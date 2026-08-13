# frozen_string_literal: true

require 'test_helper'

class SerializerPositionalClassArgumentTest < Deprecool::FinderTest
  finder Deprecool::Finders::Rails::V7_1_0::SerializerPositionalClassArgument

  def test_deprecated_use_of_positional_argument_gets_flagged
    assert_offense 'serialize :my_column, MyEncoder', confidence: :high
  end

  def test_full_class
    file = <<~FILE
      class User < ActiveRecord::Base
        serialize :name, NameSerializer

        def some_method(with_arg, another:)
          puts another if another

          does_something with_arg
        end
      end
    FILE

    assert_offense file, confidence: :high
  end

  def test_corrected_usage_of_coder_kwarg_does_not_get_flagged
    assert_no_offense 'serialize :my_column, coder: MyEncoder'
  end

  def test_bare_method_without_custom_encoder_arg
    assert_no_offense 'serialize :my_column'
  end
end
