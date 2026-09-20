# lib/gem_versions.rb

module Deprecool
  class GemVersions
    include Enumerable

    attr_reader :gem_versions

    def initialize
      @gem_versions = []
    end

    def add(gem:, version:)
      @gem_versions << { gem: gem.to_sym,
                         version: Gem::Version.new(version.to_s) }
    end

    def add_all!(gemversions)
      Array(gemversions).each { |gv| add(gem: gv[:gem], version: gv[:version]) }
    end

    def each(&block)
      @gem_versions.each(&block)
    end
  end
end
