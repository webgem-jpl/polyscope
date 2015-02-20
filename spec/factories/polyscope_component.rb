FactoryGirl.define do
  factory :polyscope_component, :class => Polyscope::Component do
    Polyscope::Component.create!
  end
end
