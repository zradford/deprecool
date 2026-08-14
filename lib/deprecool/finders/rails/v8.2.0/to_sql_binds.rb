# frozen_string_literal: true

module Deprecool
  module Finders
    module Rails
      module V8_2_0
        class ToSqlBinds < Deprecool::Finder
          gem           :rails
          deprecated_in '8.2.0'
          removed_in    '9.0.0'
          title         'Passing "binds" into "to_sql" is deprecated'
          summary       'Since Rails 5.2, bind parameters live on the Arel AST ' \
                        'to_sql_and_binds no longer uses binds for SQL construction, ' \
                        'and to_sql discards the output binds either way'
          suggestion    'Do not use the binds argument of the to_sql method'
          reference     'https://github.com/rails/rails/pull/58310'
          effort        :low

          def on_call_node(node)
            # to_sql is a method on an ActiveRecord::Base.connection
            # the first argument should be a string of sql
            # the second argument used to be an array of binds
            # == the second argument is now deprecated ==
            #
            # the name of the connection is likely to be connection, but that's unreliable
            # if a method called 'to_sql' is passed two arguments and the second is an
            # array that's probably good enough
            return unless node.name == :to_sql
            return unless arguments_are_length(node.arguments, 2)

            add_offense(node, confidence: :high)
          end
        end
      end
    end
  end
end
