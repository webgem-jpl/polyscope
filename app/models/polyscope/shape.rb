class Polyscope::Shape < ActiveRecord::Base
  belongs_to :shapes, :polymorphic => true
  serialize :diffs, Hash
  
end
