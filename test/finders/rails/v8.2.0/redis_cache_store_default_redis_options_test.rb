# frozen_string_literal: true

require 'test_helper'

class RedisCacheStoreDefaultRedisOptionsTest < Deprecool::FinderTest
  finder Deprecool::Finders::Rails::V8_2_0::RedisCacheStoreDefaultRedisOptions

  def test_bare_method_with_two_arguments
    assert_offense 'DEFAULT_REDIS_OPTIONS', confidence: :high
  end

  def test_bare_method_with_one_argument
    assert_no_offenses 'default_redis_options = { hello: "world"}'
  end
end
