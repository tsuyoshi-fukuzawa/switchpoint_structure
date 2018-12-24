class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  use_switch_point :main
  SwitchPoint.writable!(:main)
end