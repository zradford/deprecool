# frozen_string_literal: true

require 'test_helper'

class InsertUpdateDeleteBindsTest < Deprecool::FinderTest
  finder Deprecool::Finders::Rails::V8_2_0::InsertUpdateDeleteBinds

  def test_binds_passed_to_insert_has_offense
    assert_offense 'connection.insert("INSERT INTO topics (title) VALUES (?)", nil, nil, ["hello"])', confidence: :high
  end

  def test_binds_passed_to_update_has_offense
    assert_offense 'connection.update("UPDATE topics SET title = ? WHERE id = 1", nil, ["hi"])', confidence: :high
  end

  def test_binds_passed_to_delete_has_offense
    assert_offense 'connection.delete("DELETE FROM topics WHERE id = ?", nil, [1])', confidence: :high
  end

  def test_variable_sql_passed_still_has_offense
    assert_offense 'connection.delete(sql_string, nil, [1])', confidence: :low
  end

  def test_update_record_has_no_offense
    assert_no_offenses 'user.update(name: "deprecool", email: "dep@cool.com")'
  end

  def test_binds_passed_with_arel_insert_has_no_offense
    assert_no_offenses 'connection.insert(Arel.sql("INSERT INTO topics (title) VALUES (?)", "hello"))'
  end

  def test_binds_passed_to_arel_update_has_no_offense
    assert_no_offenses 'connection.update(Arel.sql("UPDATE topics SET title = ? WHERE id = 1", "hi"))'
  end

  def test_binds_passed_to_arel_delete_has_no_offense
    assert_no_offenses 'connection.delete(Arel.sql("DELETE FROM topics WHERE id = ?", 1))'
  end
end
