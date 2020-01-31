module TenantDatabases
  app_name = Rails.application.class.module_parent.name.underscore
  INITIAL_DB_COUNT = ActiveRecord::Base.configurations.configs_for.size
  TENANT_SPEC_NAMES = [10101, 53791, 24680].map {|id| "#{app_name}_#{id}"}

  TENANT_SPEC_NAMES.each do |tenant_spec_name|
    tenant_config = ActiveRecord::Base.configurations.configs_for(spec_name: 'primary', env_name: Rails.env).config.deep_dup.tap do |h|
      h['database'] = h['database'].sub(app_name, tenant_spec_name)
    end
    ActiveRecord::Base.configurations.configurations \
      << ActiveRecord::DatabaseConfigurations::HashConfig.new(Rails.env, tenant_spec_name, tenant_config)
  end
end
