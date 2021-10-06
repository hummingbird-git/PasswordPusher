# frozen_string_literal: true

desc 'Run through and expire passwords.'
task :daily_expiration, [:limit] => :environment do |_, args|
  unless args.key?(:limit)
    puts 'Please specify the limit size. e.g. rails daily_expiration[100]'
    exit
  end

  counter = 0
  expiration_count = 0
  limit = args[:limit].to_i

  Password.where(expired: false)
          .limit(limit)
          .find_each do |push|
    counter += 1

    push.validate!
    if push.expired
      puts "#{counter}: Push #{push.url_token} created on #{push.created_at.to_s(:long)} has expired."
      expiration_count += 1
    else
      puts "#{counter}: Push #{push.url_token} created on #{push.created_at.to_s(:long)} is still active."
    end
  end

  puts "#{expiration_count} total pushes expired."

  puts ''
  puts 'All done.  Bye!  (っ＾▿＾)۶🍸🌟🍺٩(˘◡˘ )'
  puts ''
end

desc 'Delete old, expired and anonymous pushes.'
task :delete_old_expired_and_anonymous, [:limit] => :environment do |_, args|
  unless args.key?(:limit)
    puts 'Please specify the limit size. e.g. rails delete_old_expired_and_anonymous[100]'
    exit
  end

  limit = args[:limit].to_i
  counter = 0

  Password.includes(:views)
          .where(expired: true)
          .where(user_id: nil)
          .limit(limit)
          .find_each do |push|
    counter += 1
    puts "#{counter}: Deleting old, expired and anonymous push #{push.url_token} created on " +
         "#{push.created_at.to_s(:long)} with #{push.views.size} views " +
         "and user_id #{push.user_id}."
    push.destroy
  end

  puts "#{counter} total pushes deleted."

  puts ''
  puts 'All done.  Bye!  (っ＾▿＾)۶🍸🌟🍺٩(˘◡˘ )'
  puts ''
end