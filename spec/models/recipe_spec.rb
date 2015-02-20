require 'rails_helper'

describe Recipe do
  describe 'instantiation' do
    it 'instantiates a recipe' do
      expect(Recipe.create!.class.name).to eq("Recipe")
    end
  end
  
  describe 'add polyshape level -1' do
    before do
      @recipe = create(:recipe)
      @step = create(:step)
      @recipe.add(@step)
    end
    it 'add a component' do
      expect(@recipe.has?(@step)).to be_truthy
    end
    it 'add an abstract to a polyshape' do
      expect(@step.belongs_to?(@recipe)).to be_truthy
    end
  end
  
  describe 'add polyshape level -2' do
    before(:all) do
      @recipe = create(:recipe)
      @step = create(:step)
      @ingredient = create(:ingredient)
      @recipe.add(@step)
      @step.add(@ingredient)
    end
    it 'add a component' do
      expect(@recipe.has?(@step)).to be_truthy
    end
    it 'add a component level -2' do
      expect(@recipe.has?(@ingredient)).to be_truthy
    end
    it 'add an abstract to a polyshape level 1' do
      expect(@step.belongs_to?(@recipe)).to be_truthy
    end
    it 'add an abstract to a polyshape level 2' do
      expect(@ingredient.belongs_to?(@recipe)).to be_truthy
    end
    it 'give a down level of 2' do
      expect(@recipe.down_level).to eq(2)
    end
    it 'give a down level of 1 to the component' do
      expect(@step.down_level).to eq(1)
    end
    it 'give a parent level of 1 to the component' do
      expect(@step.up_level).to eq(1)
    end
    it 'give a parent level of 2 to the component of component' do
      expect(@ingredient.up_level).to eq(2)
    end
  end
  
  describe "get the difference between empty object" do
      before(:all) do
        @r =  create(:recipe)
        @r2 = create(:recipe)
      end
      it "get maximal difference" do
        d = Recipe.compare(@r,@r2,Step)
        expect(d[:distance]).to eq(1)
      end
      it "get maximal sorted difference" do
        d = Recipe.compare(@r,@r2,Step)
        expect(d[:sorted_distance]).to eq(1)
      end
  end

  describe "get the difference of full object" do
      before(:all) do
      @r3 = create(:recipe)
      @r4 = create(:recipe)
      s = create(:step)
      @r3.add(s)
      @r4.add(s)
      @r5 = create(:recipe)
      @r5.add(s)
      @r5.add(create(:step))
      end
      it "get the mimimal difference" do 
      d= Recipe.compare(@r3,@r4,Step)
      expect(d[:distance]).to eq(0)
      end
      it "get the mimimal sorted difference" do 
      d= Recipe.compare(@r3,@r4,Step)
      expect(d[:distance]).to eq(0)
      end
      it "get  0.5 difference" do 
      d= Recipe.compare(@r3,@r5,Step)
      expect(d[:distance]).to eq(0.5)
      end
      it "get 0.5 sorted difference" do 
      d= Recipe.compare(@r3,@r5,Step)
      expect(d[:distance]).to eq(0.5)
      end
    end
    
    describe "polyscope" do
      before do
      @recipe = create(:recipe)
      @step = create(:step)
      @ingredient = create(:ingredient)
      @recipe.add(@step)
      @step.add(@ingredient)
      end
      it "gives 2 dimensions value" do
      d = @recipe.polyscope(@step)
      expect(d[:dimensions][:step]).to_not be_nil
      expect(d[:dimensions][:ingredient]).to_not be_nil
      end
      it "gives correct value" do
      d = @recipe.polyscope(Recipe.create)
      expect(d[:dimensions][:step][:distance]).to eq(1)
      expect(d[:dimensions][:ingredient][:distance]).to eq(1)
      expect(d[:dimensions][:step][:sorted_distance]).to eq(1)
      d[:distance].should be > 1.4
      d[:sorted_distance].should be > 1.4
      d[:distance].should be < 1.5
      d[:sorted_distance].should be < 1.5
      end
    end
    describe "copy" do
      before(:all) do
        @recipe = create(:recipe, :title => "My recipe")
        @step = create(:step, :content => "this is a step content")
        @ingredient = create(:ingredient)
        @step.add(@ingredient)
        @recipe.add(@step)
        @copy = Step.copy(@step)
      end
      it "creates a new identical instance" do
        expect(@copy.content).to eq(@step.content)
      end
      it "create the same children structure" do
        expect(@copy.all).to eq(@step.all)
      end
      it "create the same parents structure" do
          expect(@copy.parents).to eq(@step.parents)
      end
    end
    
    describe "instance_of" do
      before(:all) do
        @recipe = create(:recipe)
        @step = create(:step)
        @ingredient = create(:ingredient)
        @recipe.add(@step)
        @step.add(@ingredient)
      end
      it "shows 1 instance of type" do
        p = @recipe.instance_of(Step)
        expect(p.count).to eq(1)
      end
      it "shows 2 instances of type" do
        @recipe.add(@step)
        p = @recipe.instance_of(Step)
        expect(p.count).to eq(2)
      end
      it "doesnt count instances of type of child" do
        p = @recipe.instance_of(Ingredient)
        expect(p.count).to eq(0)
      end
    end
  
    describe "Common" do
      before(:all) do
        @recipe = create(:recipe)
        @step = create(:step)
        @ingredient = create(:ingredient)
        @recipe.add(@step)
        @step.add(@ingredient)
        @recipe2 = Recipe.copy(@recipe)
        @step2 = create(:step)
        @step2.add(@ingredient)
        @recipe2.add(@step2)
      end
      it "gives the intersection of shapes" do
        expect(@recipe.intersect(@recipe2).include?(@ingredient)).to be_truthy
        expect(@recipe.intersect(@recipe2).include?(@step)).to be_truthy
      end
      it "doesnt gives what is not in intersection" do
        expect(@recipe.intersect(@recipe2).include?(@step2)).to be_falsey
      end
    end
    describe "Down" do
      before(:all) do
        @recipe = create(:recipe)
        @step = create(:step)
        @step2 = create(:step)
        @ingredient = create(:ingredient)
        @recipe.add(@step)
        @recipe.add(@step2)
        @step.add(@ingredient)
      end
      
      it "doesnt list the second level down" do
        expect(@recipe.down.include?(@ingredient)).to be_falsey      
      end
      it "lists the first level down" do
        expect(@recipe.down.include?(@step)).to be_truthy
        expect(@recipe.down.include?(@step2)).to be_truthy
      end
      it "doesnt list the level up" do
        expect(@step.down.include?(@recipe)).to be_falsey
      end
    end
    
    describe "Up" do
      before(:all) do
        @recipe = create(:recipe)
        @step = create(:step)
        @step2 = create(:step)
        @ingredient = create(:ingredient)
        @recipe.add(@step)
        @recipe.add(@step2)
        @step.add(@ingredient)
      end
      
      it "doesnt list the second level up" do
        expect(@ingredient.up.include?(@recipe)).to be_falsey      
      end
      it "lists the first level up" do
        expect(@ingredient.up.include?(@step)).to be_truthy
        expect(@step.up.include?(@recipe)).to be_truthy
      end
      it "doesnt list the level down" do
        expect(@step.up.include?(@ingredient)).to be_falsey
      end
    end
    
    describe "All" do
      before(:all) do
        @recipe = create(:recipe)
        @recipe2 = create(:recipe)
        @step = create(:step)
        @ingredient = create(:ingredient)
        @ingredient2 = create(:ingredient)
        @recipe.add(@step)
        @recipe2.add(@step)
        @step.add(@ingredient)
        @step.add(@ingredient2)
      end
      it "list all descendants of first level down" do
        expect(@step.all.include?(@ingredient)).to be_truthy
        expect(@step.all.include?(@ingredient2)).to be_truthy
        expect(@recipe.all.include?(@step)).to be_truthy
        expect(@recipe2.all.include?(@step)).to be_truthy
      end
       it "list all descendants of second level down" do
        expect(@recipe.all.include?(@ingredient)).to be_truthy
        expect(@recipe2.all.include?(@ingredient2)).to be_truthy
      end
        before(:all) do
          @step2 =create(:step)
          @step.add(@step2)
          @step3 =create(:step)
          @step2.add(@step3)
          @ingredient3 = create(:ingredient)
          @step3.add(@ingredient3)
        end
        it "list all descendants of N level down" do
        expect(@recipe.all.include?(@ingredient3)).to be_truthy
        expect(@recipe2.all.include?(@ingredient3)).to be_truthy
      end
    end
    describe "parents" do
      before(:all) do
        @recipe = create(:recipe)
        @recipe2 = create(:recipe)
        @step = create(:step)
        @ingredient = create(:ingredient)
        @ingredient2 = create(:ingredient)
        @recipe.add(@step)
        @recipe2.add(@step)
        @step.add(@ingredient)
        @step.add(@ingredient2)
      end
      it "list all descendants of first level up" do
        expect(@ingredient.parents.include?(@step)).to be_truthy
        expect(@ingredient2.parents.include?(@step)).to be_truthy
        expect(@step.parents.include?(@recipe)).to be_truthy
        expect(@step.parents.include?(@recipe2)).to be_truthy
      end
       it "list all descendants of second level up" do
        expect(@ingredient.parents.include?(@recipe)).to be_truthy
        expect(@ingredient2.parents.include?(@recipe2)).to be_truthy
        expect(@ingredient2.parents.include?(@recipe)).to be_truthy
        expect(@ingredient.parents.include?(@recipe2)).to be_truthy
      end
        before(:all) do
          @step2 =create(:step)
          @step.add(@step2)
          @step3 =create(:step)
          @step2.add(@step3)
          @ingredient3 = create(:ingredient)
          @step3.add(@ingredient3)
        end
        it "list all parents of N level up" do
        expect(@ingredient3.parents.include?(@recipe)).to be_truthy
        expect(@ingredient3.parents.include?(@recipe2)).to be_truthy
      end
    end
    
    describe "down_level" do
      before(:all) do
          @step = create(:step)
          @step2 =create(:step)
          @step.add(@step2)
          @step3 =create(:step)
          @step2.add(@step3)
        end
      
      it "calcule correct maximum down level" do
        expect(@step.down_level).to eq(2)
        expect(@step2.down_level).to eq(1)
        expect(@step3.down_level).to eq(0)
      end
      before(:all) do
          @step4 = create(:step)
          @step.add(@step4)
      end
      it "calcule correct maximum down level for all branches" do
        expect(@step.down_level).to eq(2)
        expect(@step2.down_level).to eq(1)
        expect(@step3.down_level).to eq(0)
        expect(@step4.down_level).to eq(0)
      end
    end
    describe "up_level" do
      before(:all) do
          @step = create(:step)
          @step2 =create(:step)
          @step.add(@step2)
          @step3 =create(:step)
          @step2.add(@step3)
        end
      
      it "calcule correct maximum up level" do
        expect(@step.up_level).to eq(0)
        expect(@step2.up_level).to eq(1)
        expect(@step3.up_level).to eq(2)
      end
      before(:all) do
          @step4 = create(:step)
          @step4.add(@step2)
      end
      it "calcule correct maximum down level for all branches" do
        expect(@step.up_level).to eq(0)
        expect(@step2.up_level).to eq(1)
        expect(@step3.up_level).to eq(2)
        expect(@step4.up_level).to eq(0)
      end
    end 
end
