class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    @language = language
  end
end
