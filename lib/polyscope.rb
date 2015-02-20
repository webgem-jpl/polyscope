require "polyscope/engine"
module Polyscope
  require "acts_as_component"
  require "acts_as_abstract"
  class Edge < ActiveRecord::Base
  belongs_to :components,:polymorphic => true
  belongs_to :abstracts,:polymorphic => true
  end
  class Shaper < ActiveRecord::Base
  end
end
