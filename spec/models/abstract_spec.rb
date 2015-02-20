require 'rails_helper'

describe Polyscope::Abstract do
  describe 'instantiation' do
    it 'instantiates a polyscope_abstract' do
      expect(Polyscope::Abstract.create!.class.name).to eq("Polyscope::Abstract")
    end
  end
  
  describe 'add polyshape level -1' do
    before do
      @polyscope_abstract = create(:polyscope_abstract)
      @polyscope_middle = create(:polyscope_middle)
      @polyscope_abstract.add(@polyscope_middle)
    end
    it 'add a component' do
      expect(@polyscope_abstract.has?(@polyscope_middle)).to be_truthy
    end
    it 'add an abstract to a polyshape' do
      expect(@polyscope_middle.belongs_to?(@polyscope_abstract)).to be_truthy
    end
  end
  
  describe 'add polyshape level -2' do
    before(:all) do
      @polyscope_abstract = create(:polyscope_abstract)
      @polyscope_middle = create(:polyscope_middle)
      @polyscope_component = create(:polyscope_component)
      @polyscope_abstract.add(@polyscope_middle)
      @polyscope_middle.add(@polyscope_component)
    end
    it 'add a component' do
      expect(@polyscope_abstract.has?(@polyscope_middle)).to be_truthy
    end
    it 'add a component level -2' do
      expect(@polyscope_abstract.has?(@polyscope_component)).to be_truthy
    end
    it 'add an abstract to a polyshape level 1' do
      expect(@polyscope_middle.belongs_to?(@polyscope_abstract)).to be_truthy
    end
    it 'add an abstract to a polyshape level 2' do
      expect(@polyscope_component.belongs_to?(@polyscope_abstract)).to be_truthy
    end
    it 'give a down level of 2' do
      expect(@polyscope_abstract.down_level).to eq(2)
    end
    it 'give a down level of 1 to the component' do
      expect(@polyscope_middle.down_level).to eq(1)
    end
    it 'give a parent level of 1 to the component' do
      expect(@polyscope_middle.up_level).to eq(1)
    end
    it 'give a parent level of 2 to the component of component' do
      expect(@polyscope_component.up_level).to eq(2)
    end
  end
  
  describe "get the difference between empty object" do
      before(:all) do
        @r =  create(:polyscope_abstract)
        @r2 = create(:polyscope_abstract)
      end
      it "get maximal difference" do
        d = Polyscope::Abstract.compare(@r,@r2,Polyscope::Middle)
        expect(d[:distance]).to eq(1)
      end
      it "get maximal sorted difference" do
        d = Polyscope::Abstract.compare(@r,@r2,Polyscope::Middle)
        expect(d[:sorted_distance]).to eq(1)
      end
  end

  describe "get the difference of full object" do
      before(:all) do
      @r3 = create(:polyscope_abstract)
      @r4 = create(:polyscope_abstract)
      s = create(:polyscope_middle)
      @r3.add(s)
      @r4.add(s)
      @r5 = create(:polyscope_abstract)
      @r5.add(s)
      @r5.add(create(:polyscope_middle))
      end
      it "get the mimimal difference" do 
      d= Polyscope::Abstract.compare(@r3,@r4,Polyscope::Middle)
      expect(d[:distance]).to eq(0)
      end
      it "get the mimimal sorted difference" do 
      d= Polyscope::Abstract.compare(@r3,@r4,Polyscope::Middle)
      expect(d[:distance]).to eq(0)
      end
      it "get  0.5 difference" do 
      d= Polyscope::Abstract.compare(@r3,@r5,Polyscope::Middle)
      expect(d[:distance]).to eq(0.5)
      end
      it "get 0.5 sorted difference" do 
      d= Polyscope::Abstract.compare(@r3,@r5,Polyscope::Middle)
      expect(d[:distance]).to eq(0.5)
      end
    end
    
    describe "polyscope" do
      before do
      @polyscope_abstract = create(:polyscope_abstract)
      @polyscope_middle = create(:polyscope_middle)
      @polyscope_component = create(:polyscope_component)
      @polyscope_abstract.add(@polyscope_middle)
      @polyscope_middle.add(@polyscope_component)
      end
      it "gives 2 dimensions value" do
      d = @polyscope_abstract.polyscope(@polyscope_middle)
      expect(d[:dimensions][:"polyscope/middle"]).to_not be_nil
      expect(d[:dimensions][:"polyscope/component"]).to_not be_nil
      end
      it "gives correct value" do
      d = @polyscope_abstract.polyscope(Polyscope::Abstract.create)
      expect(d[:dimensions][:"polyscope/middle"][:distance]).to eq(1)
      expect(d[:dimensions][:"polyscope/component"][:distance]).to eq(1)
      expect(d[:dimensions][:"polyscope/middle"][:sorted_distance]).to eq(1)
      d[:distance].should be > 1.4
      d[:sorted_distance].should be > 1.4
      d[:distance].should be < 1.5
      d[:sorted_distance].should be < 1.5
      end
    end
    describe "copy" do
      before(:all) do
        @polyscope_abstract = create(:polyscope_abstract, :name => "My polyscope_abstract name")
        @polyscope_middle = create(:polyscope_middle, :name => "this is a polyscope_middle name")
        @polyscope_component = create(:polyscope_component)
        @polyscope_middle.add(@polyscope_component)
        @polyscope_abstract.add(@polyscope_middle)
        @copy = Polyscope::Middle.copy(@polyscope_middle)
      end
      it "creates a new identical instance" do
        expect(@copy.name).to eq(@polyscope_middle.name)
      end
      it "create the same children structure" do
        expect(@copy.all).to eq(@polyscope_middle.all)
      end
      it "create the same parents structure" do
          expect(@copy.parents).to eq(@polyscope_middle.parents)
      end
    end
    
    describe "instance_of" do
      before do
        @polyscope_abstract = create(:polyscope_abstract)
        @polyscope_middle = create(:polyscope_middle)
        @polyscope_component = create(:polyscope_component)
        @polyscope_abstract.add(@polyscope_middle)
        @polyscope_middle.add(@polyscope_component)
      end
      it "shows 1 instance of" do
        p = @polyscope_abstract.instance_of(Polyscope::Middle)
        expect(p.count).to eq(1)
      end
      it "shows 2 instances of type" do
        @polyscope_abstract.add(@polyscope_middle)
        p = @polyscope_abstract.instance_of(Polyscope::Middle)
        expect(p.count).to eq(2)
      end
      it "doesnt count instances of type of child" do
        p = @polyscope_abstract.instance_of(Polyscope::Component)
        expect(p.count).to eq(0)
      end
    end
  
    describe "Common" do
      before(:all) do
        @polyscope_abstract = create(:polyscope_abstract)
        @polyscope_middle = create(:polyscope_middle)
        @polyscope_component = create(:polyscope_component)
        @polyscope_abstract.add(@polyscope_middle)
        @polyscope_middle.add(@polyscope_component)
        @polyscope_abstract2 = Polyscope::Abstract.copy(@polyscope_abstract)
        @polyscope_middle2 = create(:polyscope_middle)
        @polyscope_middle2.add(@polyscope_component)
        @polyscope_abstract2.add(@polyscope_middle2)
      end
      it "gives the intersection of shapes" do
        expect(@polyscope_abstract.intersect(@polyscope_abstract2).include?(@polyscope_component)).to be_truthy
        expect(@polyscope_abstract.intersect(@polyscope_abstract2).include?(@polyscope_middle)).to be_truthy
      end
      it "doesnt gives what is not in intersection" do
        expect(@polyscope_abstract.intersect(@polyscope_abstract2).include?(@polyscope_middle2)).to be_falsey
      end
    end
    describe "Down" do
      before(:all) do
        @polyscope_abstract = create(:polyscope_abstract)
        @polyscope_middle = create(:polyscope_middle)
        @polyscope_middle2 = create(:polyscope_middle)
        @polyscope_component = create(:polyscope_component)
        @polyscope_abstract.add(@polyscope_middle)
        @polyscope_abstract.add(@polyscope_middle2)
        @polyscope_middle.add(@polyscope_component)
      end
      
      it "doesnt list the second level down" do
        expect(@polyscope_abstract.down.include?(@polyscope_component)).to be_falsey      
      end
      it "lists the first level down" do
        expect(@polyscope_abstract.down.include?(@polyscope_middle)).to be_truthy
        expect(@polyscope_abstract.down.include?(@polyscope_middle2)).to be_truthy
      end
      it "doesnt list the level up" do
        expect(@polyscope_middle.down.include?(@polyscope_abstract)).to be_falsey
      end
    end
    
    describe "Up" do
      before(:all) do
        @polyscope_abstract = create(:polyscope_abstract)
        @polyscope_middle = create(:polyscope_middle)
        @polyscope_middle2 = create(:polyscope_middle)
        @polyscope_component = create(:polyscope_component)
        @polyscope_abstract.add(@polyscope_middle)
        @polyscope_abstract.add(@polyscope_middle2)
        @polyscope_middle.add(@polyscope_component)
      end
      
      it "doesnt list the second level up" do
        expect(@polyscope_component.up.include?(@polyscope_abstract)).to be_falsey      
      end
      it "lists the first level up" do
        expect(@polyscope_component.up.include?(@polyscope_middle)).to be_truthy
        expect(@polyscope_middle.up.include?(@polyscope_abstract)).to be_truthy
      end
      it "doesnt list the level down" do
        expect(@polyscope_middle.up.include?(@polyscope_component)).to be_falsey
      end
    end
    
    describe "All" do
      before(:all) do
        @polyscope_abstract = create(:polyscope_abstract)
        @polyscope_abstract2 = create(:polyscope_abstract)
        @polyscope_middle = create(:polyscope_middle)
        @polyscope_component = create(:polyscope_component)
        @polyscope_component2 = create(:polyscope_component)
        @polyscope_abstract.add(@polyscope_middle)
        @polyscope_abstract2.add(@polyscope_middle)
        @polyscope_middle.add(@polyscope_component)
        @polyscope_middle.add(@polyscope_component2)
      end
      it "list all descendants of first level down" do
        expect(@polyscope_middle.all.include?(@polyscope_component)).to be_truthy
        expect(@polyscope_middle.all.include?(@polyscope_component2)).to be_truthy
        expect(@polyscope_abstract.all.include?(@polyscope_middle)).to be_truthy
        expect(@polyscope_abstract2.all.include?(@polyscope_middle)).to be_truthy
      end
       it "list all descendants of second level down" do
        expect(@polyscope_abstract.all.include?(@polyscope_component)).to be_truthy
        expect(@polyscope_abstract2.all.include?(@polyscope_component2)).to be_truthy
      end
        before(:all) do
          @polyscope_middle2 =create(:polyscope_middle)
          @polyscope_middle.add(@polyscope_middle2)
          @polyscope_middle3 =create(:polyscope_middle)
          @polyscope_middle2.add(@polyscope_middle3)
          @polyscope_component3 = create(:polyscope_component)
          @polyscope_middle3.add(@polyscope_component3)
        end
        it "list all descendants of N level down" do
        expect(@polyscope_abstract.all.include?(@polyscope_component3)).to be_truthy
        expect(@polyscope_abstract2.all.include?(@polyscope_component3)).to be_truthy
      end
    end
    describe "parents" do
      before(:all) do
        @polyscope_abstract = create(:polyscope_abstract)
        @polyscope_abstract2 = create(:polyscope_abstract)
        @polyscope_middle = create(:polyscope_middle)
        @polyscope_component = create(:polyscope_component)
        @polyscope_component2 = create(:polyscope_component)
        @polyscope_abstract.add(@polyscope_middle)
        @polyscope_abstract2.add(@polyscope_middle)
        @polyscope_middle.add(@polyscope_component)
        @polyscope_middle.add(@polyscope_component2)
      end
      it "list all descendants of first level up" do
        expect(@polyscope_component.parents.include?(@polyscope_middle)).to be_truthy
        expect(@polyscope_component2.parents.include?(@polyscope_middle)).to be_truthy
        expect(@polyscope_middle.parents.include?(@polyscope_abstract)).to be_truthy
        expect(@polyscope_middle.parents.include?(@polyscope_abstract2)).to be_truthy
      end
       it "list all descendants of second level up" do
        expect(@polyscope_component.parents.include?(@polyscope_abstract)).to be_truthy
        expect(@polyscope_component2.parents.include?(@polyscope_abstract2)).to be_truthy
        expect(@polyscope_component2.parents.include?(@polyscope_abstract)).to be_truthy
        expect(@polyscope_component.parents.include?(@polyscope_abstract2)).to be_truthy
      end
        before(:all) do
          @polyscope_middle2 =create(:polyscope_middle)
          @polyscope_middle.add(@polyscope_middle2)
          @polyscope_middle3 =create(:polyscope_middle)
          @polyscope_middle2.add(@polyscope_middle3)
          @polyscope_component3 = create(:polyscope_component)
          @polyscope_middle3.add(@polyscope_component3)
        end
        it "list all parents of N level up" do
        expect(@polyscope_component3.parents.include?(@polyscope_abstract)).to be_truthy
        expect(@polyscope_component3.parents.include?(@polyscope_abstract2)).to be_truthy
      end
    end
    
    describe "down_level" do
      before(:all) do
          @polyscope_middle = create(:polyscope_middle)
          @polyscope_middle2 =create(:polyscope_middle)
          @polyscope_middle.add(@polyscope_middle2)
          @polyscope_middle3 =create(:polyscope_middle)
          @polyscope_middle2.add(@polyscope_middle3)
        end
      
      it "calcule correct maximum down level" do
        expect(@polyscope_middle.down_level).to eq(2)
        expect(@polyscope_middle2.down_level).to eq(1)
        expect(@polyscope_middle3.down_level).to eq(0)
      end
      before(:all) do
          @polyscope_middle4 = create(:polyscope_middle)
          @polyscope_middle.add(@polyscope_middle4)
      end
      it "calcule correct maximum down level for all branches" do
        expect(@polyscope_middle.down_level).to eq(2)
        expect(@polyscope_middle2.down_level).to eq(1)
        expect(@polyscope_middle3.down_level).to eq(0)
        expect(@polyscope_middle4.down_level).to eq(0)
      end
    end
    describe "up_level" do
      before(:all) do
          @polyscope_middle = create(:polyscope_middle)
          @polyscope_middle2 =create(:polyscope_middle)
          @polyscope_middle.add(@polyscope_middle2)
          @polyscope_middle3 =create(:polyscope_middle)
          @polyscope_middle2.add(@polyscope_middle3)
        end
      
      it "calcule correct maximum up level" do
        expect(@polyscope_middle.up_level).to eq(0)
        expect(@polyscope_middle2.up_level).to eq(1)
        expect(@polyscope_middle3.up_level).to eq(2)
      end
      before(:all) do
          @polyscope_middle4 = create(:polyscope_middle)
          @polyscope_middle4.add(@polyscope_middle2)
      end
      it "calcule correct maximum down level for all branches" do
        expect(@polyscope_middle.up_level).to eq(0)
        expect(@polyscope_middle2.up_level).to eq(1)
        expect(@polyscope_middle3.up_level).to eq(2)
        expect(@polyscope_middle4.up_level).to eq(0)
      end
    end 
end
