class ErrorsController < ApplicationController
  skip_before_action :check_user_login, :get_error_events

  def not_found
    render '404', status: 404
  end

  def unauthorized
    render 'unauthorized', status: 401
  end
end
