# frozen_string_literal: true

require 'prism'

module Deprecool
  class Error < StandardError; end
end

require_relative 'deprecool/version'
require_relative 'deprecool/finder'
require_relative 'deprecool/registry'
require_relative 'deprecool/scanner'
require_relative 'deprecool/lockfile_parser'
require_relative 'deprecool/cli'

# TODO: Scan gemfiles and then only require relevant finders instead of all
# of them
Dir[File.join(__dir__, 'deprecool', 'finders', '**', '*.rb')].each do |finder|
  require finder
end

