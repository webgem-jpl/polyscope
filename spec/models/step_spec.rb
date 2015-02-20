require 'rails_helper'

describe Step do
  describe 'instantiation' do
    it 'instantiates step' do
      expect(Step.create!.class.name).to eq("Step")
    end
  end
  
  describe 'add polyshape' do
    it 'adds a polyshape as component' do
      step = create(:step)
      ingredient = create(:ingredient)
      step.add(ingredient)
      expect(step.has?(ingredient)).to be_truthy
    end
     it 'adds an abstract to component' do
      step = create(:step)
      ingredient = create(:ingredient)
      step.add(ingredient)
      expect(ingredient.belongs_to?(step)).to be_truthy
    end
  end
end
