class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.authenticate(params[:email], params[:password])
    if user
      update_token(user)
      if params[:remember_me]
        # cookies.permanent[:auth_token] = user.auth_token # 20 years cookies
        cookies[:auth_token] = { value: user.auth_token, expires: 1.week.from_now }
      else
        cookies[:auth_token] = { value: user.auth_token, expires: 1.minute.from_now }
      end
      redirect_to root_url, notice: 'Logged in!'
    else
      flash.now.alert = 'Invalid email or password'
      render 'new'
    end
  end

  def destroy
    cookies.delete(:auth_token) #if co
    redirect_to root_url, notice: 'Logged out!'
  end

  def update_token(user)
    user.update_mode = 'skip_password_validation'
    begin
      user.auth_token = SecureRandom.urlsafe_base64
    end while User.exists?(auth_token: user.auth_token)
    user.save!
  end
end
