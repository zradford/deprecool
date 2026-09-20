# frozen_string_literal: true

require 'test_helper'
require 'tempfile'

module Deprecool
  class ParserTest < Minitest::Test
    def test_parser_finder__uses_gemspec_parser_for_gemspec
      with_sample_gemspec do |file|
        parser = DependencyParser.parser_for_file(file.path)

        assert_equal DependencyParsers::GemspecParser, parser
      end
    end

    def test_gemspec_parser__gets_all_dependencies
      with_sample_gemspec do |file|
        dependencies = DependencyParsers::GemspecParser.parse!(file.path)

        assert_includes dependencies, { gem: :'dry-cli', version: Gem::Version.new('1.0') }
        assert_includes dependencies, { gem: :prism, version: Gem::Version.new('1.0') }
        assert_includes dependencies, { gem: :ruby, version: Gem::Version.new('3.3') }
      end
    end

    def test_gemspec_parser__raises_when_the_file_is_missing
      assert_raises(FileNotFound) { DependencyParsers::GemspecParser.parse!('no/such.gemspec') }
    end

    def test_gemspec_parser__raises_when_the_gemspec_cannot_be_loaded
      with_tempfile(filename: ['broken', '.gemspec'], text: '') do |file|
        # this will output a warning in the test list so capture_io
        # hides that for us so we can just have .....'s as output
        capture_io do
          assert_raises(InvalidGemspec) { DependencyParsers::GemspecParser.parse!(file.path) }
        end
      end
    end

    def test_parser_finder__uses_lockfile_parser_for_lockfile
      with_sample_gemfile_lock do |file|
        parser = DependencyParser.parser_for_file(file.path)

        assert_equal DependencyParsers::LockfileParser, parser
      end
    end

    def test_lockfile_parser__gets_all_dependencies
      with_sample_gemfile_lock do |file|
        dependencies = DependencyParsers::LockfileParser.parse!(file.path)

        expected = { deprecool: '0.1.3', drb: '2.2.3',   'dry-cli': '1.4.1',
                     minitest: '6.0.6',  prism: '1.9.0', rake: '13.4.2',
                     ruby: '3.3.0' }

        expected.each do |gem, version|
          assert_includes dependencies, { gem:, version: Gem::Version.new(version) }
        end
      end
    end

    def test_lockfile_parser__skips_ruby_when_the_lockfile_has_no_ruby_version
      with_tempfile(filename: ['Gemfile', '.lock'], text: gemfile_lock_body) do |file|
        capture_io do
          dependencies = DependencyParsers::LockfileParser.parse!(file.path)
          assert_includes dependencies, { gem: :prism, version: Gem::Version.new('1.9.0') }
          refute_includes dependencies.map { |dep| dep[:gem] }, :ruby
        end
      end
    end

    def test_lockfile_parser__raises_when_the_file_is_missing
      assert_raises(FileNotFound) { DependencyParsers::LockfileParser.parse!('no/such.lock') }
    end

    private

    def with_tempfile(filename:, text:, &block)
      Tempfile.create(filename) do |file|
        file.puts text
        file.flush

        yield file
      end
    end

    def with_sample_gemspec(&block)
      with_tempfile(**sample_gemspec) do |file|
        yield file
      end
    end

    def with_sample_gemfile_lock(&block)
      with_tempfile(**sample_gemfile_lock) do |file|
        yield file
      end
    end

    # filename is an array because Tempfile.open names tempfiles with an array filename value
    # in a way that the second item is at the end of the filename.
    # this will produce a filename like: "/tmp/sample20260919-17839-58xtfi.gemspec"
    def sample_gemspec = {
      filename: ['sample', '.gemspec'],
      text: <<~GEMSPEC
        Gem::Specification.new do |s|
          s.name    = 'deprecool'
          s.authors = ['Zac Radford']
          s.email   = ['zacnradford@gmail.com']
          s.version = '0.1.3'
          s.required_ruby_version = '>= 3.3'

          s.summary       = 'Static deprecation analysis tool to keep your code cool'
          s.description   = s.summary

          s.files         = Dir['lib/**/*.rb']
          s.bindir        = 'exe'
          s.executables   = ['deprecool']
          s.require_paths = ['lib']
          s.extra_rdoc_files = ['README.md', 'CHANGELOG.md', 'LICENSE']
          s.license = 'MIT'

          s.homepage                    = 'https://github.com/zradford/deprecool'
          s.metadata['changelog_uri']   = 'https://github.com/zradford/deprecool/CHANGELOG.md'
          s.metadata['source_code_uri'] = 'https://github.com/zradford/deprecool'
          s.metadata['bug_tracker_uri'] = 'https://github.com/zradford/deprecool/issues'
          s.metadata['rubygems_mfa_required'] = 'true'

          s.add_dependency 'dry-cli', '>= 1.0'
          s.add_dependency 'prism', '>= 1.0'
        end
      GEMSPEC
    }

    def sample_gemfile_lock = {
      filename: ['Gemfile', '.lock'],
      text: gemfile_lock_body(ruby_version: '3.3.0p0')
    }

    def gemfile_lock_body(ruby_version: nil)
      lock = <<~LOCK
        PATH
          remote: .
          specs:
            deprecool (0.1.3)
              dry-cli (>= 1.0)
              prism (>= 1.0)

        GEM
          remote: https://rubygems.org/
          specs:
            drb (2.2.3)
            dry-cli (1.4.1)
            minitest (6.0.6)
              drb (~> 2.0)
              prism (~> 1.5)
            prism (1.9.0)
            rake (13.4.2)

        PLATFORMS
          arm64-darwin-24
          ruby

        DEPENDENCIES
          deprecool!
          minitest
          rake

      LOCK

      lock += "RUBY VERSION\n   ruby #{ruby_version}\n\n" if ruby_version

      lock + <<~LOCK
        BUNDLED WITH
           4.0.8
      LOCK
    end
  end
end
