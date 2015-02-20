require 'rails_helper'

describe HighLevel do
  describe 'instantiation' do
    it 'instantiates a high_level' do
      expect(HighLevel.create!.class.name).to eq("HighLevel")
    end
  end
  
  describe 'add polyshape level -1' do
    before do
      @high_level = create(:high_level)
      @mid_level = create(:mid_level)
      @high_level.add(@mid_level)
    end
    it 'add a component' do
      expect(@high_level.has?(@mid_level)).to be_truthy
    end
    it 'add an abstract to a polyshape' do
      expect(@mid_level.belongs_to?(@high_level)).to be_truthy
    end
  end
  
  describe 'add polyshape level -2' do
    before(:all) do
      @high_level = create(:high_level)
      @mid_level = create(:mid_level)
      @low_level = create(:low_level)
      @high_level.add(@mid_level)
      @mid_level.add(@low_level)
    end
    it 'add a component' do
      expect(@high_level.has?(@mid_level)).to be_truthy
    end
    it 'add a component level -2' do
      expect(@high_level.has?(@low_level)).to be_truthy
    end
    it 'add an abstract to a polyshape level 1' do
      expect(@mid_level.belongs_to?(@high_level)).to be_truthy
    end
    it 'add an abstract to a polyshape level 2' do
      expect(@low_level.belongs_to?(@high_level)).to be_truthy
    end
    it 'give a down level of 2' do
      expect(@high_level.down_level).to eq(2)
    end
    it 'give a down level of 1 to the component' do
      expect(@mid_level.down_level).to eq(1)
    end
    it 'give a parent level of 1 to the component' do
      expect(@mid_level.up_level).to eq(1)
    end
    it 'give a parent level of 2 to the component of component' do
      expect(@low_level.up_level).to eq(2)
    end
  end
  
  describe "get the difference between empty object" do
      before(:all) do
        @r =  create(:high_level)
        @r2 = create(:high_level)
      end
      it "get maximal difference" do
        d = HighLevel.compare(@r,@r2,MidLevel)
        expect(d[:distance]).to eq(1)
      end
      it "get maximal sorted difference" do
        d = HighLevel.compare(@r,@r2,MidLevel)
        expect(d[:sorted_distance]).to eq(1)
      end
  end

  describe "get the difference of full object" do
      before(:all) do
      @r3 = create(:high_level)
      @r4 = create(:high_level)
      s = create(:mid_level)
      @r3.add(s)
      @r4.add(s)
      @r5 = create(:high_level)
      @r5.add(s)
      @r5.add(create(:mid_level))
      end
      it "get the mimimal difference" do 
      d= HighLevel.compare(@r3,@r4,MidLevel)
      expect(d[:distance]).to eq(0)
      end
      it "get the mimimal sorted difference" do 
      d= HighLevel.compare(@r3,@r4,MidLevel)
      expect(d[:distance]).to eq(0)
      end
      it "get  0.5 difference" do 
      d= HighLevel.compare(@r3,@r5,MidLevel)
      expect(d[:distance]).to eq(0.5)
      end
      it "get 0.5 sorted difference" do 
      d= HighLevel.compare(@r3,@r5,MidLevel)
      expect(d[:distance]).to eq(0.5)
      end
    end
    
    describe "polyscope" do
      before do
      @high_level = create(:high_level)
      @mid_level = create(:mid_level)
      @low_level = create(:low_level)
      @high_level.add(@mid_level)
      @mid_level.add(@low_level)
      end
      it "gives 2 dimensions value" do
      d = @high_level.polyscope(@mid_level)
      expect(d[:dimensions][:mid_level]).to_not be_nil
      expect(d[:dimensions][:low_level]).to_not be_nil
      end
      it "gives correct value" do
      d = @high_level.polyscope(HighLevel.create)
      expect(d[:dimensions][:mid_level][:distance]).to eq(1)
      expect(d[:dimensions][:low_level][:distance]).to eq(1)
      expect(d[:dimensions][:mid_level][:sorted_distance]).to eq(1)
      d[:distance].should be > 1.4
      d[:sorted_distance].should be > 1.4
      d[:distance].should be < 1.5
      d[:sorted_distance].should be < 1.5
      end
    end
    describe "copy" do
      before(:all) do
        @high_level = create(:high_level, :title => "My high_level")
        @mid_level = create(:mid_level, :content => "this is a mid_level content")
        @low_level = create(:low_level)
        @mid_level.add(@low_level)
        @high_level.add(@mid_level)
        @copy = MidLevel.copy(@mid_level)
      end
      it "creates a new identical instance" do
        expect(@copy.content).to eq(@mid_level.content)
      end
      it "create the same children structure" do
        expect(@copy.all).to eq(@mid_level.all)
      end
      it "create the same parents structure" do
          expect(@copy.parents).to eq(@mid_level.parents)
      end
    end
    
    describe "instance_of" do
      before(:all) do
        @high_level = create(:high_level)
        @mid_level = create(:mid_level)
        @low_level = create(:low_level)
        @high_level.add(@mid_level)
        @mid_level.add(@low_level)
      end
      it "shows 1 instance of type" do
        p = @high_level.instance_of(MidLevel)
        expect(p.count).to eq(1)
      end
      it "shows 2 instances of type" do
        @high_level.add(@mid_level)
        p = @high_level.instance_of(MidLevel)
        expect(p.count).to eq(2)
      end
      it "doesnt count instances of type of child" do
        p = @high_level.instance_of(LowLevel)
        expect(p.count).to eq(0)
      end
    end
  
    describe "Common" do
      before(:all) do
        @high_level = create(:high_level)
        @mid_level = create(:mid_level)
        @low_level = create(:low_level)
        @high_level.add(@mid_level)
        @mid_level.add(@low_level)
        @high_level2 = HighLevel.copy(@high_level)
        @mid_level2 = create(:mid_level)
        @mid_level2.add(@low_level)
        @high_level2.add(@mid_level2)
      end
      it "gives the intersection of shapes" do
        expect(@high_level.intersect(@high_level2).include?(@low_level)).to be_truthy
        expect(@high_level.intersect(@high_level2).include?(@mid_level)).to be_truthy
      end
      it "doesnt gives what is not in intersection" do
        expect(@high_level.intersect(@high_level2).include?(@mid_level2)).to be_falsey
      end
    end
    describe "Down" do
      before(:all) do
        @high_level = create(:high_level)
        @mid_level = create(:mid_level)
        @mid_level2 = create(:mid_level)
        @low_level = create(:low_level)
        @high_level.add(@mid_level)
        @high_level.add(@mid_level2)
        @mid_level.add(@low_level)
      end
      
      it "doesnt list the second level down" do
        expect(@high_level.down.include?(@low_level)).to be_falsey      
      end
      it "lists the first level down" do
        expect(@high_level.down.include?(@mid_level)).to be_truthy
        expect(@high_level.down.include?(@mid_level2)).to be_truthy
      end
      it "doesnt list the level up" do
        expect(@mid_level.down.include?(@high_level)).to be_falsey
      end
    end
    
    describe "Up" do
      before(:all) do
        @high_level = create(:high_level)
        @mid_level = create(:mid_level)
        @mid_level2 = create(:mid_level)
        @low_level = create(:low_level)
        @high_level.add(@mid_level)
        @high_level.add(@mid_level2)
        @mid_level.add(@low_level)
      end
      
      it "doesnt list the second level up" do
        expect(@low_level.up.include?(@high_level)).to be_falsey      
      end
      it "lists the first level up" do
        expect(@low_level.up.include?(@mid_level)).to be_truthy
        expect(@mid_level.up.include?(@high_level)).to be_truthy
      end
      it "doesnt list the level down" do
        expect(@mid_level.up.include?(@low_level)).to be_falsey
      end
    end
    
    describe "All" do
      before(:all) do
        @high_level = create(:high_level)
        @high_level2 = create(:high_level)
        @mid_level = create(:mid_level)
        @low_level = create(:low_level)
        @low_level2 = create(:low_level)
        @high_level.add(@mid_level)
        @high_level2.add(@mid_level)
        @mid_level.add(@low_level)
        @mid_level.add(@low_level2)
      end
      it "list all descendants of first level down" do
        expect(@mid_level.all.include?(@low_level)).to be_truthy
        expect(@mid_level.all.include?(@low_level2)).to be_truthy
        expect(@high_level.all.include?(@mid_level)).to be_truthy
        expect(@high_level2.all.include?(@mid_level)).to be_truthy
      end
       it "list all descendants of second level down" do
        expect(@high_level.all.include?(@low_level)).to be_truthy
        expect(@high_level2.all.include?(@low_level2)).to be_truthy
      end
        before(:all) do
          @mid_level2 =create(:mid_level)
          @mid_level.add(@mid_level2)
          @mid_level3 =create(:mid_level)
          @mid_level2.add(@mid_level3)
          @low_level3 = create(:low_level)
          @mid_level3.add(@low_level3)
        end
        it "list all descendants of N level down" do
        expect(@high_level.all.include?(@low_level3)).to be_truthy
        expect(@high_level2.all.include?(@low_level3)).to be_truthy
      end
    end
    describe "parents" do
      before(:all) do
        @high_level = create(:high_level)
        @high_level2 = create(:high_level)
        @mid_level = create(:mid_level)
        @low_level = create(:low_level)
        @low_level2 = create(:low_level)
        @high_level.add(@mid_level)
        @high_level2.add(@mid_level)
        @mid_level.add(@low_level)
        @mid_level.add(@low_level2)
      end
      it "list all descendants of first level up" do
        expect(@low_level.parents.include?(@mid_level)).to be_truthy
        expect(@low_level2.parents.include?(@mid_level)).to be_truthy
        expect(@mid_level.parents.include?(@high_level)).to be_truthy
        expect(@mid_level.parents.include?(@high_level2)).to be_truthy
      end
       it "list all descendants of second level up" do
        expect(@low_level.parents.include?(@high_level)).to be_truthy
        expect(@low_level2.parents.include?(@high_level2)).to be_truthy
        expect(@low_level2.parents.include?(@high_level)).to be_truthy
        expect(@low_level.parents.include?(@high_level2)).to be_truthy
      end
        before(:all) do
          @mid_level2 =create(:mid_level)
          @mid_level.add(@mid_level2)
          @mid_level3 =create(:mid_level)
          @mid_level2.add(@mid_level3)
          @low_level3 = create(:low_level)
          @mid_level3.add(@low_level3)
        end
        it "list all parents of N level up" do
        expect(@low_level3.parents.include?(@high_level)).to be_truthy
        expect(@low_level3.parents.include?(@high_level2)).to be_truthy
      end
    end
    
    describe "down_level" do
      before(:all) do
          @mid_level = create(:mid_level)
          @mid_level2 =create(:mid_level)
          @mid_level.add(@mid_level2)
          @mid_level3 =create(:mid_level)
          @mid_level2.add(@mid_level3)
        end
      
      it "calcule correct maximum down level" do
        expect(@mid_level.down_level).to eq(2)
        expect(@mid_level2.down_level).to eq(1)
        expect(@mid_level3.down_level).to eq(0)
      end
      before(:all) do
          @mid_level4 = create(:mid_level)
          @mid_level.add(@mid_level4)
      end
      it "calcule correct maximum down level for all branches" do
        expect(@mid_level.down_level).to eq(2)
        expect(@mid_level2.down_level).to eq(1)
        expect(@mid_level3.down_level).to eq(0)
        expect(@mid_level4.down_level).to eq(0)
      end
    end
    describe "up_level" do
      before(:all) do
          @mid_level = create(:mid_level)
          @mid_level2 =create(:mid_level)
          @mid_level.add(@mid_level2)
          @mid_level3 =create(:mid_level)
          @mid_level2.add(@mid_level3)
        end
      
      it "calcule correct maximum up level" do
        expect(@mid_level.up_level).to eq(0)
        expect(@mid_level2.up_level).to eq(1)
        expect(@mid_level3.up_level).to eq(2)
      end
      before(:all) do
          @mid_level4 = create(:mid_level)
          @mid_level4.add(@mid_level2)
      end
      it "calcule correct maximum down level for all branches" do
        expect(@mid_level.up_level).to eq(0)
        expect(@mid_level2.up_level).to eq(1)
        expect(@mid_level3.up_level).to eq(2)
        expect(@mid_level4.up_level).to eq(0)
      end
    end 
end
