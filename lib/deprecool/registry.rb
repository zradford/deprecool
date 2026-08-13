# frozen_string_literal: true

module Deprecool
  # Selects which finders should run for a given application, based on the gems
  # (and Ruby) it actually uses and at what versions.
  module Registry
    extend self

    # Every registered finder.
    def all_finders
      Finder.registry
    end

    # Gets finders that apply to the given versions.
    # gems - an array of gem names
    # gem_versions - an array of hashes like: { gem:, version: }
    def applicable(gems: [], gem_versions: [], include_all: false)
      return all_finders if include_all
      return finders_by_gem(gems) if gems.any?
      return finders_by_gem_version(gem_versions) if gem_versions.any?
    end

    def finders_by_gem(gems)
      targets = []
      gems.each do |gem|
        targets << all_finders.select { it.to_s.match(/#{gem.capitalize}/) }
      end
      targets.flatten
    end

    def finders_by_gem_version(gem_versions)
      finder_targets = []

      gem_versions.each do |gem_version|
        jem     = gem_version[:gem].to_sym
        version = Gem::Version.new(gem_version[:version])

        # match when:
        # 1) finder is for the current gem,
        # 2) gem's version is higher than finder's deprecated,
        # and 3) gems version is lower or equal to the removed_in
        targets = all_finders.select do |finder|
          (finder.gem == jem) &&
            (finder.deprecated_in <= version) && (version <= finder.removed_in)
        end

        if !targets.empty?
          finder_targets << targets
        else
          # this unfortunately floods the terminal for now, but one day maybe it won't
          # puts "Oops, I don't have a Finder that applies to #{jem} v#{version}"
        end
      end

      finder_targets.flatten
    end
  end
end
