SwitchPoint.configure do |config|

  dog_databases = {
    readonly: :"#{Rails.env}_readonly",
    writable: :"#{Rails.env}"
  }
  cat_databases = {
    readonly: :"#{Rails.env}_other_readonly",
    writable: :"#{Rails.env}_other"
  }
  if Rails.env.test?
    dog_databases.delete(:readonly)
    cat_databases.delete(:readonly)
  end
  config.define_switch_point :dog, dog_databases
  config.define_switch_point :cat, cat_databases
end