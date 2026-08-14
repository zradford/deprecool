# frozen_string_literal: true

require 'json'
require 'dry/cli'

module Deprecool
  # Command-line entry point. Scans the given files/directories and reports
  # deprecations.
  module CLI
    module Commands
      extend Dry::CLI::Registry

      class Version < Dry::CLI::Command
        desc 'Print the deprecool version'

        def call(*)
          puts "deprecool #{Deprecool::VERSION}"
        end
      end

      class List < Dry::CLI::Command
        desc 'Display which finders are used in this version'

        option :gems, type: :array, desc: 'Specify gem name(s) to list which versions have deprecation tracking available'

        def call(gems:)
          CLI.list_finders(Finder.registry)

          # TODO: REPL to filter through the available finders?
        end
      end

      class Scan < Dry::CLI::Command
        desc 'Scan files or directories for known deprecations'

        argument :paths, type: :array, desc: 'Files or directories to scan'
        option :lockfile, default: 'Gemfile.lock', desc: 'Path to Gemfile.lock, defaults to current directory'
        option :gems, type: :array, desc: 'Gems to scan for: --gems=ruby,rails'
        option :format, default: 'text', values: %w[text json], desc: 'Output format'
        option :all, type: :boolean, default: false, desc: 'Run every finder regardless of version'

        def call(paths:, format:, gems: [], all:, lockfile:, **)
          json_output = format == 'json'
          files   = CLI.ruby_files(paths)

          if files.empty?
            if paths.empty?
              warn CLI.colorize('deprecool: please supply a path/to/file/or/directory', :red)
              exit 2
            end

            warn CLI.colorize("deprecool: no Ruby files found in #{paths.join(', ')}", :red)
            exit 2
          end

          if gems.any?
            puts "Scanning for deprecations from: #{gems.join(', ')}" unless json_output
            # we won't be scanning a lockfile
            gem_versions = []
          elsif all
            gem_versions = []
            gems = []
          else
            puts "Scanning #{lockfile}..." unless json_output
            gem_versions = LockfileParser.parse!(lockfile)

            # we don't need to look for individual gems when scanning gemfiles
            gems = []
          end

          finders  = Registry.applicable(gems:, gem_versions:, include_all: all)
          scanner  = Scanner.new(finders)
          offenses = files.flat_map { |file| scanner.scan_file(file) }
                          .sort_by  { |offense| [offense.file_path, offense.line, offense.column] }

          offenses = offenses.group_by(&:id) unless json_output

          CLI.report(offenses, format, finders)
          exit(offenses.empty? ? 0 : 1)
        end
      end

      register 'version', Version, aliases: %w[v -v --version]
      register 'scan', Scan
      register 'list', List, aliases: %w[l -l --list]
    end

    class << self
      def start(argv)
        Dry::CLI.new(Commands).call(arguments: argv)
      end

      def ruby_files(paths)
        paths = paths.empty? ? ['.'] : paths

        paths.flat_map do |path|
          if File.directory?(path)
            Dir[File.join(path, '**', '*.rb')]
          elsif File.file?(path)
            [path]
          else
            warn "deprecool: no such file or directory: #{path}"
            []
          end
        end.uniq.sort
      end

      def report(offenses, format, finders)
        if format == 'json'
          puts JSON.pretty_generate(offenses.map(&:to_h))
        else
          text_report(offenses, finders)
        end
      end

      def text_report(offenses, finders)
        if offenses.empty?
          puts colorize('No deprecations found.', :green)
          puts "(#{finders.size} finder(s) active)"
          return
        end

        offense_count = 0

        offenses.each_value do |offense_array|
          offense = offense_array.first

          puts "\n#{colorize(offense.title, :bold)}\n"
          puts " * #{offense.summary}"
          puts "  #{colorize('fix:', :green)} #{offense.suggestion}" if offense.suggestion
          puts "  #{colorize('source:', :green)} #{offense.reference}" if offense.reference
          puts '  Found At:'
          offense_array.each do |o|
            offense_count   += 1
            confidence       = o.confidence
            confidence_color = confidence == :high ? :red : :yellow
            badge            = colorize("(#{confidence} confidence)", confidence_color)

            puts " (#{offense_count}) #{colorize(o.location, :cyan)} #{badge}"
            puts "    #{o.source_line.strip}" if o.source_line
            puts
          end
        end

        puts colorize("#{offense_count} deprecation#{'s' unless offense_count == 1} found.", :red)
      end

      def list_finders(finders)
        puts 'Active finders:'
        finders.sort_by { [it.gem.to_s, it.deprecated_in.to_s, it.id.to_s] }.each do
          puts " - #{it.classname.ljust(35)} (#{it.gem} #{it.deprecated_in.to_s}) — #{it.title}"
        end
        puts '  (none)' if finders.empty?
      end

      def colorize(text, color)
        colors = { red: 31, green: 32, yellow: 33, cyan: 36, bold: 1 }

        "\e[#{colors.fetch(color, nil)}m#{text}\e[0m"
      end
    end
  end
end
