# Scans for metar directories and join them all!
#
# If you run HomeIO on many computers and wish to join metar logs and import them to DB on one machine you
# need to:
# * copy from all instancec of HomeIO from path ruby_server/data/metar_log/ to <current_dir>/<whatever>/
# * run this script :)


class Dir

  def self.sub_dirs(dir)
    self.sub_objects(dir, true)
  end

  def self.sub_files(dir)
    self.sub_objects(dir, false)
  end

  def self.sub_objects(dir, directories = false)
    # everything inside
    dirs = Dir.entries(dir).delete_if { |d| d == '.' or d == '..' }
    # only directories
    dirs = dirs.select { |d| File.directory?(File.join(dir, d)) == directories }

    return dirs
  end

end

# Tool used with HomeIO

class MetarJoiner

  def initialize(dir = '.')
    @main_dir = dir

    @dirs = Dir.sub_dirs(dir)

    # city scan
    @cities = Array.new
    @dirs.each do |d|
      @cities += scan_dir_for_cities(d)
    end
    @cities.uniq!

    puts @dirs.inspect
    puts @cities.inspect
  end

  # Return cities (subdirectories)
  def scan_dir_for_cities(d)
    []
  end

end

MetarJoiner.new