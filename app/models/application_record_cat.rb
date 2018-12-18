class ApplicationRecordCat < ActiveRecord::Base
  self.abstract_class = true
  use_switch_point :cat
  SwitchPoint.writable!(:cat)
end