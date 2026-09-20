# frozen_string_literal: true

require 'bundler'

module Deprecool
  module DependencyParsers
    module LockfileParser
      extend self

      def parse!(path_to_gemfile_lock = 'Gemfile.lock', parser: Bundler::LockfileParser)
        raise FileNotFound.new('.lock') unless File.exist? path_to_gemfile_lock

        parsed = parser.new(File.read(path_to_gemfile_lock))
        lockfile_gem_versions = GemVersions.new

        parsed.specs.map do |spec|
          lockfile_gem_versions.add(gem: spec.name, version: spec.version)
        end

        if parsed.ruby_version
          gem, version = parsed.ruby_version.split
          lockfile_gem_versions.add(gem:, version: without_patchlevel(version))
        else
          puts "No Ruby version found"
        end

        lockfile_gem_versions.gem_versions
      end

      private

      def without_patchlevel(version) = version[/\d+(\.\d+)*/]
    end
  end
end
