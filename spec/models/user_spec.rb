# == Schema Information
#
# Table name: users
#
#  id                      :bigint           not null, primary key
#  avatar                  :string(255)
#  crypted_password        :string(255)
#  email                   :string(255)      not null
#  notification_on_comment :boolean          default(TRUE)
#  notification_on_follow  :boolean          default(TRUE)
#  notification_on_like    :boolean          default(TRUE)
#  salt                    :string(255)
#  username                :string(255)      not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#
require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'バリデーション' do
    it 'ユーザー名は必須であること' do
      user = build(:user, username: nil)
      user.valid?
      expect(user.errors[:username]).to include("can't be blank")
    end

    it 'ユーザー名は一意であること' do
      user = create(:user)
      same_name_user = build(:user, username: user.username)
      same_name_user.valid?
      expect(same_name_user.errors[:username]).to include("has already been taken")
    end

    it 'メールアドレスは必須であること' do
      user = build(:user, email: nil)
      user.valid?
      expect(user.errors[:email]).to include("can't be blank")
    end

    it 'メールアドレスは一意であること' do
      user = create(:user)
      same_email_user = build(:user, email: user.email)
      same_email_user.valid?
      expect(same_email_user.errors[:email]).to include("has already been taken")
    end
  end

  describe "スコープ" do
    let!(:user_a) { create(:user, created_at: Time.zone.now) }
    let!(:user_b) { create(:user, created_at: Time.zone.now) }
    let!(:user_c) { create(:user, created_at: 1.hour.ago) }
    let!(:user_d) { create(:user, created_at: 1.hour.ago) }
    before do
      10.times do |i|
        create(:user, created_at: 10.minutes.ago)
      end
    end
    describe 'recent' do
      context '最新のユーザーが含まれること' do
        subject { User.recent(5) }
        it { is_expected.to include user_a, user_b}
      end
      context '最新ではないユーザーが含まれないこと' do
        subject { User.recent(5) }
        it { is_expected.to_not include user_c, user_d }
      end
    end
  end

  describe "インスタンスメソッド" do
    let(:user_a) { create(:user) }
    let(:user_b) { create(:user) }
    let(:user_c) { create(:user) }
    let(:post_by_user_a) { create(:post, user: user_a) }
    let(:post_by_user_b) { create(:post, user: user_b) }
    let(:post_by_user_c) { create(:post, user: user_c) }
    describe 'own?' do
      context '自分のオブジェクトの場合' do
        it 'trueを返す' do
          expect(user_a.own?(post_by_user_a)).to be true
        end
      end
      context '自分以外のオブジェクトの場合' do
        it 'falseを返す' do
          expect(user_a.own?(post_by_user_b)).to be false
        end
      end
    end

    describe 'like' do
      it 'いいねできること' do
        expect { user_a.like(post_by_user_b) }.to change { Like.count }.by(1)
      end
    end

    describe 'unlike' do
      it 'いいねを解除できること' do
        user_a.like(post_by_user_b)
        expect { user_a.unlike(post_by_user_b) }.to change { Like.count }.by(-1)
      end
    end

    describe 'follow' do
      it 'フォローできること' do
        expect { user_a.follow(user_b) }.to change { Relationship.count }.by(1)
      end
    end

    describe 'unfollow' do
      it 'フォロー解除できること、解除の確認' do
        user_a.follow(user_b)
        expect { user_a.unfollow(user_b) }.to change { Relationship.count }.by(-1)
        expect(user_a.following?(user_b)).to be false
      end
    end

    describe 'following?' do
      context 'フォローしている場合' do
        it 'trueを返す' do
          user_a.follow(user_b)
          expect(user_a.following?(user_b)).to be true
        end
      end
      context 'フォローしていない場合' do
        it 'falseを返す' do
          expect(user_a.following?(user_b)).to be false
        end
      end
    end
    
    describe 'feed' do
      before do
        user_a.follow(user_b)
      end
      subject { user_a.feed }
      it { is_expected.to include post_by_user_a }
      it { is_expected.to include post_by_user_b }
      it { is_expected.not_to include post_by_user_c }
    end
  end

  describe 'dependent: :destroy' do
    let(:user_a) { create(:user) }
    let(:user_b) { create(:user) }
    let(:post) { create(:post, user: user_b) }
      it 'ユーザーが削除されたら投稿も削除されること' do
        create(:post, body: 'Lorem ipsum', user: user_a)
        expect { user_a.destroy }.to change { Post.count }.by(-1)
      end
      it 'ユーザーが削除されたらコメントも削除されること' do
        user_a.comments.create(body: 'Lorem ipsum', post_id: post.id)
        expect { user_a.destroy }.to change { Comment.count }.by(-1)
      end
      it 'ユーザーが削除されたらいいねも削除されること' do
        user_a.like(post)
        expect { user_a.destroy }.to change { Like.count }.by(-1)
      end
      it 'ユーザーが削除されたらrelationshipも削除されること' do
        user_a.follow(user_b)
        expect { user_a.destroy }.to change { Relationship.count }.by(-1)
      end
      describe 'activityの存在性' do
        context 'userのコンテキストでactivityが生成されること' do
          it 'コメントされた投稿のユーザーに対してactivityが生成されること' do
            expect { user_a.comments.create(body: 'Lorem ipsum', post_id: post.id) }.to change { Activity.count }.by(1)
          end
          it 'いいねされた投稿のユーザーに対してactivityが生成されること' do
            expect { user_a.like(post) }.to change { Activity.count }.by(1)
          end
          it 'フォローされたらactivityが生成されること' do
            expect { user_a.follow(user_b) }.to change { Activity.count }.by(1)
          end
        end
        context 'userのコンテキストでactivityが削除されること' do
          it 'フォローされたユーザーが削除されたらそのactivityも削除されること' do
            user_b.follow(user_a)
            expect { user_a.destroy }.to change { Activity.count }.by(-1)
          end
        end
      end
  end
end
