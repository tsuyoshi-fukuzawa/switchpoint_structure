class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  private
  def with_readonly
    ApplicationRecord.with_readonly { yield }
  end

  def with_readonly_cat
    ApplicationRecordCat.with_readonly { yield }
  end
end
