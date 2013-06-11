##
# Mailer methods can be defined using the simple format:
#
# email :registration_email do |name, user|
#   from 'admin@site.com'
#   to   user.email
#   subject 'Welcome to the site!'
#   locals  :name => name
#   content_type 'text/html'       # optional, defaults to plain/text
#   via     :sendmail              # optional, to smtp if defined, otherwise sendmail
#   render  'registration_email'
# end
#
# You can set the default delivery settings from your app through:
#
#   set :delivery_method, :smtp => {
#     :address         => 'smtp.yourserver.com',
#     :port            => '25',
#     :user_name       => 'user',
#     :password        => 'pass',
#     :authentication  => :plain, # :plain, :login, :cram_md5, no auth by default
#     :domain          => "localhost.localdomain" # the HELO domain provided by the client to the server
#   }
#
# or sendmail (default):
#
#   set :delivery_method, :sendmail
#
# or for tests:
#
#   set :delivery_method, :test
#
# or storing emails locally:
#

	# set :delivery_method, :file => {
	# 	:location => "#{Padrino.root}/tmp/emails",
	# }

#
# and then all delivered mail will use these settings unless otherwise specified.
#

StockNotifier::App.mailer :notifier do

  email :forgot_passwd do |user, new_passwd|
    from 'jaganluthra@gmail.com'
    to user.email
    subject 'Your new password'
    content_type 'text/html' # optional, defaults to plain/text
    via :smtp # optional, to smtp if defined, otherwise sendmail
    render 'notifier/forgot_passwd', :layout => 'email', :locals => {:user => user, :new_passwd => new_passwd}
  end

end
