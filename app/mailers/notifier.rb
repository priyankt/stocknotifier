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

  email :forgot_passwd_subscriber do |subscriber, new_passwd, publisher|
    from 'info@notifyme.in'
    to subscriber.email
    #bcc 'info@notifyme.in'
    subject "Your new password for #{publisher.name} app"
    content_type 'text/html' # optional, defaults to plain/text
    via :smtp # optional, to smtp if defined, otherwise sendmail
    render 'notifier/forgot_passwd_subscriber', :layout => 'email', :locals => {:subscriber => subscriber, :new_passwd => new_passwd, :publisher => publisher}
  end

  email :forgot_passwd_publisher do |publisher, new_passwd|
    from 'info@notifyme.in'
    to publisher.email
    subject 'Your new password at notifyme.in'
    content_type 'text/html' # optional, defaults to plain/text
    via :smtp # optional, to smtp if defined, otherwise sendmail
    render 'notifier/forgot_passwd_publisher', :layout => 'email', :locals => {:publisher => publisher, :new_passwd => new_passwd}
  end

  email :new_user do |subscriber, passwd, publisher|
    from 'info@notifyme.in'
    to subscriber.email
    subject "Welcome to #{publisher.name} app"
    content_type 'text/html' # optional, defaults to plain/text
    via :smtp # optional, to smtp if defined, otherwise sendmail
    render 'notifier/new_user', :layout => 'email', :locals => {:subscriber => subscriber, :passwd => passwd, :publisher => publisher}
  end

end
