# frozen_string_literal: true

module Deprecool
  module Finders
    module Ruby
      module V4_0_0
        class ToSetArguments < Deprecool::Finder
          gem           :ruby
          deprecated_in '4.0.0'
          removed_in    '4.1.0'
          title         'Passing arguments to #to_set is deprecated'
          summary       'Since Ruby 4.0, passing arguments to Set#to_set / Enumerable#to_set ' \
                        'is deprecated and will be removed.'
          suggestion    'Call #to_set with no arguments. If you were building a ' \
                        'Set subclass, construct it explicitly instead.'
          reference     'https://bugs.ruby-lang.org/issues/21390 https://github.com/ruby/ruby/pull/13489'
          effort        :low

          def on_call_node(node)
            return unless node.name == :to_set
            return unless node.arguments

            confidence = confidence_from_receiver_node(node.receiver)
            return if confidence == :none

            add_offense(node, confidence:)
          end

          private

          def confidence_from_receiver_node(receiver)
            case receiver
            # these nodes all represent Enumerables
            when Prism::ArrayNode, Prism::HashNode, Prism::RangeNode then :high
            # a plain `to_set(x)` call to the current scope's own
            # method. This is probably not Enumerable#to_set unless someone has
            # monkeypatched Enumerable and is using to_set with an argument, I guess
            when nil then :none
            when Prism::ConstantReadNode, Prism::ConstantPathNode
              # These nodes can constants like:
              # MY_DATA.to_set(arg) => likely an array, but can't be sure so :low
              # MyClass.to_set(arg) => has lowercase letters so it's a class method
              receiver&.name&.match?(/[a-z]/) ? :none : :low
            else
              # this branch is when the receiver is some
              # local var, instance variable, method chain, safe navigation, etc.
              # could even be an a custom object — we can't really tell.
              # but we do know enumerable methods like map, reduce, etc. so
              # we can be more confident about that
              return :high if Enumerable.method_defined?(receiver.name)

              :low
            end
          end
        end
      end
    end
  end
end

