StockNotifier::App.controllers :place do

    before do

      @publisher = get_publisher_from_session()
      if @publisher.blank?
        # if invalis request then send 401 not authorized                                                                                                       
        flash[:error] = "Access Denied. Please Login."
        redirect url(:login)
      end
      
    end

    get :places, :map => '/places' do
    
        keyword = params[:keyword] if params.has_key?("keyword")
        if keyword.blank?
            places = @publisher.places.all(:order => :created_at.desc).paginate(:page => params[:page])
        else
            places = @publisher.places.all(:conditions => ["name like ?", "%#{keyword}%"], :order => :created_at.desc).paginate(:page => params[:page])
        end

        total = places.total_entries

        render 'place/list', :locals => {:total => total, :places => places}

    end

    get :manage_place, :map => '/places/manage/:id' do

        place = Place.get(params[:id])
        place.verified = params[:active]

        if place.valid?
            place.save
        end
    
        redirect(:places)

    end

end
