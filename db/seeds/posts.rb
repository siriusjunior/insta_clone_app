puts 'Start inserting seed "posts"...'
User.limit(10).each do |user|
    post = user.posts.create(body: Faker::Lorem.sentence(word_count: 3, supplemental: false, random_words_to_add: 4), remote_images_urls: %w[https://picsum.photos/350/350/?random https://picsum.photos/350/350/?random])
    puts "post#{post.id} has created!"    
end

