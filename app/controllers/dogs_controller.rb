class DogsController < ApplicationController
  around_action :with_readonly, except: []

  def index
  end

end
