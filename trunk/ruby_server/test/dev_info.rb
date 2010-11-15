require 'lib/dev_info'
require 'test/unit'

class TestDevInfo < Test::Unit::TestCase

  def test_simple
    di = DevInfo.instance

    # incremental test
    di[:test ][:sample] = 0
    pre_test = di[:test][:sample]
    di.inc( :test, :sample )
    post_test = di[:test][:sample]

    assert_equal pre_test + 1, post_test


    # direct modify test
    time_now = Time.now
    di[:test][:other_sample] = time_now
    di.force_save
    assert_equal di[:test][:other_sample], time_now
  end

  # test autosaving
  def test_autosave
    di = DevInfo.instance
    interval = di.autosave_interval

    # test count
    count_pre = di[ di.class ][ :autosave_count ]
    sleep( interval * 1.5) # neet to wait a little, increment after save
    count_after = di[ di.class ][ :autosave_count ]

    assert_equal count_pre + 1, count_after

    # test save time
    assert_in_delta(
      di[ di.class ][ :last_save ].to_f,
      File.mtime( di.file_name ).to_f,
      1
    )

  end

end




#
#