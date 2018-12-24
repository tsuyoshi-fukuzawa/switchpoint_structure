class ApplicationRecordDog < ActiveRecord::Base
  self.abstract_class = true
  use_switch_point :dog
  SwitchPoint.writable!(:dog)
end