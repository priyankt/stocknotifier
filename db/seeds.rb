require 'csv'    

csv_text = File.read('/home/priyank/web/StockNotifier/config/jainsite_user.csv')
csv = CSV.parse(csv_text, :headers => false)
publisher = Publisher.first(:email => 'info@jainsite.com')
csv.each do |u|
  	subscriber = Subscriber.new(
		:email => u[1],
		:passwd => u[2],
		:name => u[3],
		:phone => u[4],
		:occupation => u[5],
		:city => u[7],
		:publisher => publisher
	)

	if subscriber.valid?
		subscriber.save
		puts "user #{subscriber.name} saved successfully."
	else
		puts "Invalid user #{subscriber.name}."
		puts subscriber.errors.to_hash
	end

end
