class Edge < ActiveRecord::Base
  belongs_to :components,:polymorphic => true
  belongs_to :abstracts,:polymorphic => true
end