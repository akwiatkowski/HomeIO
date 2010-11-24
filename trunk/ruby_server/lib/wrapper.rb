require './lib/comm_wrapper.rb'
require './lib/metar_wrapper_module.rb'

# Opiekun używanych procesów
class Wrapper < CommWrapper
  include MetarWrapperModule
end
