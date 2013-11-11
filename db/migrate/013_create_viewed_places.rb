migration 13, :create_viewed_places do
  up do
    create_table :viewed_places do
      column :id, Integer, :serial => true
      
    end
  end

  down do
    drop_table :viewed_places
  end
end
