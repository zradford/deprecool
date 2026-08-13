# Deprecool

A static ruby code analyzer to find your deprecated code!

For any developer who has ever ignored a gem's warning and then ran into an error when they went to update

## Usage

Add to your gemfile: `gem 'deprecool'`
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

```
deprecool scan --gem=rails,ruby
```
_(make sure there are no spaces between the gem names)_

- `--format=json` if you want the output as json instead of the default text
- `--lockfile` takes a path to your `Gemfile.lock`, it defaults to using the current directory
- `--all` run every finder regardless of applicability
- `--paths` an array of the files or directories to look for ruby file in, defaults to `'.'`
