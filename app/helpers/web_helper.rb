# Helper methods defined here can be accessed in any controller or view in the application

StockNotifier::App.helpers do
  
    def logged_in?
        !session[:publisher].nil?
    end

    def format_date(the_date)
        if !the_date.nil? 
            the_date.strftime("%d %b, %Y @ %I:%M %p")
        end
    end

end
