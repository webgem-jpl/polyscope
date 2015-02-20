require 'rails_helper'
describe LowLevel do
  describe 'instantiation' do
    it 'instantiates low_level' do
      expect(LowLevel.create!.class.name).to eq("LowLevel")
    end
  end
end
