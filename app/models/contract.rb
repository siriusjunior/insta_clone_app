# == Schema Information
#
# Table name: contracts
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  plan_id    :bigint
#  user_id    :bigint
#
# Indexes
#
#  index_contracts_on_plan_id  (plan_id)
#  index_contracts_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (plan_id => plans.id)
#  fk_rails_...  (user_id => users.id)
#
class Contract < ApplicationRecord
  belongs_to :plan
  belongs_to :user
  has_many :payments, dependent: :restrict_with_error
  has_one :contract_cancellation, dependent: :restrict_with_error
  
  def current_period_start
    payments.last.current_period_start
  end

  def current_period_end
    payments.last.current_period_end
  end

  # payjpの支払いインスタンスを受ける、payレコード(支払い履歴)の作成
  def pay!(charge)
    payments.create!(charge_id: charge.id, current_period_start: plan.period_start, current_period_end: plan.period_end)
  end

  # 任意のcontractに対してcontract_cancellationレコードを付加する
  def cancel!(reason)
    create_contract_cancellation!(reason: reason)
  end
end
