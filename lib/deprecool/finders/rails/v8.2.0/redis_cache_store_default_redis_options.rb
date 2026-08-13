# frozen_string_literal: true

module Deprecool
  module Finders
    module Rails
      module V8_2_0
        class RedisCacheStoreDefaultRedisOptions < Deprecool::Finder
          gem           :rails
          deprecated_in '8.2.0'
          removed_in    '9.0.0'
          title         'RedisCacheStore::DEFAULT_REDIS_OPTIONS is deprecated'
          summary       'The `redis-client` implementation no longer reads this constant.'
          suggestion    'Pass timeout options to RedisCacheStore or a configured RedisClient instead.'
          reference     'https://github.com/rails/rails/pull/58191 '
          effort        :low

          # constant_read is any constant, like `Foo`
          def on_constant_read_node(node)
            return unless node.name == :DEFAULT_REDIS_OPTIONS

            add_offense(node, confidence: :high)
          end

          # a constant_path is like: ActiveSupport::Cache::RedisCacheStore::DEFAULT_REDIS_OPTIONS
          def on_constant_path_node(node)
            return unless node.name == :DEFAULT_REDIS_OPTIONS

            add_offense(node, confidence: :high)
          end
        end
      end
    end
  end
end
