class CreateMidLevels < ActiveRecord::Migration
  def change
    create_table :mid_levels do |t|
      t.text :content
      t.timestamps null: false
    end
  end
end
