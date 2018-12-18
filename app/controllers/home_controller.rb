class HomeController < ApplicationController

  def index
    redirect_to animals_path
  end

end
