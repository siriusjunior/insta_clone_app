class Mypage::Contract::ContractCancellationsController < Mypage::BaseController
    def create
        contract_cancellation = current_user.stop_subscript!
        redirect_to mypage_plans_path, success: "#{contract_cancellation.contract.plan.name}を解約しました"
    end
end
