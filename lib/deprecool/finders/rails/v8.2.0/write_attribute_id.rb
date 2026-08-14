# frozen_string_literal: true

module Deprecool
  module Finders
    module Rails
      module V8_2_0
        class WriteAttributeId < Deprecool::Finder
          gem           :rails
          deprecated_in '8.2.0'
          removed_in    '9.0.0'
          title         'Using "write_attribute" for the primary key is deprecated'
          summary       'Just like Rails 7.1\'s deprecation of calling "read_attribute(:id)", '\
                        '"write_attribute(:id)" is now deprecated and will be removed in the next version of Rails. ' \
                        'making :id refer only to the id column, not the primary key.'
          suggestion    'Use "#id=" on a model whose primary key is not named "id"'
          reference     'Original Rails Commit: https://github.com/rails/rails/commit/1a90632bbe62dae2626de7a058bc18c29f77aea6'
          effort        :low

          def on_call_node(node)
            return unless node.name == :write_attribute
            return unless arguments_are_length(node.arguments, 2)
            return unless arguments_contain(node.arguments, "id", position: 0)

            add_offense(node, confidence: :high)
          end
        end
      end
    end
  end
end
