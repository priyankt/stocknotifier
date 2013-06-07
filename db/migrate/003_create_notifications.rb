migration 3, :create_notifications do
  up do
    create_table :notifications do
      column :id, Integer, :serial => true
      column :text, Text
    end
  end

  down do
    drop_table :notifications
  end
end
