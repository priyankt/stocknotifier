migration 5, :create_sponsorers do
  up do
    create_table :sponsorers do
      column :id, Integer, :serial => true
      column :name, String, :length => 255
      column :email, String, :length => 255
      column :phone, String, :length => 255
      column :address, String, :length => 255
      column :about, Text
    end
  end

  down do
    drop_table :sponsorers
  end
end
