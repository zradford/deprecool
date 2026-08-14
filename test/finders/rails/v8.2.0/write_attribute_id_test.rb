# frozen_string_literal: true

require 'test_helper'

class WriteAttributeIdTest < Deprecool::FinderTest
  finder Deprecool::Finders::Rails::V8_2_0::WriteAttributeId

  def test_writing_to_id_attribute_has_offense
    assert_offense 'write_attribute(:id, some_value)', confidence: :high
  end

  def test_writing_to_id_attribute_with_string_param_has_offense
    assert_offense 'write_attribute("id", some_value)', confidence: :high
  end

  def test_writing_to_other_attribute_has_no_offense
    assert_no_offense 'write_attribute(:name, some_value)'
  end
end
