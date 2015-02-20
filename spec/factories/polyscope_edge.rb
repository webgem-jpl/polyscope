FactoryGirl.define do
  factory :polyscope_edge, :class => Polyscope::Edge do
     m = Polyscope::Middle.create!
    m2 = Polyscope::Middle.create!
    e = Polyscope::Edge.create!(:component_id=>m.id,:component_type=>m.class.name,:abstract_id=>m2.id,:abstract_type=>m2.class.name)
    end
end
