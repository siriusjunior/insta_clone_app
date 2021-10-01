# Rails.rootを使用するために必要
require File.expand_path(File.dirname(__FILE__) + "/environment" )

rails_env = ENV['RAILS_ENV'] || :development

# cron実行の環境変数をセット
set :environment, rails_env

# cronのログ出力ファイルを作成
set :output, "Rails.root"/log/cron.log"

every 1.day, at: '03:00 am' do
    rake 'subscription:update'
end