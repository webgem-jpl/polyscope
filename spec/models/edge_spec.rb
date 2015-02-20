require 'rails_helper'
describe Polyscope::Edge do
  describe 'instantiation' do
    it 'raise error' do
      expect { Polyscope::Edge.create! }.to raise_error
    end
  end
  describe 'instantiation with component and abstract nodes' do
    it 'doesnt raise error' do
      m = Polyscope::Middle.create!
      m2 = Polyscope::Middle.create!
      e = Polyscope::Edge.create!(:component_id=>m.id,:component_type=>m.class.name,:abstract_id=>m2.id,:abstract_type=>m2.class.name)
    expect(e.id).to_not be_nil
    end
  end
  describe 'instantiation with component and abstract nodes' do
    it 'doesnt raise error' do
      m = Polyscope::Component.create!
      m2 = Polyscope::Abstract.create!
      e = Polyscope::Edge.create!(:component_id=>m.id,:component_type=>m.class.name,:abstract_id=>m2.id,:abstract_type=>m2.class.name)
    expect(e.id).to_not be_nil
    end
  end
end
