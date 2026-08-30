# frozen_string_literal: true

require 'test_helper'

class ActiveRecordRelationUniqTest < Deprecool::FinderTest
  finder Deprecool::Finders::Rails::V8_2_0::ActiveRecordRelationUniq

  def test_uniq_call_chained_to_where_is_high_confidence
    # this source is taken from the original pr that added the uniq! method
    source = <<~SOURCE
      accounts = Account.group(:firm_id)
      accounts.merge(accounts.where.not(credit_limit: nil)).uniq!(:group).sum(:credit_limit)
    SOURCE

    assert_offense source, confidence: :high
  end

  def test_bare_uniq_call_to_variable_is_low_confidence
    assert_offense 'users.uniq!(:column_name)', confidence: :low
  end

  def test_uniq_call_on_array_method_chain_has_no_offenses
    assert_no_offenses 'my_array.map(&:to_s).uniq!'
  end

  def test_bare_uniq_call_to_variable_with_inline_block_has_no_offenses
    assert_no_offenses 'my_array.uniq! { |element| element.size }'
  end

  def test_bare_uniq_call_to_variable_with_block_has_no_offenses
    source = <<~SOURCE
      my_array.uniq! do |element|
        element.size
      end
    SOURCE

    assert_no_offenses source
  end

  def test_uniq_call_on_array_has_no_offenses
    assert_no_offenses '[1, 1, 2].uniq!'
  end

  def test_bare_uniq_call_with_proc_sugar_has_no_offense
    assert_no_offenses 'some_array.uniq!(&:name)'
  end
end
