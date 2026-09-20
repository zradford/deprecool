# frozen_string_literal: true

module Deprecool
  module DependencyParsers
    module NullParser
      extend self

      def parse!(file)
        warn "Attempted to parse #{file} for dependencies, but deprecool does not support #{File.extname(file)} yet."

        []
      end
    end
  end
end
