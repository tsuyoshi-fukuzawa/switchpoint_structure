class CatsController < ApplicationController
  around_action :with_readonly_another, except: []

  def index
  end

end
