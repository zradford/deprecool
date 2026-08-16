# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'deprecool'
require 'minitest/autorun'

module Deprecool
  # Base class for finder tests. Provides helpers to run a single finder against
  # an inline source string and make assertions about the resulting offenses.
  class FinderTest < Minitest::Test
    # The finder class for assert_offense and assert_no_offense to use
    def self.finder(klass) = define_method(:finder) { klass }

    def scan(source) = Scanner.new(finder).scan_source(source)

    def assert_offense(source, confidence: nil)
      offenses = scan(source)
      assert_equal 1, offenses.size, "expected exactly one offense for #{source.inspect}, got #{offenses.size}"
      assert_equal confidence, offenses.first.confidence if confidence
    end

    def assert_no_offense(source)
      offenses = scan(source)
      assert_empty offenses, -> { "expected #{source.inspect} to be empty, but #{offenses.size} offense(s) were found" }
    end
  end
end
