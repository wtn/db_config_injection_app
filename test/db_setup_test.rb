require 'test_helper'

class DBSetupTest < ActiveSupport::TestCase
  self.test_order = :sorted

  test '1 extra configs set by initializer' do
    assert_equal TenantDatabases::DESIRED_DB_COUNT, configs_count
  end

  test '2 rake db tasks reset configs' do
    lost_configs_difference = -1 * TenantDatabases::TENANT_SPEC_NAMES.size

    assert_difference('configs_count', lost_configs_difference) do
      silence_stream($stdout) { Rake::Task['db:version'].invoke }
    end
  end

  test '3 restore extra configs' do
    TenantDatabases.inject_tenant_db_configs
    assert_equal TenantDatabases::DESIRED_DB_COUNT, configs_count
  end

  private

  def configs_count
    ActiveRecord::Base.configurations.configs_for.size
  end

  def silence_stream(stream)
    old_stream = stream.dup
    stream.reopen(RbConfig::CONFIG['host_os'] =~ /mswin|mingw/ ? 'NUL:' : '/dev/null')
    stream.sync = true
    yield
  ensure
    stream.reopen(old_stream)
    old_stream.close
  end
end
