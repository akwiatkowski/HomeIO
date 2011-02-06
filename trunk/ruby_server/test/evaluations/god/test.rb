f = File.new('pid','w')
f.puts( $$ )
f.close

puts "RUN"
  
sleep 10