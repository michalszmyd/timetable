class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  around_action :use_user_locale

  helper_method :current_user

  def authenticate_admin!
    authenticate_user!
    return head(:forbidden) unless current_user.admin?
  end

  def use_user_locale(&block)
    I18n.with_locale(current_user.try(:lang), &block)
  end

  def authenticate_admin_or_manager_or_leader!
    authenticate_user!
    return head(:forbidden) unless current_user.admin? || current_user.manager? || current_user.leader?
  end

  private

  def current_user
    @current_user ||= begin
      return unless session['warden.user.user.key'] || request.headers['token']

      if session['warden.user.user.key']
        User.find session['warden.user.user.key'][0][0]
      else
        User.find JwtService.decode(token: request.headers['token'])['id']
      end
    end
  end
end
