require 'rails_helper'

RSpec.describe "Mypage::Plans", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/mypage/plans/index"
      expect(response).to have_http_status(:success)
    end
  end

end
