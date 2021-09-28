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
require 'rails_helper'

RSpec.describe Plan, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
