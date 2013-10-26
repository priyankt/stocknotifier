migration 10, :create_places do
  up do
    create_table :places do
      column :id, Integer, :serial => true
      
    end
  end

  down do
    drop_table :places
  end
end
