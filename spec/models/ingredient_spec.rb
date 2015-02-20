require 'rails_helper'
describe Ingredient do
  describe 'instantiation' do
    it 'instantiates ingredient' do
      expect(Ingredient.create!.class.name).to eq("Ingredient")
    end
  end
end
