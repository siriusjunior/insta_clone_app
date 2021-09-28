class Mypage::PlansController < Mypage::BaseController
  def index
    @plans = Plan.all
  end
end
