StockNotifier::Api.controllers :place do

    before do

        @subscriber = get_subscriber_from_key()
        if @subscriber.blank?
            # if invalis request then send 401 not authorized
            halt 401, {:success => 0, :errors => ['Authentication failed. Please logout and login again.']}.to_json
        end

    end

    post :place, :map => '/place' do

        puts params.inspect
        place = Place.new
        place.name = params[:name] if params.has_key?('name')
        place.description = params[:description] if params.has_key?('description')
        place.phone = params[:contact] if params.has_key?('contact')
        place.address = params[:address] if params.has_key?('address')
        place.lat = params[:lat].to_f if params.has_key?('lat')
        place.lng = params[:lng].to_f if params.has_key?('lng')
        place.image1 = params[:image1] if params.has_key?('image1')
        place.image2 = params[:image2] if params.has_key?('image2')
        place.image3 = params[:image3] if params.has_key?('image3')

        if params.has_key?('categories')
            categories = JSON.parse params[:categories]
            categories.each do |c|
                place.categories << Category.get(c)
            end
        end

        place.subscriber = @subscriber
        place.publisher = @subscriber.publisher

        if place.valid?
            place.save
            status 200
            ret = {:success => 1, :id => place.id}
        else
            status 400
            ret = {:success => 0, :errors => get_formatted_errors(place.errors)}
        end
        
        ret.to_json

    end

    get :places, :map => '/places' do

        exclude_ids = JSON.parse params[:exclude_ids] if params.has_key?('exclude_ids')

        ne_lat = params[:ne_lat].to_f if params.has_key?('ne_lat')
        ne_lng = params[:ne_lng].to_f if params.has_key?('ne_lng')
        sw_lat = params[:sw_lat].to_f if params.has_key?('sw_lat')
        sw_lng = params[:sw_lng].to_f if params.has_key?('sw_lng')
        category_ids = params[:categories] if params.has_key?('categories')

        query = "
            SELECT
                id, name, description, phone, address, lat, lng, image1, image2, image3, subscriber_id
            FROM
                places
            INNER JOIN
                category_places
            ON
                places.id = category_places.place_id
            WHERE
                lat < #{ne_lat}
            AND
                lat > #{sw_lat}
            AND
                lng > #{sw_lng}
            AND
                lng < #{ne_lng}
            AND
                verified = 't'
        "

        if category_ids.present? and category_ids.length > 0
            query += ' AND category_id in (' + category_ids.join(',') + ')'
        end

        if exclude_ids.present? and exclude_ids.length > 0
            query += ' AND places.id not in (' + exclude_ids.join(',') + ')'
        end

        query += ' GROUP BY places.id'

        places = repository(:default).adapter.select(query)

        ret = []
        
        places.each do |p|
            creator = Subscriber.get(p[:subscriber_id])
            ret.push({
                :id => p[:id],
                :name => p[:name],
                :description => p[:description],
                :contact => p[:phone],
                :address => p[:address],
                :lat => p[:lat],
                :lng => p[:lng],
                :creator => creator.name,
                :image => get_place_images(p)
            })
        end

        return ret.to_json

    end

    post :review, :map => '/place/:id/review' do

        begin

            review = Review.new()
            review.text = params[:text] if has_key?('text')
            review.place_id = params[:id]
            review.subscriber = @subscriber

            if review.valid?
                review.save
                status 200
                ret = {:success => 1}
            else
                raise CustomError.new(get_formatted_errors(review.errors))
            end
            
        rescue CustomError => ce

            status 400
            ret = {:success => 0, :errors => ce.errors}

        end

    end

    get :reviews, :map => '/place/:id/reviews' do

        reviews = Review.all(place_id => params[:id], :active => true)

        return reviews.to_json

    end

end
