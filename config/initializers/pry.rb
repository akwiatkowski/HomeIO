HomeIO::Application.configure do
  # Use Pry instead of IRB
  silence_warnings do
    begin
      require 'pry'
      IRB = Pry
    rescue LoadError
    end
  end

  # crazy web console
  #Rack::Webconsole.inject_jquery = true
  #Rack::Webconsole.key_code = 94
end

