# == Schema Information
#
# Table name: payments
#
#  id                   :bigint           not null, primary key
#  current_period_start :date             not null
#  current_period_end   :date             not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  charge_id            :string(255)
#  contract_id          :bigint
#
# Indexes
#
#  index_payments_on_contract_id  (contract_id)
#
# Foreign Keys
#
#  fk_rails_...  (contract_id => contracts.id)
#
class Payment < ApplicationRecord
  belongs_to :contract
  validates :current_period_start, presence: true
  validates :current_period_end, presence: true
  validates :charge_id, presence: true
end
