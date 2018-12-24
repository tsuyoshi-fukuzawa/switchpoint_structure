SwitchPoint.configure do |config|

  main_databases = {
    readonly: :"#{Rails.env}_readonly",
    writable: :"#{Rails.env}"
  }
  another_databases = {
    readonly: :"#{Rails.env}_another_readonly",
    writable: :"#{Rails.env}_another"
  }
  if Rails.env.test?
    main_databases.delete(:readonly)
    another_databases.delete(:readonly)
  end
  config.define_switch_point :main, main_databases
  config.define_switch_point :another, another_databases
end