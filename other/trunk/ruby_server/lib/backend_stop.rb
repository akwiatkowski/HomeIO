dir_path = "data/pid/"

d = Dir.glob("#{dir_path}*.pid").each do |file_name|
  pid_file = File.new(file_name, "r")
  pid = pid_file.readline
  pid_file.close

  puts "Killing #{file_name} - PID  #{pid}"

  `kill -9 #{pid}`
  `rm #{file_name}`

end
