# frozen_string_literal: true

module Deprecool
  module Finders
    module Ruby
      module V4_0_0
        class JsonDumpLimit < Deprecool::Finder
          gem           :ruby
          deprecated_in '4.0.0'
          removed_in    '4.1.0'
          title         'Passing a positional limit argument to JSON.dump is deprecated'
          summary       'JSON.dump(obj, io, limit) accepted a nesting limit as a positional argument. ' \
                        'Parsing that argument is awful and costly, so it is now named _deprecated_limit ' \
                        'instead of fully removing because updating rdoc is costly.'
          suggestion    'Pass the :max_nesting option instead, e.g. JSON.dump(obj, io, max_nesting: 10)'
          reference     'https://github.com/ruby/json/commit/566bd7c108 ' \
                        'https://github.com/ruby/ruby/commit/d98d7978dc0dd777756ba737295d9cec482f84a3'
          effort        :low

          def on_call_node(node)
            # we only care if the call is JSON.dump
            return unless node.name == :dump
            return unless json_receiver?(node.receiver)

            # bare keyword options and blocks aren't positional arguments
            positional = positional_args_from(node.arguments)

            # :high because the receiver is JSON and the limit is only detected when it
            # can't be anything else (a non-nil, non-hash third argument or an integer in place of io)
            add_offense(node, confidence: :high) if passes_limit_arg?(positional)
          end

          private

          def json_receiver?(receiver)
            case receiver
            when Prism::ConstantReadNode then receiver.name == :JSON
            # ::JSON.dump
            when Prism::ConstantPathNode then receiver.parent.nil? && receiver.name == :JSON
            else false
            end
          end

          # follows the same steps JSON.dump uses to decide which argument is the limit
          def passes_limit_arg?(positional)
            # the positional param will dereference into all 3 variables only if
            # all three are actually passed.
            _obj, io, limit = positional

            # if a third argument is passed, but it's a {hash} or nil
            # then set the third arg to nil in case the second argument is being used
            # as the limit i.e. (JSON.dump(obj, 1, strict: true))
            limit = nil if limit.is_a?(Prism::HashNode) || limit.is_a?(Prism::NilNode)

            # in the case the third arg was nil or a hash/nil then check if the second arg
            # is an integer, this is similar to what the `dump` method does in ruby 4
            limit = io if limit.nil? && integer?(io)


            !limit.nil?
          end

          def integer?(node) = node.is_a?(Prism::IntegerNode)
        end
      end
    end
  end
end
