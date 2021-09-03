FactoryBot.define do
  factory :post do
    body { Faker::Lorem.sentence }
    # carrierwaveが画像をアップロードしデータ保存
    images { [File.open("#{Rails.root}/spec/fixtures/fixture.png")] }
    user
  end
end