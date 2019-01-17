if Rails.env.development? || Rails.env.test?

  class SwitchPointLoggerEnhancement < Arproxy::Base
    def execute(sql, name = nil)
      begin
        database_config = self.proxy_chain.connection.pool.spec.config
        if database_config.present? && database_config[:switch_point].present?
          switch_point = database_config[:switch_point]
          name = "#{name} [#{switch_point[:name]}][#{switch_point[:mode]}]"
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

