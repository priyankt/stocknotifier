StockNotifier::Api.controllers :category do

    before do

        @subscriber = get_subscriber_from_key()
        if @subscriber.blank?
            # if invalis request then send 401 not authorized
            halt 401, {:success => 0, :errors => ['Authentication failed. Please logout and login again.']}.to_json
        end

    end

    get :categories, :map => '/categories' do

        categories = @subscriber.publisher.categories.all(:active => true, :order => [:name])

        return categories.to_json(:exclude => [:updated_at, :created_at, :active, :publisher_id])

    end

end
