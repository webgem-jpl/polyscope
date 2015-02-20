require 'rails_helper'

describe Polyscope::Middle do
  describe 'instantiation' do
    it 'instantiates polyscope_middle' do
      expect(Polyscope::Middle.create!.class.name).to eq("Polyscope::Middle")
    end
  end
  
  describe 'add polyshape' do
    it 'adds a polyshape as component' do
      polyscope_middle = create(:polyscope_middle)
      polyscope_component = create(:polyscope_component)
      polyscope_middle.add(polyscope_component)
      expect(polyscope_middle.has?(polyscope_component)).to be_truthy
    end
     it 'adds an abstract to component' do
      polyscope_middle = create(:polyscope_middle)
      polyscope_component = create(:polyscope_component)
      polyscope_middle.add(polyscope_component)
      expect(polyscope_component.belongs_to?(polyscope_middle)).to be_truthy
    end
  end
end
