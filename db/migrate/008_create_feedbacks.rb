migration 8, :create_feedbacks do
  up do
    create_table :feedbacks do
      column :id, Integer, :serial => true
      
    end
  end

  down do
    drop_table :feedbacks
  end
end
