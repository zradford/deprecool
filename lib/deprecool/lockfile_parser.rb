# frozen_string_literal: true

require 'bundler'

module Deprecool
  module LockfileParser
    extend self

    def parse!(path_to_gemfile_lock = 'Gemfile.lock', parser: Bundler::LockfileParser)
      lockfile = File.read(path_to_gemfile_lock)

      parsed = parser.new(lockfile)

      versions = parsed.specs.map do |spec|
        { gem: spec.name, version: spec.version.to_s }
      end

      gem, version = parsed.ruby_version.split
      versions << { gem:, version: }
    end
  end
end
