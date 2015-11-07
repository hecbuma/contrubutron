class User < ActiveRecord::Base

  def self.sanitize_user_params(auth)
    user_params = {
      provider: auth.provider,
      uid: auth.uid,
      name: auth.info.name,
      email: auth.info.email,
      username: auth.info.nickname,
      avatar: auth.extra.raw_info.avatar_url
    }
    parameters = ActionController::Parameters.new(user_params)
    parameters.permit( :provider,:uid,:name,:email,:username,:avatar)
  end

  def self.with_omniauth(auth)
    first_or_create sanitize_user_params(auth)
  end



end
