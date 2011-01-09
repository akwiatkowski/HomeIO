require './lib/storage/extractors/extractor_active_record.rb'
require 'test/unit'

class TestExtractor < Test::Unit::TestCase

  def test_basic
    # TODO wyciaganie danych z db
    ExtractorActiveRecord.new
  end

end

