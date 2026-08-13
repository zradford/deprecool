# frozen_string_literal: true

# raise 'Comment this out if you want to see the actual deprecation warnings'

# This fixture contains deprecated lines of code
# to test the CLI on if you want
#
# If you have added lines to this then you need
# to:
# `gem uninstall deprecool`
# `gem build deprecool.gemspec`
# `gem install deprecool`
#
# then, after installing the gem, run
# `deprecool scan test/fixtures/script.rb`

#### Ruby 4.0.0 ####

[1, 2, 3].to_set(Hash)
my_variable.to_set(CustomSet)
ObjectSpace._id2ref('oops deprecated'.object_id)

module Enumerable
  def test_somethin
    [1,2,3].to_set(Hash)
  end
end

#### RAILS 8.2.0 ####

@connection.to_sql('SELECT 1', [])

ActiveSupport::Cache::RedisCacheStore::DEFAULT_REDIS_OPTIONS.to_h

default_redis_options = { hello: 'some_config' }
