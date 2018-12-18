# lib/switch_point_logger_enhancement.rb
class SwitchPointLoggerEnhancement < Arproxy::Base
  def execute(sql, name = nil)
    begin
      database_config = self.proxy_chain.connection.instance_variable_get(:@config)
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
