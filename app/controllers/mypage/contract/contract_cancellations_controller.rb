class Mypage::Contract::ContractCancellationsController < Mypage::BaseController
    def create
        contract = current_user.stop_subscript!
        redirect_to mypage_plans_path, success: "#{contract.plan.name}を解約しました"
    end
end
