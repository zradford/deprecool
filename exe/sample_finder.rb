# frozen_string_literal: true

module Deprecool
  module Finders
    module GEM_NAME
      module V_E_R_S_I_O_N
        class YourDeprecation < Deprecool::Finder
          gem           :gem_name
          deprecated_in 'start v.e.r.s.i.o.n'
          removed_in    'end v.e.r.s.i.o.n'
          title         ''
          summary       ''
          reference     'Links to pr'
          effort        :low?

          # see https://docs.ruby-lang.org/en/master/Prism/Visitor.html#method-i-visit_class_node
          # for the list of methods Prism:Visitor will call,
          # but in a finder you swap 'visit' for 'on'
          #
          # so instead of 'visit_call_node'
          def on_call_node(node)
            return unless node.name == :some_method_name

            add_offense(node, confidence: :high_or_low)
          end
        end
      end
    end
  end
end
