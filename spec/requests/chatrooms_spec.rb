require 'rails_helper'

RSpec.describe "Chatrooms", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/chatrooms/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/chatrooms/show"
      expect(response).to have_http_status(:success)
    end
  end

end
