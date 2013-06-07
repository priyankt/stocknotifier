migration 4, :create_viewed_notifications do
  up do
    create_table :viewed_notifications do
      column :id, Integer, :serial => true
      
    end
  end

  down do
    drop_table :viewed_notifications
  end
end
