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
FactoryBot.define do
  factory :contract do
    plan { nil }
    user { nil }
  end
end
