class CreateEdges < ActiveRecord::Migration
  def self.up
    create_table :polyscope_edges, :force => true do |t|
      t.references :abstract, :polymorphic => true, :null => false
      t.references :component,:polymorphic => true, :null => false
    end

    add_index :polyscope_edges, ["component_id", "component_type"],     :name => "a_component"
    add_index :polyscope_edges, ["abstract_id", "abstract_type"], :name => "a_abstract"
  
  end

  def self.down
    drop_table :polyscope_edges
  end
end
