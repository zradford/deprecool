# frozen_string_literal: true

require 'test_helper'

class ToSqlBindsTest < Deprecool::FinderTest
  finder Deprecool::Finders::Rails::V8_2_0::ToSqlBinds

  # TODO: find more examples in rails of this method being called with binds
  def test_bare_method_with_two_arguments
    assert_offense 'to_sql("SELECT 1", [some_bind])', confidence: :high
  end

  def test_bare_method_with_one_argument
    assert_no_offense 'to_sql("SELECT 1")'
  end
end
