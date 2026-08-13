# frozen_string_literal: true

module Deprecool
  # Parses a source file with Prism and runs a set of finders against it in a
  # single AST traversal.
  class Scanner
    def initialize(finders)
      @finders = Array(finders)
    end

    def scan_file(path)
      scan_source(File.read(path), path)
    end

    # Returns an Array<Offense>. Files that fail to parse yield no offenses;
    # parse errors are surfaced separately via {#parse_errors}.
    def scan_source(source, path = '(source)')
      result = Prism.parse(source)
      return [] unless result.success?

      offenses  = []
      # each finder has the path, the whole source of the file, and the offenses list
      # so that they can build the offense warning themselves.
      # we might be able to refactor this to only pass the source because the path
      # and offenses are only needed for the add_offense method, not the actual
      # searching for an offense?
      instances = @finders.map { |finder| finder.new(path, source, offenses) }
      DispatchVisitor.new(instances).visit(result.value)
      offenses
    end

    # Combines the given Finder classes into one class by
    #  defining one method per Prism::Visitor hook (e.g. visit_call_node)
    #  based on all the given finders that define a method that matches that
    #  hook method name
    class DispatchVisitor < Prism::Visitor
      # finder_instances is the array passed to the Scanner.new class,
      # so this would be [Ruby::V4_0_0::ToSetArguments, ..]
      def initialize(finder_instances)
        super()

        dispatch = Hash.new { |hash, key| hash[key] = [] }
        finder_instances.each do |instance|
          # find the hooks and add the instances to the hash of hook methods
          # so { on_call_node: [ToSetArguments.new, ObjectSpaceId2ref.new,.. ], ... }
          instance.class.hook_methods.each { |hook| dispatch[hook] << instance }
        end

        dispatch.each do |hook, finders|
          # convert the instances' hooks to what prism::visitor expects
          # so finder classes must use this pattern to name the visit_node methods
          #
          # 'on_call_node'   => good
          # 'find_call_node' => bad
          visit_method = hook.to_s.sub(/\Aon_/, 'visit_').to_sym

          # define the prism::visitor hook to loop through each of the
          # related finders and call the name of the hook like so:
          #
          # def visit_call_node(node)
          #   [ToSetArguments.new, ObjectSpaceId2ref.new].each do |finder|
          #     finder.send("on_call_node", node)
          #   end
          #
          #   super(node)
          # end
          define_singleton_method(visit_method) do |node|
            finders.each { |finder| finder.send(hook, node) }
            super(node)
          end
        end
      end
    end
  end
end
