# frozen_string_literal: true

module Deprecool
  module Finders
    module Ruby
      module V4_0_0
        class ObjectSpaceId2ref < Deprecool::Finder
          gem           :ruby
          deprecated_in '4.0.0'
          removed_in    '4.1.0'
          title         'Using ObjectSpace._id2ref is deprecated'
          summary       'The object_id identifier does not guarantee that the id won\'t be reused ' \
                        'after the original has been garbage collected, ' \
                        'therefore _id2ref is unsafe and unreliable, and per matz: ' \
                        '"Reviving arbitrary objects from integer IDs was never a sound API"'
          suggestion    'Do not rely on this method'
          reference     'original issue: https://bugs.ruby-lang.org/issues/15408' \
                        'deprecated: https://github.com/ruby/ruby/pull/13157' \
                        'removed: https://bugs.ruby-lang.org/issues/22135'
          effort        :medium

          def on_call_node(node)
            return unless node.name == :_id2ref

            # The method name '_id2ref' is quite unique, and
            # the use case for this is specific enough that
            # I don't think we need much more than this
            # I'm open to be wrong though, maybe lots of people are subclassing
            # ObjectSpace or defining '_id2ref' on custom classes
            confidence = node.receiver.name == :ObjectSpace ? :high : :none



            add_offense node, confidence: confidence
          end
        end
      end
    end
  end
end
