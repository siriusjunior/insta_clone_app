require 'rails_helper'

RSpec.describe 'チャット', type: :system do
    let(:login_user) { create(:user) }
    let(:user) { create(:user) }
    # payjp_cutomer.rbのPlan.find_byでエラーが起きるため先にplanを構成
    let!(:basic_plan) { create(:plan, :basic_plan) }
    let!(:premium_plan) { create(:plan, :premium_plan) }
    before do
        charge_mock = double(:charge_mock)
            allow(charge_mock).to receive(:id).and_return(SecureRandom.uuid)
            allow(Payjp::Charge).to receive(:create).and_return(charge_mock)
    end

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

    it 'コメントの編集ボタンを押すとモダールが表示されコメントの更新ができること', js: true do
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

    describe '投稿数の制限' do
        let!(:non_subscriber) { create(:user) }
        let!(:basic_plan_user) { create(:user) }
        let!(:premium_plan_user) { create(:user) }
        let!(:invited) { create(:user) }
        before do
            basic_plan_user.subscript!(basic_plan)
            premium_plan_user.subscript!(premium_plan)
        end

        context '未契約ユーザーの場合' do
            before do
                # チャットルームの構築、ボタン無効化直前9件までのメッセージの出力
                login_as(non_subscriber)
                visit user_path(invited)
                click_on 'Message'
                @chatroom = Chatroom.chatroom_for_users([non_subscriber] + [invited])
                messages = create_list(:message, 9, user: non_subscriber, chatroom: @chatroom)
            end
            it 'メッセージの10件目を投稿したら、ボタンが無効化されること', js: true do
                # メッセージを入力する
                fill_in 'message-form', with: 'Lorem ipsum dolor sit amet'
                # POSTボタンを押す
                click_on 'POST'
                # メッセージが反映される
                expect(page).to have_content 'Lorem ipsum dolor sit amet'
                expect(page).to have_css('.disabled')
            end
            it 'メッセージの11件目を投稿しようとすると、alertが表示されること', js: true do
                fill_in 'message-form', with: 'Lorem ipsum dolor sit amet'
                click_on 'POST'
                fill_in 'message-form', with: 'Bibendum ut tristique et'
                click_on 'POST'
                # メッセージが反映されないとともに、alertが反映される
                expect(page).not_to have_content 'Bibendum ut tristique et'
                expect(page).to have_css('.validates')
                expect(page).to have_css('.disabled')
            end
            it '上限エラーがでた状態でメッセージを1件削除し、空き枠を作るとalertが消えるとともに、ボタンが再度有効化され投稿ができること', js: true do
                fill_in 'message-form', with: 'Lorem ipsum dolor sit amet'
                click_on 'POST'
                fill_in 'message-form', with: 'Bibendum ut tristique et'
                click_on 'POST'
                # 上限到達によるalert表示、ボタン無効化
                expect(page).to have_css('.validates')
                expect(page).to have_css('.disabled')
                # メッセージを削除するとalertが消えて、ボタンが再度有効化
                page.accept_confirm { find(".delete-button").click }
                expect(page).not_to have_css('.validates')
                expect(page).not_to have_css('.disabled')
                fill_in 'message-form', with: 'Bibendum ut tristique et'
                click_on 'POST'
                expect(page).to have_content 'Bibendum ut tristique et'
            end
        end
        context 'ベーシックプラン契約ユーザーの場合' do
            before do
                # チャットルームの構築、ボタン無効化直前19件までのメッセージの出力
                login_as(basic_plan_user)
                visit user_path(invited)
                click_on 'Message'
                @chatroom = Chatroom.chatroom_for_users([basic_plan_user] + [invited])
                messages = create_list(:message, 19, user: basic_plan_user, chatroom: @chatroom)
            end
            it 'メッセージの20件目を投稿したら、ボタンが無効化されること', js: true do
                # メッセージを入力する
                fill_in 'message-form', with: 'Lorem ipsum dolor sit amet'
                # POSTボタンを押す
                click_on 'POST'
                # メッセージが反映される
                expect(page).to have_content 'Lorem ipsum dolor sit amet'
                expect(page).to have_css('.disabled')
            end
            it 'メッセージの21件目を投稿しようとすると、alertが表示されること', js: true do
                fill_in 'message-form', with: 'Lorem ipsum dolor sit amet'
                click_on 'POST'
                fill_in 'message-form', with: 'Bibendum ut tristique et'
                click_on 'POST'
                # メッセージが反映されないとともに、alertが反映される
                expect(page).not_to have_content 'Bibendum ut tristique et'
                expect(page).to have_css('.validates')
            end
            it '上限エラーがでた状態でメッセージを1件削除し、空き枠を作るとalertが消えるとともに、ボタンが再度有効化され投稿ができること', js: true do
                fill_in 'message-form', with: 'Lorem ipsum dolor sit amet'
                click_on 'POST'
                fill_in 'message-form', with: 'Bibendum ut tristique et'
                click_on 'POST'
                # 上限到達によるalert表示、ボタン無効化
                expect(page).to have_css('.validates')
                expect(page).to have_css('.disabled')
                # メッセージを削除するとalertが消えて、ボタンが再度有効化
                page.accept_confirm { find(".delete-button").click }
                expect(page).not_to have_css('.validates')
                expect(page).not_to have_css('.disabled')
                fill_in 'message-form', with: 'Bibendum ut tristique et'
                click_on 'POST'
                expect(page).to have_content 'Bibendum ut tristique et'
            end
        end
        context 'プレミアムプラン契約ユーザーの場合' do
            before do
                # チャットルームの構築、メッセージの出力
                login_as(premium_plan_user)
                visit user_path(invited)
                click_on 'Message'
                @chatroom = Chatroom.chatroom_for_users([premium_plan_user] + [invited])
                messages = create_list(:message, 30, user: premium_plan_user, chatroom: @chatroom)
            end
            it 'メッセージの31件目を投稿ても、alertが表示されず、ボタンも無効化されていないこと' do
                fill_in 'message-form', with: 'Lorem ipsum dolor sit amet'
                click_on 'POST'
                # メッセージが反映されているともに、alertが表示されず、ボタンも無効化されていない
                expect(page).to have_content 'Lorem ipsum dolor sit amet'
                expect(page).not_to have_css('.validates')
                expect(page).not_to have_css('.disabled')
            end
        end
    end
    describe '文字数の制限' do
        it '文字数制限を超えたメッセージを投稿するとalertが表示されること', js: true do
            login_as login_user
            visit user_path(user)
            click_on 'Message'
            fill_in 'message-form', with: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Eget magna fermentum iaculis eu non diam phasellus vestibulum lorem. Metus vulputate eu scelerisque felis. Suscipit tellus mauris a diam maecenas sed enim.'
            click_on 'POST'
            expect(page).to have_css('.validates')
        end
        it 'メッセージの文字数が230文字以内であれば、再度投稿ができるとともにalertが消えること', js: true do
            login_as login_user
            visit user_path(user)
            click_on 'Message'
            fill_in 'message-form', with: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Eget magna fermentum iaculis eu non diam phasellus vestibulum lorem. Metus vulputate eu scelerisque felis. Suscipit tellus mauris a diam maecenas sed enim.'
            click_on 'POST'
            # alertが表示される
            expect(page).to have_css('.validates')
            # 再度、制限以内の文字数でメッセージを投稿
            fill_in 'message-form', with: 'Lorem ipsum dolor sit amet'
            click_on 'POST'
            # メッセージが反映されるとともに、alertが消える
            expect(page).to have_content 'Lorem ipsum dolor sit amet'
            expect(page).not_to have_css('.validates')
        end
    end
end