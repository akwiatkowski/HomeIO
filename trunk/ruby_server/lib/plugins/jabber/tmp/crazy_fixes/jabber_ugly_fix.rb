require 'nokogiri'
# This class is ugly. I mean really ugly, ugly as hell. I should put bag on it...

# Create a subclass of Nokogiri::XML::SAX::Document and implement
# the events we care about:
class NokogiriJabberParser < Nokogiri::XML::SAX::Document
  def start_element qname, attributes = []
    puts "start_elem #{qname}"
    case qname
    when "stream:stream"
      openstream = ParsedXMLElement.new(qname)
      attributes.each { |attr, value| openstream.add_attribute(attr, value) }
      @listener.receive(openstream)
      @started = true
    else
      if @current.nil?
        @current = ParsedXMLElement.new(qname)
      else
        @current = @current.add_child(qname)
      end
      attributes.each { |attr, value| @current.add_attribute(attr, value) }
    end
  end

  def end_element qname
    puts "end_element #{qname}"
    case qname
    when "stream:stream"
      @started = false
    else
      @listener.receive(@current) unless @current.element_parent
      @current = @current.element_parent
    end
  end

  def characters text
    puts "characters #{text}"
    @current.append_data(text) if @current
  end

  def cdata text
    puts "cdata #{text}"
    @current.append_data(text) if @current
  end

end


module Jabber
  module Protocol
    class REXMLJabberParser
      def parse
        @started = false
        begin
          parser = NokogiriJabberParser.new @stream
          parser.parse
        end
      end
    end
  end
end