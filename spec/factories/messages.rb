# == Schema Information
#
# Table name: messages
#
#  id          :bigint           not null, primary key
#  body        :text(65535)      not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  chatroom_id :bigint
#  user_id     :bigint
#
# Indexes
#
#  index_messages_on_chatroom_id  (chatroom_id)
#  index_messages_on_user_id      (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (chatroom_id => chatrooms.id)
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :message do
    user { nil }
    chatroom { nil }
    body { Faker::Lorem.sentence(word_count: 3, supplemental: false, random_words_to_add: 4) }
  end
end
