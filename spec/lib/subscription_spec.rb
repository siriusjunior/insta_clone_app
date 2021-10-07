require 'rake_helper'

describe 'subscription:create' do
    subject(:task) { Rake.application['subscription:update'] }
    let(:users) { create_list(:user, 2) }
    let(:basic_plan) { create(:plan, :basic_plan) }
    before do
        charge_mock = double(:charge_mock)
        allow(charge_mock).to receive(:id).and_return(SecureRandom.uuid)
        allow(Payjp::Charge).to receive(:create).and_return(charge_mock)

        users.each { |user| user.subscript!(basic_plan) }

        allow(User).to receive(:subscription_to_be_updated).and_return(users)
        allow(users.sample).to receive(:pay!).and_raise(Payjp::PayjpError)
    end

    it 'サブスクの更新、キャンセルが正常に行われること' do
        expect {
            task.invoke
        }.to change{ ContractCancellation.by_payment_failed.count}.by(1).and change { Payment.count }.by(1)
    end
end