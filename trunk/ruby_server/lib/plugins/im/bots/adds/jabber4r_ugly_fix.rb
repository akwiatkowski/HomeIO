# This class is ugly. I mean really ugly, ugly as hell. I should put bag on it...
# Probably works better in ruby 1.8. Using Xmpp4r instead of this.

module REXML
  class IOSource
    def position
      begin
        @er_source.pos
      rescue
        0
      end
    end
  end
end

module Jabber
  module Protocol
    class REXMLJabberParser
      def parse
        @started = false
        begin
          parser = REXML::Parsers::SAX2Parser.new @stream
          parser.listen( :start_element ) do |uri, localname, qname, attributes|
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
          parser.listen( :end_element ) do  |uri, localname, qname|
            case qname
            when "stream:stream"
              @started = false
            else
              @listener.receive(@current) unless @current.element_parent
              @current = @current.element_parent
            end
          end
          parser.listen( :characters ) do | text |
            @current.append_data(text) if @current
          end
          parser.listen( :cdata ) do | text |
            @current.append_data(text) if @current
          end
          parser.parse
          #rescue REXML::ParseException
          #@listener.parse_failure
        end
      end
    end
  end
end