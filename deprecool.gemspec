# frozen_string_literal: true

require_relative 'lib/deprecool/version'

Gem::Specification.new do |s|
  s.name    = 'deprecool'
  s.authors = ['Zac Radford']
  s.email   = ['zacnradford@gmail.com']
  s.version = Deprecool::VERSION
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
