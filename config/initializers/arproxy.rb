if Rails.env.development? || Rails.env.test?
  require 'switch_point_logger_enhancement'
  Arproxy.configure do |config|
    config.adapter = 'mysql2'
    config.use SwitchPointLoggerEnhancement
  end
  Arproxy.enable!
end

