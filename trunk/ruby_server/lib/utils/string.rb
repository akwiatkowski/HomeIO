# Some new methods

class String

  # Odkodowanie co oznacza dany kod METAR - jakie miasto
  def encode_metar_name
    c = MetarTools.load_config
    o = c[:cities].select{|city| city[:code] == self}
    if o.size == 1
      return o.first[:name]
    else
      return self
    end
  end
end