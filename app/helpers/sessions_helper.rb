module SessionsHelper
  def log_in user
    cookies[:login_identity] = user.login_identity
    cookies[:current_user] = user.name
    cookies[:admin_user] = 'true' if user.admin?

    user.update_column('session_ip', request.remote_ip)
  end

  def current_user
    login_identity = cookies[:login_identity].presence
    @current_user ||= login_identity && User.find_by_login_identity(login_identity)
  end

  def logged_in?
    current_user.present?
  end

  def logged_in_other_system?
    cookies[:idToken].present?
  end

  def user_roles
    current_user.roles.join(',')
  end

  def logout
    # unset current_user
    cookies.delete :login_identity
    cookies.delete :current_user
    cookies.delete :admin_user

    # unset user token
    cookies.delete :user_token
    cookies.delete :can_change_username

    # unset odic cookies
    cookies.delete :oidcUuid
    cookies.delete :idToken
    cookies.delete :userinfos

    # unset starhub synced
    cookies.delete :user_synced
  end

  def is_on_premise?
    on_premise_from_env = ENV.fetch('ON_PREMISE', nil)

    system_config = SystemConfig.first
    feature_flags = (system_config.feature_flags rescue {}) || {}
    on_premise = on_premise_from_env || feature_flags['on_premise']

    on_premise.to_s == 'true'
  end
end
