# frozen_string_literal: true

require 'test_helper'

class ToSetArgumentsTest < Deprecool::FinderTest
  finder Deprecool::Finders::Ruby::V4_0_0::ToSetArguments

  def test_array_literal_with_argument_is_high_confidence
    assert_offense '[1, 2, 3].to_set(SortedSet)', confidence: :high
  end

  def test_hash_literal_with_argument_is_high_confidence
    assert_offense '{ a: 1 }.to_set(Set)', confidence: :high
  end

  def test_enumerable_instance_method_chain_is_high_confidence
    assert_offense 'users.map(&:id).to_set(Set)', confidence: :high
  end

  def test_local_variable_receiver_is_low_confidence
    assert_offense 'my_variable.to_set(CustomSet)', confidence: :low
  end

  def test_screaming_snake_case_constant_is_low_confidence
    assert_offense 'RECORDS.to_set(Set)', confidence: :low
  end

  def test_no_arguments_with_block
    assert_no_offense '[1, 2, 3].to_set { it * 2 }'
  end

  def test_camelcase_constant_receiver_class_method_with_argument
    assert_no_offense 'MyClass.to_set(true)'
  end

  def test_empty_parentheses_to_set_call_no_arguments
    assert_no_offense 'my_variable.to_set()'
  end

  def test_similar_method_name_with_arguments_is_ignored
    assert_no_offense 'thing.to_setup(1, 2, 3)'
  end
end
