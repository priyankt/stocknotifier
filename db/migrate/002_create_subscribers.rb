migration 2, :create_subscribers do
  up do
    create_table :subscribers do
      column :id, Integer, :serial => true
      column :email, String, :length => 255
      column :passwd, String, :length => 255
      column :name, String, :length => 255
      column :registration_token, String, :length => 255
      column :mobile, String, :length => 255
      column :phone, String, :length => 255
    end
  end

  down do
    drop_table :subscribers
  end
end
