require 'rails_helper'

RSpec.describe 'ユーザー', type: :system do
    # users/new
    describe 'ユーザー登録' do
        context '入力情報が正しい場合' do
            it 'ユーザーが登録できること' do
                visit new_user_path
                fill_in 'Username', with: 'Foobar'
                fill_in 'Email', with: 'foobar@example.com'
                fill_in 'Password', with: 'password'
                fill_in 'Password confirmation', with: 'password'
                click_button 'Submit'
                expect(current_path).to eq login_path
                expect(page).to have_content 'ユーザーを作成しました'
            end
        end
        context '入力情報に誤りがある場合' do
            it 'ユーザー登録に失敗すること' do
                visit new_user_path
                fill_in 'Username', with: ''
                fill_in 'Email', with: ''
                fill_in 'Password', with: ''
                fill_in 'Password confirmation', with: ''
                click_button 'Submit'
                expect(page).to have_content "Username can't be blank"
                expect(page).to have_content "Email can't be blank"
                expect(page).to have_content "Password is too short (minimum is 3 characters)"
                expect(page).to have_content "Password confirmation can't be blank"
            end
        end
    end

    # relationships/create
    describe 'フォロー' do
        let!(:login_user) { create(:user) }
        let!(:other_user) { create(:user) }

        before do
            login_as login_user
        end
        it 'フォローができること' do
            visit posts_path
            expect {
                within "#follow-area-#{other_user.id}" do
                    click_link 'Follow'
                    expect(page).to have_content 'UNFOLLOW'
                end
            }.to change(login_user.following, :count).by(1)
        end
        it 'フォローが外せること' do
            login_user.follow(other_user)
            visit posts_path
            expect {
                within "#follow-area-#{other_user.id}" do
                    click_link 'Unfollow'
                    expect(page).to have_content 'FOLLOW'
                end
            }.to change(login_user.following, :count).by(-1)
        end

    end
end