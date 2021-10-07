class Mypage::CreditcardsController < Mypage::BaseController
  before_action :set_payjp_sk, only: %i[new create edit update]
  def new
    redirect_to edit_mypage_creditcard_path if current_user.customer_id.present?
  end

  def create
    current_user.register_creditcard!(token: params['payjp-token'])
    redirect_to edit_mypage_creditcard_path, success: 'クレジットカードを登録しました'
  rescue Payjp::PayjpError => e
    redirect_to new_mypage_creditcard_path, danger: e.message
  end

  def edit
    @card = current_user.default_card
  rescue Payjp::PayjpError => e
    redirect_to edit_mypage_creditcard_path, danger: e.message
  end

  def update
    # tokenはeditビューで新しく生成
    current_user.change_default_card!(token: params['payjp-token'])
    redirect_to edit_mypage_creditcard_path, success: 'クレジットカードを変更しました'
  rescue Payjp::PayjpError => e
    redirect_to edit_mypage_creditcard_path, danger: e.message
  end

  private

    # クレカ処理でskも求められた
    def set_payjp_sk
      Payjp.api_key = Settings.payjp.dig(:sk)
    end

end
