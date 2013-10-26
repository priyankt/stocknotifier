migration 12, :create_reviews do
  up do
    create_table :reviews do
      column :id, Integer, :serial => true
      
    end
  end

  down do
    drop_table :reviews
  end
end
