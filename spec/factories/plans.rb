# == Schema Information
#
# Table name: plans
#
#  id         :bigint           not null, primary key
#  code       :string(255)      not null
#  interval   :integer          not null
#  name       :string(255)      not null
#  price      :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :plan do
    code { "MyString" }
    name { "MyString" }
    price { 1 }
    interval { 1 }

    trait :basic_plan do
      code { '0001' }
      name { 'ベーシックプラン' }
      price { 480 }
      interval { 1 }
    end

    trait :premium_plan do
      code { '0002' }
      name { 'プレミアムプラン' }
      price { 980 }
      interval { 1 }
    end
  end
end
