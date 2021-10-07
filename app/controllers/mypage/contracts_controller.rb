class Mypage::ContractsController < Mypage::BaseController
    before_action :require_creditcards

    def create
        plan = Plan.find_by!(code: params[:code])
        ActiveRecord::Base.transaction do
            current_user.subscript!(plan)
        end
        redirect_to mypage_plans_path, success: "#{ plan.name }を契約しました"
    rescue Payjp::PayjpError => e
        redirect_to mypage_plans_path, danger: e.message
    end

    def require_creditcards
        redirect_to new_mypage_creditcard_path, danger: 'クレジットカードを登録してください' if current_user.customer_id.blank?
    end
end
