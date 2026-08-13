# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'deprecool'
require 'minitest/autorun'

module Deprecool
  # Base class for finder tests. Provides helpers to run a single finder against
  # an inline source string and make assertions about the resulting offenses.
  class FinderTest < Minitest::Test
    # The finder class under test. Override in subclasses.
    def self.finder(klass)
      define_method(:finder) { klass }
    end

    def scan(source)
      Scanner.new(finder).scan_source(source)
    end

    def assert_offense(source, confidence: nil)
      offenses = scan(source)
      assert_equal 1, offenses.size,
                   "expected exactly one offense for #{source.inspect}, got #{offenses.size}"
      offense  = offenses.first
      assert_equal confidence, offense.confidence if confidence
      offense
    end

    def assert_no_offense(source)
      offenses = scan(source)
      assert_empty offenses,
                   "expected no offenses for #{source.inspect}, got #{offenses.map(&:snippet)}"
    end
  end
end
