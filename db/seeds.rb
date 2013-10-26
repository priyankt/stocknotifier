if Padrino.env != :test
    email     = shell.ask "Which email do you want use for logging into admin?"
    password  = shell.ask "Tell me the password to use:"

    shell.say ""

    account = Account.create(:email => email, :name => "Foo", :surname => "Bar", :password => password, :password_confirmation => password, :role => "admin")

    if account.valid?
      shell.say "================================================================="
      shell.say "Account has been successfully created, now you can login with:"
      shell.say "================================================================="
      shell.say "   email: #{email}"
      shell.say "   password: #{password}"
      shell.say "================================================================="
    else
      shell.say "Sorry but some thing went wrong!"
      shell.say ""
      account.errors.full_messages.each { |m| shell.say "   - #{m}" }
    end

    shell.say ""
end


# Create test publisher
salt = BCrypt::Engine.generate_salt
publisher = Publisher.new(
    :email => "test@test.com",
    :passwd => BCrypt::Engine.hash_secret("test", salt),
    :salt => salt,
    :name => "Test",
    :address => "Bibvewadi, Pune",
    :phone => "9887675443",
    :website => "http://www.test.com",
    :desc => "Test publisher",
    :occupation => "Stock Broker",
    :city => "Pune"
    )

if publisher.valid?
    publisher.save
    puts "=> Created test user with email - test@test.com & password - test"
else
    puts "=> Errors:\n"
    publisher.errors.each do |e|
        puts e
    end
end

# Create test subscriber1
salt = BCrypt::Engine.generate_salt
subscriber1 = Subscriber.new(
    :email => "sub1@test.com",
    :passwd => BCrypt::Engine.hash_secret("sub1", salt),
    :salt => salt,
    :name => "Subscriber 1",
    :phone => "02024906787",
    :occupation => "Software Engineer",
    :city => "Mumbai"
    )
testPublisher = Publisher.first(:email => "test@test.com")
subscriber1.publisher = testPublisher
if subscriber1.valid?
    subscriber1.save
    puts "=> Created sub1 user with email - sub1@test.com & password - sub1"
else
    puts "=> Errors:\n"
    subscriber1.errors.each do |e|
        puts e
    end
end

# Create test subscriber2
salt = BCrypt::Engine.generate_salt
subscriber2 = Subscriber.new(
    :email => "sub2@test.com",
    :passwd => BCrypt::Engine.hash_secret("sub2", salt),
    :salt => salt,
    :name => "Subscriber 2",
    :phone => "02024906787",
    :occupation => "Business",
    :city => "Pune"
    )
testPublisher1 = Publisher.first(:email => "test@test.com")
subscriber2.publisher = testPublisher1
if subscriber2.valid?
    subscriber2.save
    puts "=> Created sub2 user with email - sub2@test.com & password - sub2"
else
    puts "=> Errors:\n"
    subscriber2.errors.each do |e|
        puts e
    end
end

# Create test subscriber3
salt = BCrypt::Engine.generate_salt
subscriber3 = Subscriber.new(
    :email => "sub3@test.com",
    :passwd => BCrypt::Engine.hash_secret("sub3", salt),
    :salt => salt,
    :name => "Subscriber 3",
    :phone => "02024906767",
    :occupation => "goverment",
    :city => "Nasik"
    )
testPublisher2 = Publisher.first(:email => "test@test.com")
subscriber3.publisher = testPublisher2
if subscriber3.valid?
    subscriber3.save
    puts "=> Created sub3 user with email - sub3@test.com & password - sub3"
else
    puts "=> Errors:\n"
    subscriber3.errors.each do |e|
        puts e
    end
end

# Create test notification1
not1 = Notification.new(
    :title => "Notification 1",
    :text => "Notification 1 is good but not that good. Lets see what happens."
    )
testPublisher3 = Publisher.first(:email => "test@test.com")
not1.publisher = testPublisher3
if not1.valid?
    not1.save
    puts "=> Created test notification 1"
else
   puts "=> Errors:\n"
    not1.errors.each do |e|
        puts e
    end 
end

# Create test notification2
not2 = Notification.new(
    :title => "Notification 2",
    :text => "Notification 2 is good but not that good. Lets see what happens next."
    )
testPublisher4 = Publisher.first(:email => "test@test.com")
not2.publisher = testPublisher4
if not2.valid?
    not2.save
    puts "=> Created test notification 2"
else
    puts "=> Errors:\n"
    not2.errors.each do |e|
        puts e
    end 
end

# Create a test record for subscriber 1 viewed notification 1
vn = ViewedNotification.new()
vn.notification = not1
testSub1 = Subscriber.first(:email => "sub1@test.com")
vn.subscriber = testSub1

if vn.valid?
    vn.save
    puts "=> Created record for subscriber 1 viewed notification 1"
else
    puts "=> Errors:\n"
    vn.errors.each do |e|
        puts e
    end 
end