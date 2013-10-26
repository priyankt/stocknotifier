StockNotifier::App.controllers :category do

    before do

        @publisher = get_publisher_from_session()
        if @publisher.blank?
            # if invalis request then send 401 not authorized                                                                                                       
            flash[:error] = "Access Denied. Please Login."
            redirect url(:login)
        end

    end

    get :new_category, :map => '/category/new' do
    
        @category = Category.new()

        render 'category/new'

    end

    post :new_category, :map => '/category/new' do

        @category = Category.new(params[:category])
        @category.publisher = @publisher

        if @category.valid?
            @category.save
            flash[:success] = "Category #{@category.name} created successfully."
            redirect url(:category, :new_category)
        else
            flash.now[:error] = "Failed to create category #{@category.name}."
            render 'category/new'
        end
    
        render 'category/new'

    end

    get :categories, :map => '/categories' do
    
        keyword = params[:keyword] if params.has_key?("keyword")
        if keyword.blank?
            categories = @publisher.categories.all(:order => :created_at.desc).paginate(:page => params[:page])
        else
            categories = @publisher.categories.all(:conditions => ["name like ?", "%#{keyword}%"], :order => :created_at.desc).paginate(:page => params[:page])
        end

        total = categories.total_entries

        render 'category/list', :locals => {:total => total, :categories => categories}

    end

    get :manage_category, :map => '/category/manage/:id' do

        category = Category.get(params[:id])
        category.active = params[:active]

        if category.valid?
            category.save
        end
    
        redirect(:categories)

    end

end
