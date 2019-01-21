SwitchPoint.configure do |config|

  # https://github.com/eagletmt/switch_point
  # If :writable key is omitted, it uses ActiveRecord::Base.connection as writable one.
  # writableの設定を省略して、readonlyだけにすると、DatabaseCleanerでもトランザクションをロールバックできるようになる
  if Rails.env.test?
    main_databases    = { readonly: :"#{Rails.env}" }
    another_databases = main_databases

    # master/slave設定を施したDBを用意し、readonlyをテストする場合。
    # main_databases = {
    #   readonly: :"#{Rails.env}_readonly",
    #   writable: :"#{Rails.env}"
    # }
    # another_databases = {
    #   readonly: :"#{Rails.env}_another_readonly",
    #   writable: :"#{Rails.env}_another"
    # }
  else
    main_databases = {
      readonly: :"#{Rails.env}_readonly",
      writable: :"#{Rails.env}"
    }
    another_databases = {
      readonly: :"#{Rails.env}_another_readonly",
      writable: :"#{Rails.env}_another"
    }
  end

  config.define_switch_point :main, main_databases
  config.define_switch_point :another, another_databases
end