require 'test_helper'

class DBSetupTest < ActiveSupport::TestCase
  include TenantDatabases

  test 'injected configurations loaded' do
    assert_equal INITIAL_DB_COUNT + TENANT_SPEC_NAMES.size, ActiveRecord::Base.configurations.configs_for.size
  end
end
