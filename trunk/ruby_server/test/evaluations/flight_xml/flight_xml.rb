class FlightXml

  def initialize
    url = "http://flightxml.flightaware.com/soap/FlightXML2"

    require 'soap/wsdlDriver'
    require 'pp'
    wsdl = 'http://flightxml.flightaware.com/soap/FlightXML2/wsdl'
    driver = SOAP::WSDLDriverFactory.new(wsdl).create_rpc_driver

    # Log SOAP request and response
    driver.wiredump_file_base = "soap-log.txt"

    response = driver.Metar(:airport => 'EPPO')
    puts response.inspect

  end

end

f = FlightXml.new