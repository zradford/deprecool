# frozen_string_literal: true

module Deprecool
  module DependencyParsers
    module GemspecParser
      extend self

      def parse!(gemspec_file_path)
        raise FileNotFound.new('.gemspec') unless File.exist? gemspec_file_path

        parsed = Gem::Specification.load(gemspec_file_path)

        raise InvalidGemspec.new(gemspec_file_path) if parsed.nil?

        gem_versions = GemVersions.new

        parsed.dependencies.each do |dep|
          gem_versions.add(gem: dep.name, version: minimum_version(dep.requirement))
        end

        gem_versions.add(gem: 'ruby', version: minimum_version(parsed.required_ruby_version))

        gem_versions.gem_versions
      end

      private

      def minimum_version(requirement)
        lower_bounds = requirement.requirements.filter_map { |req| lower_bound(*req) }

        lower_bounds.min || Gem::Version.new(0)
      end

      def lower_bound(operator, version)
        case operator
        when '=', '>=', '>', '~>' then version
        end
      end
    end
  end
end
