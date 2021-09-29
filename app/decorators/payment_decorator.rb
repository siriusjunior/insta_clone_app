class PaymentDecorator < ApplicationDecorator
  delegate_all

  def contract_valid_period
    "#{ l object.current_period_start.to_date, format: '%Y/%m/%d'}~#{ l object.current_period_end.to_date, format: '%Y/%m/%d' }"
  end

end
