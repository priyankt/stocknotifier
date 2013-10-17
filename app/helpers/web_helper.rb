# Helper methods defined here can be accessed in any controller or view in the application

StockNotifier::App.helpers do
  
    def logged_in?

        !session[:publisher].nil? and !Publisher.first( :id => session[:publisher], :active => true).nil?

    end

    def format_date(the_date)

        if !the_date.nil? 
            the_date.strftime("%d %b, %Y @ %I:%M %p")
        end

    end

    def images_available(notification)

    	notification.image1.main.url.present? or notification.image2.main.url.present? or notification.image3.main.url.present?	or notification.image4.main.url.present? or notification.image5.main.url.present?

    end

    def videos_available(notification)

    	notification.video1.present?

    end

    def media_available(notification)

    	images_available(notification) or videos_available(notification)

    end

end
