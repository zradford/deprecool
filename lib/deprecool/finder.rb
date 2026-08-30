# frozen_string_literal: true

module Deprecool
  # Base class for every deprecation finder.
  #
  # A finder is responsible for detecting a single deprecation.
  # Subclasses of Finder describe the deprecation with the class-level DSL and
  # then implement one or more Prism visit hooks (e.g. `on_call_node`).
  #
  # A Scanner then follows the AST a single time and dispatches each node to the
  # finders that have a relevant method, which call `add_offense` when a match is found.
  #
  # Example child class
  #
  #   class MyFinder < Deprecool::Finder
  #     gem           :ruby
  #     deprecated_in '4.0.0'
  #     removed_in    '4.1.0'
  #     title         'some_method will be removed'
  #     summary       'some_method was causing a problem and will be removed soon'
  #     suggestion    'remove some_method'
  #     reference     'https://link_to_pr_or_relevant_info'
  #     effort        :medium
  #
  #     def on_call_node(node)
  #       add_offense(node, confidence: :high) if node.name == :some_method
  #     end
  #   end
  class Finder
    include PrismHelpers

    class << self
      # automatically include GemHelpers into the classes for the Gem
      def inherited(subclass)
        gem_name = subclass.name.split("::")[2]
        return if gem_name == "Ruby"

        subclass.send(:include, const_get("#{gem_name}Helpers"))
      end

      # defines class methods that set instance variables
      %i[gem title summary suggestion reference].each do |attribute|
        define_method(attribute) do |value = (getter = true)|
          return instance_variable_get("@#{attribute}") if getter

          instance_variable_set("@#{attribute}", value)
        end
      end

      # Stored as a Gem::Version so it can be compared against the app's
      # detected version.
      %i[deprecated_in removed_in].each do |attribute|
        define_method(attribute) do |value = (getter = true)|
          return instance_variable_get("@#{attribute}") if getter

          instance_variable_set("@#{attribute}", Gem::Version.new(value))
        end
      end

      # how much work is this to fix?
      # low    => Rails::v7_1_0::SerializerPositionalClassArgument just changes a method signature to have kwarg
      # medium => Ruby::v4_0_0::ObjectSpaceId2ref to keep same functionality you need to remove the method
      #           and minor refactor to use WeakMap or something
      # high   => you're gonna need to make some changes to preserve the same functionality
      def effort(value = (getter = true))
        return @effort if getter

        values = %i[low medium high]

        raise "Please use a standardized effort value, i.e #{values}" unless values.include?(value)

        @effort = value
      end

      def affected_version_range
        [deprecated_in, removed_in]
      end

      # return just the class name without all the modules, for displaying
      def classname
        name.split('::').last
      end

      # this is used internally to sort Finders
      # so we might as well not sort the part thats repeated for every finder
      def id
        name.delete_prefix('Deprecool::Finders::')
      end

      # This is what the Scanner class calls to see what methods are
      # defined on the child classes,
      #
      # child classes should define the methods with 'on' in place of 'visit'
      # so that we can differentiate them from the default implementation
      # provided by Prism::Visitor
      #
      # (see https://docs.ruby-lang.org/en/master/Prism/Visitor.html for the full list of
      # Prism compatible methods)
      # some examples of prism compatible 'on_node' methods for a finder:
      # Prism::VisitClassNode  => on_class_node
      # Prism::VisitDefNode    => on_def_node
      # Prism::VisitModuleNode => on_module_node
      def hook_methods
        instance_methods(false).grep(/\Aon_\w+_node\z/)
      end
    end

    attr_reader :file_path, :source

    def initialize(file_path, source, offenses)
      @file_path = file_path
      @source    = source # the AST from Prism.parse
      @offenses  = offenses
    end

    Offense = Struct.new(:file_path, :line, :column, :end_line, :end_column,
                         :id, :title, :summary, :suggestion, :reference,
                         :effort, :confidence, :gem, :deprecated_in,
                         :removed_in, :snippet, :source_line) do
      def location
        "#{file_path}:#{line}:#{column + 1}"
      end
    end

    private

    # Record a deprecation at the given node's location.
    #
    # confidence - [:high, :low, :none], returns early if :none
    #              to save each finder the effort of checking for :none
    def add_offense(node, confidence: :high)
      return if confidence == :none

      location = node.location # a Prism::Location

      @offenses << Offense.new(
        file_path:     file_path,
        line:          location.start_line,
        column:        location.start_column,
        end_line:      location.end_line,
        end_column:    location.end_column,
        id:            self.class.id,
        title:         self.class.title,
        summary:       self.class.summary,
        suggestion:    self.class.suggestion,
        reference:     self.class.reference,
        effort:        self.class.effort,
        confidence:    confidence,
        gem:           self.class.gem,
        deprecated_in: self.class.deprecated_in.to_s,
        removed_in:    self.class.removed_in.to_s,
        snippet:       location.slice,
        source_line:   source.lines[location.start_line - 1]&.chomp
      )
    end
  end
end
