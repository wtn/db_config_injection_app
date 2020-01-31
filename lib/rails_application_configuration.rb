require 'rails/application/configuration'

class Rails::Application::Configuration
  def database_configuration
    ActiveRecord::Base.configurations.present? \
      and return ActiveRecord::Base.configurations

    path = paths['config/database'].existent.first
    yaml = Pathname.new(path) if path

    config = if yaml && yaml.exist?
      require 'yaml'
      require 'erb'
      loaded_yaml = YAML.load(ERB.new(yaml.read).result) || {}
      shared = loaded_yaml.delete('shared')
      if shared
        loaded_yaml.each do |_k, values|
          values.reverse_merge!(shared)
        end
      end
      Hash.new(shared).merge(loaded_yaml)
    elsif ENV['DATABASE_URL']
      {}
    else
      raise "Could not load database configuration. No such file - #{paths['config/database'].instance_variable_get(:@paths)}"
    end

    config
  rescue Psych::SyntaxError => e
    raise "YAML syntax error occurred while parsing #{paths["config/database"].first}. " \
          'Please note that YAML must be consistently indented using spaces. Tabs are not allowed. ' \
          "Error: #{e.message}"
  rescue => e
    raise e, "Cannot load database configuration:\n#{e.message}", e.backtrace
  end
end
