# frozen_string_literal: true

module Deprecool
  module Finders
    module Rails
      module V7_1_0
        class SerializerPositionalClassArgument < Deprecool::Finder
          gem           :rails
          deprecated_in '7.1.0'
          removed_in    '7.2.0'
          title         '"serialize" method singature change'
          summary       'The serialize method in active_record no longer accepts a class as a positional argument ' \
                        'the method signature now requires custom serializer classes to be ' \
                        'passed with the `coder:` keword argument.'
          suggestion    'add the keyword `coder:` to the method signature, i.e serialize :attr, coder: CustomJsonEncoder'
          reference     'https://github.com/rails/rails/pull/47463'
          effort        :low

          # TODO: add check for the `serialize` method being called by a Rails model?,
          # like add a on_constant_path_node for ActiveRecord::Base
          # or a class_node with a superclass of ActiveRecord::Base
          # def on_class_node node
          #   node
          # end

          def on_call_node(node)
            return unless node.name == :serialize

            arguments_array = unwrap_arguments(node.arguments)
            return unless arguments_array && arguments_array[1]

            add_offense(node, confidence: :high) if arguments_array[1].is_a?(Prism::ConstantReadNode)
          end
        end
      end
    end
  end
end
