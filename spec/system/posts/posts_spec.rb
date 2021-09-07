require 'rails_helper'

RSpec.describe '投稿', type: :system do
    # posts/index
    describe '投稿一覧' do
        let!(:user) { create(:user) }
        let!(:post_1_by_others) { create(:post) }
        let!(:post_2_by_others) { create(:post) }
        let!(:post_by_user) { create(:post, user: user) }

        context 'ログインしている場合' do
            before do
                login_as user
                user.follow(post_1_by_others.user)
            end
            it 'フォロワーと自分の投稿だけが表示されること' do
                visit posts_path
                expect(page).to have_content post_1_by_others.body
                expect(page).to have_content post_by_user.body
                expect(page).not_to have_content post_2_by_others.body
            end
        end

        context 'ログインしていない場合' do
            it 'すべての投稿が表示されること' do
                visit posts_path
                expect(page).to have_content post_1_by_others.body
                expect(page).to have_content post_2_by_others.body
                expect(page).to have_content post_by_user.body
            end
        end
    end
    # posts/create
    describe 'ポスト投稿' do
        it '投稿できること' do
            login
            visit new_post_path
            within '#posts_form' do
                attach_file 'Images', Rails.root.join('spec', 'fixtures', 'fixture.png')
                fill_in 'Body', with: 'Lorem ipsum'
                click_button 'Create Post'
            end
            expect(page).to have_content '投稿しました'
            expect(page).to have_content 'Lorem ipsum'
        end
    end
    # posts/edit
    describe 'ポスト更新' do
        let!(:user) { create(:user) }
        let!(:post_1_by_others) { create(:post) }
        let!(:post_by_user) { create(:post, user: user) }
        before do
            login_as user
        end
        it '自分の投稿に編集ボタンが表示されること' do
            visit posts_path
            within "#post-#{post_by_user.id}" do
                expect(page).to have_css '.edit-button'
            end
        end
        it '他人の投稿には編集ボタンが表示されないこと' do
            user.follow(post_1_by_others.user)
            visit posts_path
            within "#post-#{post_1_by_others.id}" do
                expect(page).not_to have_css '.edit-button'
            end
        end
        # posts/update
        it '投稿が更新できること' do
            visit edit_post_path(post_by_user)
            within "#posts_form" do
                attach_file 'Images', Rails.root.join('spec', 'fixtures', 'fixture.png')
                fill_in 'Body', with: 'This is the edited post!'
                click_button 'Update Post'
            end
            expect(page).to have_content '投稿を更新しました'
            expect(page).to have_content 'This is the edited post!'
        end
    end
    # posts/delete
    describe 'ポスト削除' do
        let!(:user) { create(:user) }
        let!(:post_1_by_others) { create(:post) }
        let!(:post_by_user) { create(:post, user: user) }
        before do
            login_as user
        end
        it '自分の投稿に削除ボタンが表示されること' do
            visit posts_path
            within "#post-#{post_by_user.id}" do
                expect(page).to have_css '.delete-button'
            end
        end
        it '他人の投稿には削除ボタンが表示されないこと' do
            user.follow(post_1_by_others.user)
            visit posts_path
            within "#post-#{post_1_by_others.id}" do
                expect(page).not_to have_css '.delete-button'
            end
        end
        it '投稿が削除できること' do
            visit posts_path
            within "#post-#{post_by_user.id}" do
                page.accept_confirm { find('.delete-button').click }
            end
            expect(page).to have_content '投稿を削除しました'
            expect(page).not_to have_content post_by_user.body
        end
    end
    # posts/show
    describe 'ポスト詳細' do
        let(:user) { create(:user) }
        let(:post_by_user) { create(:post, user: user) }

        before do
            login_as user
        end

        it '投稿の詳細画面が閲覧できること' do
            visit post_path(post_by_user)
            expect(current_path).to eq post_path(post_by_user)
        end
    end

    describe 'ポスト検索' do
        context '検索で投稿がヒットする場合' do
                let(:user1) { create(:user, username: "michael") }
                let(:user2) { create(:user, username: "lana") }
                let(:user3) { create(:user, username: "archer") }
                let!(:post1_by_user1) { create(:post, body: "This post really ties the room together.", user: user1)}
                let!(:post2_by_user2) { create(:post, body: "Oh, is that what you want? Because that's how you get ants!", user: user2)}
                let!(:post3_by_user3) { create(:post, body: "I'm sorry. Your words made sense, but your sarcastic tone did not.", user: user3)}
                before do
                    user2.comments.create(body: "Does it really tie together??", post: post1_by_user1)
                end
            it '単一検索で該当の投稿がヒットすること' do
                visit posts_path
                find_by_id('q_body').set("room")
                find_by_id('q_comment_body').set("")
                find_by_id('q_username').set("")
                click_button 'Search'
                expect(page).to have_content "1 result for room"
            end
            it '複合検索で該当の投稿がヒットすること' do
                visit posts_path
                find_by_id('q_body').set("together")
                find_by_id('q_comment_body').set("tie")
                find_by_id('q_username').set("michael")
                click_button 'Search'
                expect(page).to have_content "1 result for together tie michael"
            end
        end
        context '検索で投稿がヒットしない場合' do
            it '検索によって該当する記事がないこと' do
                visit posts_path
                find_by_id('q_body').set("Lorem")
                find_by_id('q_comment_body').set("ipsum")
                find_by_id('q_username').set("dolor")
                click_button 'Search'
                expect(page).to have_content "0 results for Lorem ipsum dolor"
            end
            it '何も入力しないで検索した時にエラーメッセージが表示されること' do
                visit posts_path
                find_by_id('q_body').set("")
                find_by_id('q_comment_body').set("")
                find_by_id('q_username').set("")
                click_button 'Search'
                expect(page).to have_content "検索語を入力してください"
            end
        end
    end

    describe 'いいね' do
        let!(:user) { create(:user) }
        let!(:post) { create(:post) }
        before do
            login_as user
            user.follow(post.user)
        end
        it 'いいねができること' do
            visit posts_path
            expect {
                within "#post-#{post.id}" do
                    find('.like-button').click
                    expect(page).to have_css '.unlike-button'
                end
            }.to change(user.like_posts, :count).by(1)
        end
        it 'いいねが取り消せること' do
            user.like(post)
            visit posts_path
            expect {
                within "#post-#{post.id}" do
                    find('.unlike-button').click
                    expect(page).to have_css '.like-button'
                end
            }.to change(user.like_posts, :count).by(-1)
        end
    end
end