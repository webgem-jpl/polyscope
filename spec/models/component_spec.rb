require 'rails_helper'
describe Polyscope::Component do
  describe 'instantiation' do
    it 'instantiates polyscope_component' do
      expect(Polyscope::Component.create!.class.name).to eq("Polyscope::Component")
    end
  end
end
