# Deprecool

## Unreleased
 - Rails 8.2.0 deprecation of ActiveRecord#uniq!
 - Finder Test Helper change from `assert_no_offense` to `assert_no_offenses`
 - auto-inclusion of a gem's helper method class to Finders under a gem's namespace
 
## [0.1.3] - 2026-08-24
 - Added Finder for: "Passing `binds` as a positional argument to `insert` deprecated", see [original commit](https://github.com/rails/rails/commit/2dca5457ab2097626481fdbec233ea56d3fb9ee3)
 - Added `effort` to the CLI output

## [0.1.2] - 2026-08-14

- Add Finder for Rails's deprecation of `write_attribute(:id, value)`

## [0.1.0], [0.1.1] - 2026-08-13

- Initial Release
