class CreatePolyscopeShapes < ActiveRecord::Migration
  def self.up
    create_table :polyscope_shapes do |t|
    t.text :diffs
    t.references :shape, :polymorphic => true, :null => false
  end
    add_index :polyscope_shapes, ["shape_id", "shape_type"]
  end
  def self.down
    drop_table :polyscope_shapes
  end
end
