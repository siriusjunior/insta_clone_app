class Mypage::PaymentsController < Mypage::BaseController
  def index
    @payments = Payment.includes(contract: :user).where(users: { id: current_user.id }).order(created_at: :desc)
  end
end
