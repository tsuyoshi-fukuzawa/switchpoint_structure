if Rails.env.development? || Rails.env.test?

  class SwitchPointLoggerEnhancement < Arproxy::Base
    def execute(sql, name = nil)
      begin
        if self.proxy_chain.connection.pool.present?
          database_config = self.proxy_chain.connection.pool.spec.config
          if database_config.present? && database_config[:switch_point].present?
            name = "#{name} [#{database_config[:switch_point][:name]}][#{database_config[:switch_point][:mode]}]"
          end
        end
      rescue => e
        name = "#{name} [#{e}]"
      end
      super(sql, name)
    end
  end

  # require 'switch_point/switch_point_logger_enhancement'
  Arproxy.configure do |config|
    config.adapter = 'mysql2'
    config.use SwitchPointLoggerEnhancement
  end
  Arproxy.enable!
end

