# frozen_string_literal: true

module Deprecool
  module Finders
    module Rails
      module V8_2_0
        class ActiveRecordRelationUniq < Deprecool::Finder
          gem           :rails
          deprecated_in '8.2.0'
          removed_in    '9.0.0'
          title         'ActiveRecord::Relation#uniq! is deprecated'
          summary       'Since Rails 6.1 you have been able to use Relation#uniq! to remove duplicate fields ' \
                        'on a query. This was originally because grouping by the same field twice resulted in ' \
                        'duplicated results. Since Rails 7.0 though, this has been de-duplicated automatically ' \
                        'and this method has been a near no-op'
          suggestion    'Remove the call to #uniq!, don\'t just find and replace though ' \
                        'because `uniq!` is also an Array method. Make sure you have tests ' \
                        'backing these changes, as always.'
          reference     'uniq! added in: https://github.com/rails/rails/pull/39358, ' \
                        'uniq! deprecated in: https://github.com/rails/rails/pull/58525'
          effort        :low

          def on_call_node(node)
            return unless node.name == :uniq!
            return unless args = unwrap_arguments(node.arguments)

            # neither Array.uniq! or ActiveRecord's uniq! take
            # more than one argument,
            #
            # Array only accepts an optional block
            # AR receives a string or symbol
            return unless args.count == 1

            confidence = :none
            confidence = :high if [Prism::SymbolNode, Prism::StringNode].include?(args.first.class)

            # if uniq! is called on a variable like:
            # some_query.uniq!(:somehting)
            # then it's still probably a deprecation, but we are a little less sure
            confidence = :low if receiver_is_bare_variable(node.receiver)


            add_offense(node, confidence:)
          end

          def receiver_is_bare_variable(receiver)
            receiver.is_a?(Prism::CallNode) && receiver.variable_call?
          end
        end
      end
    end
  end
end
