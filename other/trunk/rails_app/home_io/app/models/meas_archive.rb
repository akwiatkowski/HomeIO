# Measurements

class MeasArchive < ActiveRecord::Base
  belongs_to :meas_type

  validates_presence_of :value, :time_from, :time_to, :meas_type

  # will paginate
  attr_reader :per_page
  @per_page = 20

  # recent measurements
  scope :recent, :order => "time_from DESC", :include => :meas_type

  scope :time_from, lambda {|from|
    tf = from.to_time(:local)
    where ["time_from >= ?", tf]
    }
  scope :time_to, lambda {|tto|
    tt = tto.to_time(:local)
    where ["time_to <= ?", tt]
  }
  scope :meas_type_id, lambda { |id| where(:meas_type_id => id) unless id == 'all' }



  # Measurement time range begin. Fix for storing microseconds
  def time_from_w_ms
    return Time.at(self.time_from.to_i.to_f + self._time_from_ms.to_f / 1000.0)
  end

  # Measurement time range end. Fix for storing microseconds
  def time_to_w_ms
    return Time.at(self.time_to.to_i.to_f + self._time_to_ms.to_f / 1000.0)
  end

  # Measurement time range begin. Fix for storing microseconds
  def time_from_w_ms=(t)
    self.time_from = t
    self._time_from_ms = t.usec / 1000
  end

  # Measurement time range end. Fix for storing microseconds
  def time_to_w_ms=(t)
    self.time_to = t
    self._time_to_ms = t.usec / 1000
  end

  # Get last measurements of all types if direct connection to backend is not available
  def self.all_types_last_measurements
    @meas_types = MeasType.all
    @meas_archives = Array.new
    @meas_types.each do |mt|
      @meas_archives << mt.meas_archives.last
    end
    return @meas_archives
  end

  # Create json data used for creating charts for MeasArchive instances
  # TODO move it elsewhere
  def self.todo_to_json_graph(array)
    times = Array.new
    values = Array.new

    array.sort { |m, n| m.time_from <=> n.time_from }.each do |ma|
      # measurements will be drawn as horizontal line as time range
      times << (ma.time_from - Time.now) / 60
      times << (ma.time_to - Time.now) / 60

      values << ma.value
      values << ma.value
    end

    return {
      :x => times,
      :y => values
    }
  end

end
