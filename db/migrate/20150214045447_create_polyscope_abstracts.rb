class CreatePolyscopeAbstracts < ActiveRecord::Migration
  def change
    create_table :polyscope_abstracts do |t|
      t.string :name
      t.timestamps null: false
    end
  end
end
