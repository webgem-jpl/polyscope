require 'rails_helper'

describe MidLevel do
  describe 'instantiation' do
    it 'instantiates mid_level' do
      expect(MidLevel.create!.class.name).to eq("MidLevel")
    end
  end
  
  describe 'add polyshape' do
    it 'adds a polyshape as component' do
      mid_level = create(:mid_level)
      low_level = create(:low_level)
      mid_level.add(low_level)
      expect(mid_level.has?(low_level)).to be_truthy
    end
     it 'adds an abstract to component' do
      mid_level = create(:mid_level)
      low_level = create(:low_level)
      mid_level.add(low_level)
      expect(low_level.belongs_to?(mid_level)).to be_truthy
    end
  end
end
