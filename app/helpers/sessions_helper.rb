module SessionsHelper
    # アクセスしようとしたURLを覚えておく
    def store_location
        session[:return_to_url] = request.original_url if request.get?
    end
end