require 'lib/comm_wrapper'
require 'lib/metar_wrapper_module'

# Opiekun używanych procesów
class Wrapper < CommWrapper
  include MetarWrapperModule
end
