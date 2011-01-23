require './lib/utils/config_loader.rb'
require 'test/unit'

class TestConfigLoader < Test::Unit::TestCase

  def test_sampleconfigs
    @cf = ConfigLoader.instance
    klass_name = "WeatherRipper"
    metar_config = @cf.config( klass_name )

    assert_kind_of Hash, metar_config

    assert_raise(Errno::ENOENT) {
      @cf.config("missing_config_file")
    }

    manualy_loaded = YAML::load_file(
      File.join(
        ConfigLoader::CONFIG_FILES_PATH,
        "#{klass_name.to_s}.yml")
    )

    assert_equal manualy_loaded, metar_config
  end

end

