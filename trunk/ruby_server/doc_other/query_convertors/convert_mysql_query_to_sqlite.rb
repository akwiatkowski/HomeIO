t = ""
f = File.new("temp.sql","r")
f.each_line do |l|
  t += l
  t += "\n"
end
f.close

f = File.new("temp_sqlite.sql","w")

puts t

data = t.scan(/(\(\d[^)]*\))/)
data.each do |d|
  f.puts "INSERT INTO `weather_metar_archives` (`time_to`,`pressure`,`created_at`,`snow`,`raw`,`rain`,`temperature`,`time_from`,`wind`,`city_id`) VALUES #{d};"
end
f.close