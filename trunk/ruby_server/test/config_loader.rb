require 'lib/config_loader'
require 'test/unit'

class TestConfigLoader < Test::Unit::TestCase

  def test_init
    @cf = ConfigLoader.instance
  end

  def test_sampleconfigs
    @cf = ConfigLoader.instance
    metar_config = @cf.config("metar")

    assert_kind_of Hash, metar_config

    assert_raise(Errno::ENOENT) {
      @cf.config("missing_config_file")
    }

  end

end




#
#