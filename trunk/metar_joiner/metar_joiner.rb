# Scans for metar directories and join them all!
#
# If you run HomeIO on many computers and wish to join metar logs and import them to DB on one machine you
# need to:
# * copy from all instancec of HomeIO from path ruby_server/data/metar_log/ to <current_dir>/<whatever>/
# * run this script :)
# * get them from ./_RESULT
#
# ./<dir>/<city>/<year>/metar_<city>_2010_11.log

require 'yaml'

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

    # list of directories to join,
    @dirs = Dir.sub_dirs(dir)
    puts @dirs.inspect

    # city scan
    #@cities = scan_dir_for_cities
    #puts @cities.inspect
    #puts @cities.size

    files = scan_for_files
    files.each do |f|
      join_file(f)
    end
  end

  # Return cities (subdirectories)
  # DEPRECATED
  def scan_dir_for_cities
    cities = Array.new
    @dirs.each do |d|
      cities += Dir.sub_dirs(File.join(@main_dir, d))
    end
    cities.uniq!
    return cities
  end

  # Scan for all log files
  def scan_for_files
    files = Array.new
    @dirs.each do |d|
      # directories loop

      cities = Dir.sub_dirs(File.join(@main_dir, d))
      cities.each do |c|
        # cities loop

        years = Dir.sub_dirs(File.join(@main_dir, d, c))
        years.each do |y|
          # years loop

          files += Dir.sub_files(File.join(@main_dir, d, c, y))
        end
      end
    end

    return files.uniq.sort
  end

  # Join one type of file from all directories
  def join_file(f)
    files_count = 0
    if f =~ /metar_(\w{4})_(\d{4})_(\d{1,2})\.log/
      metar = Array.new

      c = $1
      y = $2
      m = $3

      @dirs.each do |d|
        file_name = File.join(@main_dir, d, c, y, f)
        if File.exist?( file_name)
          # load file and add lines to array
          file = File.new(file_name, "r")
          file.each_line do |m|
            metar << m
          end
          file.close

          # processed files count
          files_count += 1
        end
      end

      # sort and uniq
      metar = metar.uniq.sort
      puts "File #{f} lines #{metar.size} joined from #{files_count} files"

      # save new file
      new_dir = File.join(@main_dir, '_RESULT', c, y)
      `mkdir -p #{new_dir}`
      new_file_name = File.join(new_dir, f)
      new_file = File.new(new_file_name, "w")
      # puts metars
      metar.each do |m|
        new_file.puts m
      end
      new_file.close

      return true

    else
      puts "Error - file #{f}"
      return nil
    end

  end

end

MetarJoiner.new