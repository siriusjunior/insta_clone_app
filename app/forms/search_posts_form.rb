class SearchPostsForm
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :body, :string
    attribute :comment_body, :string
    attribute :username, :string

    def search
        if body.present? || comment_body.present? || username.present? then
            scope = Post.distinct
        end
        scope = splited_bodies.map { |splited_body| scope.body_contain(splited_body) }.inject{ |result, scp| result.or(scp) } if body.present?
        scope = scope.comment_body_contain(comment_body) if comment_body.present?
        scope = scope.username_contain(username) if username.present?
        scope
    end

    private

        def splited_bodies
            # 検索語を空白ごとに区切って配列を形成
            body.strip.split(/[[:blank:]]+/)
        end
end