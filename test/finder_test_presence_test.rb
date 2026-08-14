# frozen_string_literal: true

require 'test_helper'

module Deprecool
  # ensure that every new Finder gets an associated test
  class FinderTestPresenceTest < Minitest::Test
    def test_ensure_all_finders_are_tested
      # grab each FinderTest and remove the word 'Test'
      finder_tests = Deprecool::FinderTest.subclasses.map { |klass| klass.name[..-5] }
      finders      = Registry.all_finders.map { |klass| klass.name.split('::').last }

      assert_equal (finders - finder_tests), []
    end
  end
end
