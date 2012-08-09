require 'rubygems'
require 'yaml'
require './lib/storage/storage_active_record.rb'

Dir.mkdir('data/backup') unless File.exists?('data/backup')
s = StorageActiveRecord.instance

puts "getting all meas types"
types = MeasType.all

#puts "getting first meas"
#first_meas = MeasArchive.order(:time_from).first
#puts "... first meas time #{first_meas.time_from}"
#time = first_meas.time_from.beginning_of_day

# initial backup
#time = Time.at(1309381405).beginning_of_day - 1.day
#time_limit = Time.now.end_of_day


# later as daily backup
time = (Time.now.end_of_day - 7.days).beginning_of_day
time_limit = Time.now.end_of_day

puts "#{(time_limit - time) / 1.days} days to go"

while time < time_limit
  types.each do |type|
    puts "starting day #{time.strftime("%Y_%m_%d")}, type #{type.name}"
    bt = Time.now

    file_name = File.join('data', 'backup', "meas_#{time.strftime("%Y_%m_%d")}_#{type.name}.csv")
    file = File.new(file_name, 'w')
    file.puts "meas_type;unix_time_from;unix_time_to;raw_value;value"

    meases = MeasArchive.where(meas_type_id: type.id).where(["time_from >= ?", time]).where(["time_from < ?", time + 1.day]).all
    meases.each do |m|
      file.puts "#{type.name};#{m.time_from.to_f};#{m.time_to.to_f};#{m.raw};#{m.value}"
    end

    file.close

    puts "finished day #{time}, type #{type.name}, took #{Time.now - bt}, meases #{meases.size}"
  end
  
  time += 1.day
end