# == Schema Information
#
# Table name: posts
#
#  id         :bigint           not null, primary key
#  body       :text(65535)      not null
#  images     :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint
#
# Indexes
#
#  index_posts_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
require 'rails_helper'

RSpec.describe Post, type: :model do
  describe 'バリデーション' do
    it '画像は必須であること' do
      post = build(:post, images: nil)
      post.valid?
      expect(post.errors[:images]).to include("can't be blank")
    end

    it '本文は必須であること' do
      post = build(:post, body: nil)
      post.valid?
      expect(post.errors[:body]).to include("can't be blank")
    end

    it '本文は最大1000文字であること' do
      post = build(:post, body: "a" * 1001)
      post.valid?
      expect(post.errors[:body]).to include("is too long (maximum is 1000 characters)")
    end
  end

  describe 'スコープ' do
    let!(:user) { create(:user, username: 'user_a') }
    let!(:post) { create(:post, body: 'hello world', user_id: user.id) }
    before do
      user.comments.create(body: 'Lorem ipsum', post_id: post.id)
    end
    context '単一検索' do
      describe 'body_contain' do
        # 語句を含む投稿の検索
        subject { Post.body_contain('hello') }
        it { is_expected.to include post }
      end
      describe 'comment_body_contain' do
        # コメント語句を含む投稿の検索
        subject { Post.comment_body_contain('Lorem') }
        it { is_expected.to include post }
      end
      describe 'username_contain' do
        # ユーザー名を含む投稿の検索
        subject { Post.username_contain('user_a') }
        it { is_expected.to include post }
      end
    end
    context '複合検索' do
      describe '全てのフォームで複合検索' do
        subject { Post.body_contain('hello') && Post.comment_body_contain('Lorem') && Post.username_contain('user_a') }
        it { is_expected.to include post }
      end
    end
  end
    
    describe 'dependent: :destroy' do
      let(:user_a) { create(:user) }
    let(:user_b) { create(:user) }
    let(:post) { create(:post, user: user_b) }
      it '投稿が削除されたらコメントも削除されること' do
        user_a.comments.create(body: 'Lorem ipsum', post_id: post.id)
        expect { post.destroy }.to change { Comment.count }.by(-1)
      end
      it '投稿が削除されたらいいねも削除されること' do
        user_a.like(post)
        expect { post.destroy }.to change { Like.count }.by(-1)
      end
      it '投稿が削除されたらコメント生成時のactivityも削除されること' do
        user_a.comments.create(body: 'Lorem ipsum', post_id: post.id)
        expect { post.destroy }.to change { Activity.count }.by(-1)
      end
  end
end
