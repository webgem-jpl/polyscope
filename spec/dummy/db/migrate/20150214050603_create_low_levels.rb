class CreateLowLevels < ActiveRecord::Migration
  def change
    create_table :low_levels do |t|
      t.string :name
      t.float :quantity
      t.string :quantity_type
      t.timestamps null: false
    end
  end
end
