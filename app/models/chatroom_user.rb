# == Schema Information
#
# Table name: chatroom_users
#
#  id           :bigint           not null, primary key
#  datetime     :datetime
#  last_read_at :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  chatroom_id  :bigint
#  user_id      :bigint
#
# Indexes
#
#  index_chatroom_users_on_chatroom_id              (chatroom_id)
#  index_chatroom_users_on_user_id                  (user_id)
#  index_chatroom_users_on_user_id_and_chatroom_id  (user_id,chatroom_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (chatroom_id => chatrooms.id)
#  fk_rails_...  (user_id => users.id)
#
class ChatroomUser < ApplicationRecord
  belongs_to :user
  belongs_to :chatroom
end
