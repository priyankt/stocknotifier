migration 1, :create_publishers do
  up do
    create_table :publishers do
      column :id, Integer, :serial => true
      column :email, String, :length => 255
      column :passwd, String, :length => 255
      column :name, String, :length => 255
      column :address, Text
      column :mobile, String, :length => 255
      column :phone, String, :length => 255
      column :website, String, :length => 255
      column :desc, Text
    end
  end

  down do
    drop_table :publishers
  end
end
