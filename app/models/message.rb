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
class Message < ApplicationRecord
  belongs_to :user
  belongs_to :chatroom

  validates :body, presence: true, length: { maximum: 230 }
  validate :number_of_times

  # 回数制限
  def number_of_times
    # プレミアムプランを契約中であれば処理中断
    return if user.subscripting_premium_plan?

    # ベーシックプランを契約中であり、期間中のメッセージ数が指定数未満であれば処理中断、達した時点でerrors.add発火
    return if user.subscripting_basic_plan? &&
              user.messages
                  .where(created_at: user.latest_contract.current_period_start...user.latest_contract.current_period_end)
                  .size < 20
    # プランが未契約であり、期間中のメッセージ数が指定数未満であれば処理中断、達した時点でerrors.add発火
    return if user.messages.size < 11

    errors.add(:base, '今月のメッセージ可能回数をオーバーしました。')
  end
end
