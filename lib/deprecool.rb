# frozen_string_literal: true

require 'prism'

module Deprecool; end

Dir["#{__dir__}/deprecool/helpers/*.rb"].each do |helper|
  require helper
end

require_relative 'deprecool/errors'
require_relative 'deprecool/version'
require_relative 'deprecool/gem_versions'
require_relative 'deprecool/finder'
require_relative 'deprecool/registry'
require_relative 'deprecool/scanner'
require_relative 'deprecool/dependency_parser'
require_relative 'deprecool/cli'

# TODO: Scan gemfiles and then only require relevant finders instead of all
# of them
Dir["#{__dir__}/deprecool/finders/**/*.rb"].each do |finder|
  require finder
end
