require 'rubygems'
require 'logger'
require 'active_record'
require 'yaml'
require 'json'

ActiveRecord::Base.logger = Logger.new(STDERR)
ActiveRecord::Base.colorize_logging = false

ActiveRecord::Base.establish_connection(
  :adapter => "mysql",
  :host => "192.168.0.11",
  :database => "wiatrak",
  :username => "wiatrak",
  :password => "PASSWORD"
)

class DbTable < ActiveRecord::Base
  set_table_name 'pomiary'
end

empty = false
offset = 0
#partial = 1000
partial = 10_000
i = 0

prefix = "pomiary"

columns = DbTable.first.attributes.keys

while empty == false
  t = Time.now
  #data = DbTable.all(:order => 'czas ASC', :limit => partial, :offset => offset).collect { |p| p.attributes }
  data = DbTable.all(:order => 'czas ASC', :limit => partial, :offset => offset)

  filename = "dbou_#{prefix}_#{offset}_#{offset + partial}.yaml"

  # yaml, slowly
  #File.open(filename, 'w') do |out|
  #  YAML.dump(data, out)
  #end

  # json, every line - faster than yaml
  #f = File.new(filename,"w")
  #data.each do |d|
  #  f.puts( d.to_json )
  #end
  #f.close

  # json, faster than yaml
  #f = File.new(filename, "w")
  #f.puts(data.to_json)
  #f.close

  # custom, slow as hell
  #f = File.new(filename,"w")
  tmp = columns.join("; ")
  #data.each do |d|
  #  tmp = columns.collect{|c| d.attributes[c]}.join("; ")
  #  f.puts( tmp )
  #end
  #f.close


  i += 1
  offset = partial * i

  puts "done #{i} * #{partial}, #{Time.now - t} s"

# end of data
  if data.size == 0
    empty = true
  end

end

#puts "\n"*10
#puts Pomiar.first.inspect
#puts "\n"*10