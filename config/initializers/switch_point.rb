SwitchPoint.configure do |config|

  main_databases = {
    readonly: :"#{Rails.env}_readonly",
    writable: :"#{Rails.env}"
  }
  another_databases = {
    readonly: :"#{Rails.env}_another_readonly",
    writable: :"#{Rails.env}_another"
  }

  config.define_switch_point :main, main_databases
  config.define_switch_point :another, another_databases
end

# テスト環境は、SwitchPointを無効化する。
# コンフィグをreadonlyのみにしても、writableのみにしても、
# use_transactional_fixtures = falseの環境では、DatabaseCleanerが正常に動作しない

if Rails.env.test?
  module SwitchPoint
    module Model
      module MonkeyPatch
        def connection
          super
        end
      end
    end
  end
end