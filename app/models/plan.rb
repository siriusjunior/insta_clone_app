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
class Plan < ApplicationRecord
    validates :code, presence: true
    validates :name, presence: true
    validates :price, presence: true
    validates :interval, presence: true
    enum interval: { month: 1, year: 2 }

    def period_start
        time_current
    end

    def period_end
        time_current + 1.send(interval) - 1.day
    end

    private
    
        def time_current
            @time_current = Time.current
        end
end
