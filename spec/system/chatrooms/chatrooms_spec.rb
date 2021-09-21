require 'rails_helper'

RSpec.describe 'チャット', type: :system do
    let(:login_user) { create(:user) }
    let(:user) { create(:user) }

    it 'ユーザーの詳細ページに「メッセージボタン」が存在すること' do
        login_as login_user
        visit user_path(user)
        # メッセージボタンの確認、当該userとのチャットルームにつながる
        expect(page).to have_selector(:link_or_button, 'Message')
    end

    it '「メッセージ」ボタンを押すと当該ユーザーとのチャットルームに遷移すること' do
        login_as login_user
        visit user_path(user)
        click_on 'Message'
        expect(current_path).to eq chatroom_path(Chatroom.first)
    end

    it 'テキストを入力して投稿ボタンを押すとメッセージが投稿されること' do
        login_as login_user
        visit user_path(user)
        click_on 'Message'
        # メッセージを入力する
        fill_in 'message-form', with: 'hello world'
        # POSTボタンを押す
        click_on 'POST'
        # メッセージが画像に反映される
        expect(page).to have_content 'hello world'
    end

    it 'コメントの編集ボタンを押すとモダールが表示されコメントをの更新ができること', js: true do
        login_as login_user
        visit user_path(user)
        click_on 'Message'
        # メッセージを入力する
        fill_in 'message-form', with: 'hello world'
        # POSTボタンを押す
        click_on 'POST'
        # メッセージが画像に反映される
        expect(page).to have_content 'hello world'
        find(".edit-button").click
        within '#modal-container' do
            fill_in 'message-form', with: 'updated hello world'
            click_on 'EDIT'
        end
        expect(page).to have_content('updated hello world')
    end

    it 'コメントの削除ボタンを押すと確認アラートが出るとともに「OK」を押すとコメントが削除されて画面から消えること' do
        login_as login_user
        visit user_path(user)
        click_on 'Message'
        # メッセージを入力する
        fill_in 'message-form', with: 'hello world'
        # POSTボタンを押す
        click_on 'POST'
        # メッセージが画像に反映される
        expect(page).to have_content 'hello world'
        page.accept_confirm { find(".delete-button").click }
        expect(page).not_to have_content('hello world')
    end
end