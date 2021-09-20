class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      auto_login(@user)
      redirect_to login_path, success: 'ユーザーを作成しました'
    else
      flash.now[:danger] = 'ユーザーの作成に失敗しました'
      render :new
    end
  end

  def show
    @user = User.find(params[:id])
    # @chatroom_users =  [@user] + [current_user]
    # user_ids = @chatroom_users.map(&:id).sort # [3,5,7,9]
    # name = user_ids.join(':').to_s # "3:5:7:9"
    # @chatroom = @user.chatrooms.find_by(name: name)
  end

  def index
    @users = User.all.page(params[:page]).order(created_at: :desc)
  end

    private

    def user_params
      params.require(:user).permit(:email, :password, :password_confirmation, :username)
    end
end
