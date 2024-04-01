class InternalApi::ApplicationController < ApplicationController
  rescue_from StarhubError do |e|
    log_error e.message, e.backtrace
    handled_ssh = render_ssh_error e
    handled_user_edit = render_user_edit_error e
    render_git = handled_ssh || handled_user_edit
    render json: {message: "Git服务器报错"}, status: 500 unless render_git
  end

  rescue_from SensitiveContentError do |e|
    log_error e.message, e.backtrace
    render json: {message: "监测到敏感内容！！！"}, status: 500
  end

  private

  def render_ssh_error e
    message = JSON.parse(e.message)["msg"]
    if message.include?("key,error:Invalid")
      render json: {message: I18n.t('ssh_key.invalid')}, status: 500
      return true
    elsif message.include?("key,error")
      render json: {message: I18n.t('ssh_key.non_deploy')}, status: 500
      return true
    end
    false
  end

  def render_user_edit_error e
    message = JSON.parse(e.message)["msg"]
    if message.include?("user,error")
      render json: {message: I18n.t('user_edit.email')}, status: 500
      return true
    end
    false
  end
end
