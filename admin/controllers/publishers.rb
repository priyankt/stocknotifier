StockNotifier::Admin.controllers :publishers do
  get :index do
    @title = "Publishers"
    @publishers = Publisher.all
    render 'publishers/index'
  end

  get :new do
    @title = pat(:new_title, :model => 'publisher')
    @publisher = Publisher.new
    render 'publishers/new'
  end

  post :create do
    @publisher = Publisher.new(params[:publisher])
    salt = BCrypt::Engine.generate_salt
    @publisher.passwd = BCrypt::Engine.hash_secret( @publisher.passwd, salt)
    @publisher.salt = salt
    if @publisher.save
      @title = pat(:create_title, :model => "publisher #{@publisher.id}")
      flash[:success] = pat(:create_success, :model => 'Publisher')
      params[:save_and_continue] ? redirect(url(:publishers, :index)) : redirect(url(:publishers, :edit, :id => @publisher.id))
    else
      @title = pat(:create_title, :model => 'publisher')
      flash.now[:error] = pat(:create_error, :model => 'publisher')
      render 'publishers/new'
    end
  end

  get :edit, :with => :id do
    @title = pat(:edit_title, :model => "publisher #{params[:id]}")
    @publisher = Publisher.get(params[:id].to_i)
    if @publisher
      render 'publishers/edit'
    else
      flash[:warning] = pat(:create_error, :model => 'publisher', :id => "#{params[:id]}")
      halt 404
    end
  end

  put :update, :with => :id do
    @title = pat(:update_title, :model => "publisher #{params[:id]}")
    @publisher = Publisher.get(params[:id].to_i)
    if @publisher
      if @publisher.update(params[:publisher])
        flash[:success] = pat(:update_success, :model => 'Publisher', :id =>  "#{params[:id]}")
        params[:save_and_continue] ?
          redirect(url(:publishers, :index)) :
          redirect(url(:publishers, :edit, :id => @publisher.id))
      else
        flash.now[:error] = pat(:update_error, :model => 'publisher')
        render 'publishers/edit'
      end
    else
      flash[:warning] = pat(:update_warning, :model => 'publisher', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy, :with => :id do
    @title = "Publishers"
    publisher = Publisher.get(params[:id].to_i)
    if publisher
      if publisher.destroy
        flash[:success] = pat(:delete_success, :model => 'Publisher', :id => "#{params[:id]}")
      else
        flash[:error] = pat(:delete_error, :model => 'publisher')
      end
      redirect url(:publishers, :index)
    else
      flash[:warning] = pat(:delete_warning, :model => 'publisher', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy_many do
    @title = "Publishers"
    unless params[:publisher_ids]
      flash[:error] = pat(:destroy_many_error, :model => 'publisher')
      redirect(url(:publishers, :index))
    end
    ids = params[:publisher_ids].split(',').map(&:strip).map(&:to_i)
    publishers = Publisher.all(:id => ids)
    
    if publishers.destroy
    
      flash[:success] = pat(:destroy_many_success, :model => 'Publishers', :ids => "#{ids.to_sentence}")
    end
    redirect url(:publishers, :index)
  end
end
