# == Schema Information
#
# Table name: chatrooms
#
#  id         :bigint           not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Chatroom < ApplicationRecord
    has_many :chatroom_users, dependent: :destroy
    has_many :users, through: :chatroom_users
    has_many :messages, dependent: :destroy

    # インスタンス生成のクラスメソッド
    def self.chatroom_for_users(users)
        user_ids = users.map(&:id).sort # [3,5,7,9]
        name = user_ids.join(':').to_s # "3:5:7:9"
            unless (chatroom = find_by(name: name))
                chatroom = new(name: name)
                chatroom.users = users
                chatroom.save
            end
        chatroom
    end
    
    def users_excluding(user)
        users.reject { |u| u == user }
    end
end
