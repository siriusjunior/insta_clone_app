puts 'Start inserting seed "users" ...'
45.times do
    user = User.create(
        email: Faker::Internet.unique.email,
        username: Faker::Name.name,
        password: 'password',
        password_confirmation: 'password'
    )
    puts "\"#{user.username}\" has created!"
end