class CreateShapers < ActiveRecord::Migration
  def self.up
    create_table :shapers do |t|
    t.text :diffs
    t.references :shape, :polymorphic => true, :null => false
  end
    add_index :shapers, ["shape_id", "shape_type"]
  end
  def self.down
    drop_table :shapers
  end
end
