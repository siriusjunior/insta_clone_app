class PostsController < ApplicationController
    before_action :require_login, only: %i[new create edit update destroy]
    before_action :logged_in_user, only: %i[index show]
    
    def index
        @posts = if current_user
                    current_user.feed.includes(:user).page(params[:page]).order(created_at: :desc)
                else
                    Post.all.includes(:user).page(params[:page]).order(created_at: :desc)
                end
        @users = User.recent(5)
    end
    
    def new
        @post = Post.new
    end
    
    def create
        @post = current_user.posts.build(post_params)
        if @post.save
            redirect_to posts_path, success: '投稿しました'
        else
            flash.now[:danger] = '投稿に失敗しました'
            render :new
        end
    end

    def edit
        @post = current_user.posts.find(params[:id])
    end

    def update
        @post = current_user.posts.find(params[:id])
        if @post.update(post_params)
            redirect_to posts_path, success: '投稿を更新しました'
        else
            flash.now[:danger] = '投稿の更新に失敗しました'
            render :edit
        end
    end

    def show
        @post = Post.find(params[:id])
        @comments = @post.comments.includes(:user).order(created_at: :asc)
        @comment = Comment.new
    end 

    def destroy
        @post = current_user.posts.find(params[:id])
        @post.destroy!
        redirect_to posts_path, success: '投稿を削除しました'
    end

    def search
        if !@search_form.search.nil?
            @posts = @search_form.search.includes(:user).page(params[:page])
        else
            flash.now[:warning] = "検索語を入力してください"
            render :search
        end
    end

    private

        def post_params
            params.require(:post).permit(:body, images: [])
        end
        
        def logged_in_user
            unless logged_in?
                store_location
            end
        end
end
