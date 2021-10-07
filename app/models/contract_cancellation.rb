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
class ContractCancellation < ApplicationRecord
  belongs_to :contract
  enum reason: { by_user_canceled: 1, by_payment_failed: 2 }
end
