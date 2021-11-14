class CreateVehicles < ActiveRecord::Migration[5.2]
  def change
    create_table :vehicles do |t|
      t.string :vin
      t.float :mileage
      t.string :make
      t.string :model
      t.string :color
      t.belongs_to :customer, foreign_key: true

      t.timestamps
    end
  end
end
