class ApplicationRecordAnother < ActiveRecord::Base
  self.abstract_class = true
  use_switch_point :another
  SwitchPoint.writable!(:another)
end