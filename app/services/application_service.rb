class ApplicationService

  attr_accessor :params

  def initialize(user, params = {})
    @user, @params = user, params.dup
  end
end
