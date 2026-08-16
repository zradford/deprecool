# frozen_string_literal: true

module Deprecool
  module Finders
    module Rails
      module V8_2_0
        class InsertUpdateDeleteBinds < Deprecool::Finder
          gem           :rails
          deprecated_in '8.2.0'
          removed_in    '9.0.0'
          title         'Binds being bassed to Insert Update Delete is deprecated'
          summary       ' Now that `Arel.sql(sql_with_placeholders, *binds)` wraps SQL and its binds' \
                        'together as an `Arel::Nodes::BoundSqlLiteral`, just like ' \
                        '`Model.where("... = ?", value)`, the separate positional is no longer needed'
          suggestion    'Old: `connection.insert("INSERT INTO topics (title) VALUES (?)", nil, nil, ["hello"])` ' \
                        'New: `connection.insert(Arel.sql("INSERT INTO topics (title) VALUES (?)", "hello"))`'
          reference     'Original Commit: https://github.com/rails/rails/commit/2dca5457ab2097626481fdbec233ea56d3fb9ee3'
          effort        :low

          def on_call_node(node)
            return unless %i[insert update delete].include?(node.name)
            return unless arguments = unwrap_arguments(node.arguments)
            return unless arguments.length > 1

            confidence = confidence_from_arguments(arguments)
            return if confidence == :none

            add_offense(node, confidence: confidence)
          end

          private

          def confidence_from_arguments(arguments)
            first = arguments[0]

            # if first argument is string node that starts with "INSERT" "UPDATE" "DELETE" then :high
            # if first argument is a variable then :low confidence
            # it it's a Prism::CallNode, and not a variable call, then I don't know what it is here,
            # maybe it's like 'connection.update(generate_sql(some_arg), ["name"])' and if you are doing that
            # then good luck?
            if first.is_a?(Prism::CallNode)
              return :low if first.variable_call? # can't tell what's stored in the variable, https://docs.ruby-lang.org/en/master/Prism/CallNode.html#method-i-variable_call-3F
              :none
            elsif %w[INSERT UPDATE DELETE].include?(first.unescaped[..5].upcase)
              :high
            else
              :none
            end
          end
        end
      end
    end
  end
end
