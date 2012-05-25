class WindTurbinePowerCalculator

  def self.make_it_so
    mc = MeasType.where(name: 'i_gen_batt').first
    mv = MeasType.where(name: 'batt_u').first

    period = 1.hour

    puts "Getting first and last measurements"

    first_c = mc.meas_archives.order("id ASC").first
    first_v = mv.meas_archives.order("id ASC").first

    last_c = mc.meas_archives.order("id ASC").last
    last_v = mv.meas_archives.order("id ASC").last

    puts "First voltage time #{first_v.time_from.to_s(:db)}"
    puts "First current time #{first_c.time_from.to_s(:db)}"
    puts "Last  voltage time #{last_v.time_from.to_s(:db)}"
    puts "Last  current time #{last_c.time_from.to_s(:db)}"

    pc = Array.new

    t = first_c.time_from.beginning_of_day
    time_from = t
    t = first_v.time_from.beginning_of_day
    time_from = t if t < time_from

    t = last_c.time_from.end_of_day
    time_to = t
    t = last_v.time_from.end_of_day
    time_to = t if t > time_to

    puts "", "Time from #{time_from.to_s(:db)} to #{time_to.to_s(:db)}"

    puts "Starting..."

    time = time_from

    file_name = Rails.root.join('power_calculator.json')
    file_name_txt = Rails.root.join('power_calculator.txt')

    file_txt = File.new(file_name_txt, 'w')
    file_txt.close

    while time < time_to
      # search and calc
      puts "Searching from #{time.to_s(:db)} to #{(time + period).to_s(:db)}"

      currents = mc.meas_archives.where(["time_from >= ? and time_from < ?", time, time + period]).all
      voltages = mv.meas_archives.where(["time_from >= ? and time_from < ?", time, time + period]).all

      puts "Found #{voltages.size} voltages, #{currents.size} currents"

      currents = currents.collect { |c| [c.time_from, c.time_to, c.value < 0.0 ? 0.0 : c.value] }
      voltages = voltages.collect { |c| [c.time_from, c.time_to, c.value < 0.0 ? 0.0 : c.value] }

      energy = RangesMerger.energy_calculation(voltages, currents)
      puts "Calculated energy #{energy}"

      # Calculate % of time where wind turbine has > 0.5A of current
      time_with_current = 0
      currents.select { |c| c[2] > 0.5 }.collect { |c| c[1] - c[0] }.each do |t|
        time_with_current += t
      end
      puts "Time with current > 0.5A #{time_with_current}"

      file_txt = File.new(file_name_txt, 'a')
      file_txt.puts("#{time.to_i};#{(time + period).to_i};#{energy};#{time_with_current}")
      file_txt.close

      pc << {
        :time_from => time.to_i,
        :time_to => (time + period).to_i,
        :energy => energy,
        :time_wc => time_with_current
      }

      # next period
      time += period
    end

    file = File.new(file_name, 'w')
    file.puts(pc.to_json)
    file.close

  end

end