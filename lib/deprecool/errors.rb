# lib/errors.rb

module Deprecool
  class Error < StandardError; end

  class FileNotFound < Error
    def initialize(filetype)
      super("No ruby files found in '#{filetype}'")
    end
  end

  class InvalidGemspec < Error
    def initialize(path)
      super("Could not load a gem specification from '#{path}'")
    end
  end

  class NoPathGiven < Error
    def initialize(_msg = nil)
      super("No path given, and no ruby files found under '.'")
    end
  end
end
