class CollectionsController < ApplicationController
  before_action :check_user_info_integrity

  def index
  end

  def new
  end

  def show
    @collections_id = params[:collections_id]
    @path = params[:path]
  end

end
