# Deprecool

A static ruby code analyzer to find your deprecated code!

A helpful tool for any developer who has ever ignored a gem's warning and then ran into an error when they went to update

## Usage

Add to your Gemfile: `gem 'deprecool'`, and `bundle install`

Or directly `gem install deprecool`

Then you can run `deprecool` in the command line to get:

```
Commands:
  deprecool list                     # Display which finders are used in this version
  deprecool scan [PATHS]             # Scan files or directories for known deprecations
  deprecool version                  # Print the deprecool version
```

### Scan

`deprecool scan` has several options that can be passed, or it can be run in a folder with a `Gemfile.lock` to automatically look for deprecations based on the currently installed gems.

- `--gem` takes a comma separated list of gems to scan for:

_(make sure there are no spaces between the gem names)_

```
deprecool scan --gem=rails,ruby
```

- `--format=json` if you want the output as json instead of the default text
- `--lockfile` takes a path to your `Gemfile.lock`, it defaults to using the current directory
- `--all` run every finder regardless of applicability
- `--paths` an array of the files or directories to look for ruby file in, defaults to `'.'`

## Contributing

This project has an incredibly large scope and I can't do it alone!

If you see a deprecation warning in your code that isn't reflected here please either create an issue or make a PR

Deprecool is designed to be able to support new deprecation warnings very easily.

After cloning the repo, simply add two files:

```
lib/deprecool/finders/< gem name >/< gem version>/<short_name_of_warning>.rb

test/deprecool/finders/< gem name >/< gem version>/<short_name_of_warning>_test.rb
```

Or, run the `exe/contribute` script and it will prompt you for:
- the gem name
- the version the deprecation first appears in
- a short name for the warning's finder class

_(if the script doesn't work, run `chmod +x exe/contribute` and try again)_

Then use `rake` to run the test suite.

