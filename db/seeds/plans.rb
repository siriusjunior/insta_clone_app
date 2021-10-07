puts 'Start inserting seed "plans" ...'
Plan.create(
        code: '0001',
        name: 'ベーシックプラン',
        price: 480,
        interval: 1
) do |plan|
    puts "\"#{ plan.name }\" has created!"
end

Plan.create(
        code: '0002',
        name: 'プレミアムプラン',
        price: 980,
        interval: 1
) do |plan|
    puts "\"#{ plan.name }\" has created!"
end