module PayjpCustomer
    extend ActiveSupport::Concern
    
    included do
        has_many :contracts, dependent: :restrict_with_error
        scope :subscription_to_be_updated, lambda {
            joins(contracts: :payments).joins('LEFT OUTER JOIN contract_cancellations ON contracts.id = contract_cancellations.contract_id')
                                    .where(contracts: { id: Contract.group(:user_id).select('max(id)') }) # Userごとの最新Contractの抜出し
                                    .where(contract_cancellations: { id: nil })
                                    .where(payments: { id: Payment.group(:contract_id).select('max(id)') }) # Contractごとの最新Paymentの抜出し
                                    .where('payments.current_period_end < ?', Time.current)
    }   end

    # 当該プランを契約し、支払う
    def subscript!(plan)
        contract = contracts.create!(plan: plan)
        pay!
        contract
    end

    # 契約をもとにした支払い処理とpaymentsレコードの作成
    def pay!
        charge = charge!(latest_contract.plan.price)
        latest_contract.pay!(charge)
    end

    # 最新の契約
    def latest_contract
        contracts.last
    end

    # 解約する、最新のcontractに対してcontract_cancellationレコードを付加する
    def stop_subscript!(reason: :by_user_canceled)
        latest_contract.cancel!(reason: reason)
    end

    # 当該プランを契約中であり、かつキャンセルしているか
    def about_to_cancel?(plan)
        subscripting_to?(plan) &&
            latest_contract.contract_cancellation.present?
    end

    # プラン問わず契約中か、最新契約の最終支払いが期間内か
    def subscripting?
        latest_contract.present? &&
        latest_contract.payments.last.current_period_end >= Time.current.to_date
    end

    # 当該プランが契約中か
    def subscripting_to?(plan)
        subscripting? &&
            latest_contract.plan.code == plan.code
    end

    # ベーシックプランが契約中か
    def subscripting_basic_plan?
        subscripting_to?(Plan.find_by!(code: '0001'))
    end
    
    # プレミアムプランが契約中か
    def subscripting_premium_plan?
        subscripting_to?(Plan.find_by!(code: '0002'))
    end

    def cannot_message?
        subscripting_basic_plan? && messages.where(created_at: latest_contract.current_period_start...latest_contract.current_period_end).count >= 20 || !subscripting_premium_plan? && !subscripting_basic_plan? && messages.count >= 10
    end

    # userモデルとの連携準備
    def register_creditcard!(token:)
        customer = add_customer!(token: token)
        #Payjpで登録したインスタンスidをuserモデルに反映、customerの抜出しで使用
        # テストではcustomerがmockにあたる
        update!(customer_id: customer.id)
    end

    #Payjpのcustomerの登録
    def add_customer!(token:)
        Payjp::Customer.create(card: token, email: email, metadata: { name: username })
    end

    #Payjpのcustomerの抜出し
    def customer
        @customer ||= Payjp::Customer.retrieve(customer_id)
    end

    #Payjpのcustomerよりカードを取得
    def default_card
        @default_card ||= customer.cards.retrieve(customer.default_card)
    end

    def change_default_card!(token:)
        old_card = default_card
        customer.cards.create(
            card: token,
            default: true
        )
        old_card.delete
    end

    private

        # payjpでの支払い処理,customer_idは連携済(L43)
        def charge!(amount)
            Payjp::Charge.create(currency: 'jpy',
                                    amount: amount,
                                    customer: customer_id)
        end
end