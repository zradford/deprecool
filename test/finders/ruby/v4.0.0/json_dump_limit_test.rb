# frozen_string_literal: true

require 'test_helper'

class JsonDumpLimitTest < Deprecool::FinderTest
  finder Deprecool::Finders::Ruby::V4_0_0::JsonDumpLimit

  def test_io_and_positional_limit_is_high_confidence
    assert_offense 'JSON.dump(obj, io, 10)', confidence: :high
  end

  def test_positional_limit_without_io_is_high_confidence
    assert_offense 'JSON.dump(obj, 10)', confidence: :high
  end

  def test_positional_limit_with_options_is_high_confidence
    assert_offense 'JSON.dump(obj, io, 10, { strict: true })', confidence: :high
  end

  def test_positional_limit_without_io_with_keywords_is_high_confidence
    assert_offense 'JSON.dump(obj, 10, strict: true)', confidence: :high
  end

  def test_dump_with_max_nesting_keyword_and_limit_arg_is_high_confidence
    assert_offense 'JSON.dump(obj, io, 10, max_nesting: 10)'
  end

  def test_positional_limit_without_io_with_options_hash_is_high_confidence
    assert_offense 'JSON.dump(obj, 10, { strict: true })', confidence: :high
  end

  def test_top_level_constant_receiver_is_high_confidence
    assert_offense '::JSON.dump(obj, io, 10)', confidence: :high
  end

  def test_dump_with_only_io
    assert_no_offenses 'JSON.dump(obj, io)'
  end

  def test_dump_with_max_nesting_keyword
    assert_no_offenses 'JSON.dump(obj, io, max_nesting: 10)'
  end

  def test_dump_with_options_hash_as_third_argument
    assert_no_offenses 'JSON.dump(obj, io, { max_nesting: 10 })'
  end

  def test_dump_with_nil_limit
    assert_no_offenses 'JSON.dump(obj, io, nil, { strict: true })'
  end

  def test_marshal_dump_with_limit_is_ignored
    assert_no_offenses 'Marshal.dump(obj, io, 10)'
  end
end
