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
          CLI.list_finders(Finder.subclasses)

          # TODO: REPL to filter through the available finders?
        end
      end

      class Scan < Dry::CLI::Command
        desc 'Scan files or directories for known deprecations'

        argument :paths, type: :array, desc: 'Files or directories to scan'

        option :format,
               default: 'text',
               values: %w[text json],
               desc: 'Output format'

        option :gems,
               type: :array,
               desc: 'Gems to scan for: --gems=ruby,rails'

        option :lockfile,
               default: 'Gemfile.lock',
               desc: 'Path to Gemfile.lock, defaults to current directory'

        option :all,
               type: :boolean,
               default: false,
               desc: 'Run every finder regardless of version'

        def call(paths:, format:, gems: [], lockfile:, all:, **)
          json_output = format == 'json'
          files = CLI.ruby_files(paths)

          if paths.empty?
            puts 'No path given, using \'.\' as the path' unless json_output
          end

          # TODO: detect when deprecool is run on too many projects at once
          # i.e. if you run it on a ~/Documents folder and it finds
          # a ton of files from different projects it doesn't know what finders
          # to use and finds nothing
          if files.empty?
            warn "No ruby files found in #{paths.join(', ')}"
            exit 1
          end

          dependency_files = CLI.find_dependency_files
          gem_versions = []
          gems ||= []

          # if the user supplied "all" then we don't worry about finding gem versions
          if !all
            # next we need to find where the dependencies come from, or we could match
            # offenses from not applicable versions of gems
            if dependency_files.any?
              puts "Scanning #{dependency_files.join(', ')} ..."
              gem_versions = DependencyParser.parse_all(dependency_files)
              if gems.any?
                puts "Scanning for deprecations from: #{gems.join(', ')}" unless json_output
              end
            end
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
        begin
          files = paths.flat_map do |path|
            if File.directory?(path)
              Dir[File.join(path, '**', '*.rb')]
            elsif File.file?(path)
              [path]
            else
              warn "deprecool: no such file or directory: #{path}"
              []
            end
          end.uniq.sort
        rescue SystemCallError => err
          warn "deprecool: An error occurred - #{err}"
        ensure
          files ||= []

          return files
        end
      end

      def find_dependency_files
        Dir["*.gemspec", "Gemfile.lock"]
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
          puts "(#{finders&.size || 0} finder(s) active)"
          return
        end

        offense_count = 0

        offenses.each_value do |offense_array|
          offense = offense_array.first

          puts "\n#{offense.gem} #{offense.deprecated_in} - #{colorize(offense.title, :bold)}"
          puts
          puts " * #{offense.summary}"
          puts
          puts "  #{colorize('effort:', :green).ljust(19)} #{colorize_effort(offense.effort)}"
          puts "  #{colorize('fix:', :green).ljust(19)} #{offense.suggestion}"   if offense.suggestion
          puts "  #{colorize('source(s):', :green).ljust(19)} #{offense.reference}" if offense.reference
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
        finders.sort_by { |f| [f.gem.to_s, f.deprecated_in.to_s, f.id.to_s] }.each do
          puts " - #{f.classname.ljust(35)} (#{f.gem} #{f.deprecated_in.to_s}) — #{f.title}"
        end
        puts '  (none)' if finders.empty?
      end

      def colorize(text, color)
        colors = { red: 31, green: 32, yellow: 33, cyan: 36, bold: 1 }

        "\e[#{colors.fetch(color, nil)}m#{text}\e[0m"
      end

      def colorize_effort(effort)
        # the effort method raises if you set anything but these
        # values so it's safe to assume, it would also be a hassle
        # to remove duplication here so oh well
        effort_colors = { low:    :green,
                          medium: :yellow,
                          high: :red }

        colorize(effort, effort_colors[effort])
      end
    end
  end
end
