class UserSessionsController < ApplicationController
  def new; end

  def create
    @user = login(params[:email], params[:password])
    if @user
      # ActionCableでユーザーを特定するために必要
      cookies.signed['user_id'] = current_user.id
      redirect_back_or_to root_path, success: "ログインに成功しました"
      # flash[:success] = "ログインに成功しました"
    else
      flash.now[:danger] = "ログインに失敗しました"
      render :new
    end
  end

  def destroy
    logout
    cookies.delete('user_id') if !cookies['user_id'].nil?
    redirect_to login_path, success: "ログアウトしました"
  end
end
