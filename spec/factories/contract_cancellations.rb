# == Schema Information
#
# Table name: contract_cancellations
#
#  id          :bigint           not null, primary key
#  reason      :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  contract_id :bigint
#
# Indexes
#
#  index_contract_cancellations_on_contract_id  (contract_id)
#
# Foreign Keys
#
#  fk_rails_...  (contract_id => contracts.id)
#
FactoryBot.define do
  factory :contract_cancellation do
    contract { nil }
    reason { 1 }
  end
end
