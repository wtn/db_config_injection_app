module TenantDatabases
  APP_NAME = Rails.application.class.module_parent.name.underscore
  INITIAL_DB_COUNT = ActiveRecord::Base.configurations.configs_for.size
  TENANT_SPEC_NAMES = [10101, 53791, 24680].map {|id| "#{APP_NAME}_#{id}"}
  DESIRED_DB_COUNT = INITIAL_DB_COUNT + TENANT_SPEC_NAMES.size

  class << self
    def inject_tenant_db_configs
      configurations = ActiveRecord::Base.configurations.configurations
      warn('already injected') if DESIRED_DB_COUNT == ActiveRecord::Base.configurations.configs_for.size
      TENANT_SPEC_NAMES.each do |tenant_spec_name|
        tenant_config = ActiveRecord::Base.configurations.configs_for(spec_name: 'primary', env_name: Rails.env).config.deep_dup.tap do |h|
          h['database'] = h['database'].sub(APP_NAME, tenant_spec_name)
        end
        configurations << ActiveRecord::DatabaseConfigurations::HashConfig.new(Rails.env, tenant_spec_name, tenant_config)
      end
      ActiveRecord::Base.configurations = ActiveRecord::DatabaseConfigurations.new configurations
    end
  end
end

TenantDatabases.inject_tenant_db_configs
