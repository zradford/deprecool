# frozen_string_literal: true

require_relative 'dependency_parsers/gemspec_parser'
require_relative 'dependency_parsers/lockfile_parser'
require_relative 'dependency_parsers/null_parser'

module Deprecool
  module DependencyParser
    extend self

    def parse_all(dependency_files)
      files = Array(dependency_files)

      dependencies = GemVersions.new

      files.each do |file|
        dependencies.add_all!(parser_for_file(file).parse!(file))
      end

      dependencies
    end

    def parser_for_file(dependency_file)
      case File.extname(dependency_file)
      when '.lock'    then DependencyParsers::LockfileParser
      when '.gemspec' then DependencyParsers::GemspecParser
      else
        DependencyParsers::NullParser
      end
    end
  end
end
