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
   describe 'add polyshape level -1' do
    before do
      @polyscope_component = create(:polyscope_component)
      @polyscope_middle = create(:polyscope_middle)
      @polyscope_middle.add(@polyscope_component)
    end
    it 'add a component' do
      expect(@polyscope_middle.has?(@polyscope_component)).to be_truthy
    end
    it 'add an abstract to a polyshape' do
      expect(@polyscope_component.belongs_to?(@polyscope_middle)).to be_truthy
    end
  end
  
  describe 'add polyshape level -2' do
    before(:all) do
      @polyscope_middle = create(:polyscope_middle)
      @polyscope_middle2 = create(:polyscope_middle)
      @polyscope_component = create(:polyscope_component)
      @polyscope_middle.add(@polyscope_middle2)
      @polyscope_middle2.add(@polyscope_component)
    end
    it 'add a component' do
      expect(@polyscope_middle.has?(@polyscope_middle2)).to be_truthy
    end
    it 'add a component level -2' do
      expect(@polyscope_middle.has?(@polyscope_component)).to be_truthy
    end
    it 'add an abstract to a polyshape level 1' do
      expect(@polyscope_middle2.belongs_to?(@polyscope_middle)).to be_truthy
    end
    it 'add an abstract to a polyshape level 2' do
      expect(@polyscope_component.belongs_to?(@polyscope_middle)).to be_truthy
    end
    it 'give a down level of 2' do
      expect(@polyscope_middle.down_level).to eq(2)
    end
    it 'give a down level of 1 to the component' do
      expect(@polyscope_middle2.down_level).to eq(1)
    end
    it 'give a parent level of 1 to the component' do
      expect(@polyscope_middle2.up_level).to eq(1)
    end
    it 'give a parent level of 2 to the component of component' do
      expect(@polyscope_component.up_level).to eq(2)
    end
  end
  
  describe "get the difference between empty object" do
      before(:all) do
        @r =  create(:polyscope_middle)
        @r2 = create(:polyscope_middle)
      end
      it "get maximal difference" do
        d = Polyscope::Middle.compare(@r,@r2,Polyscope::Middle)
        expect(d[:distance]).to eq(1)
      end
      it "get maximal sorted difference" do
        d = Polyscope::Middle.compare(@r,@r2,Polyscope::Middle)
        expect(d[:sorted_distance]).to eq(1)
      end
  end

  describe "get the difference of full object" do
      before(:all) do
      @m = create(:polyscope_middle)
      @m2 = create(:polyscope_middle)
      s = create(:polyscope_middle)
      @m.add(s)
      @m2.add(s)
      @m3 = create(:polyscope_middle)
      @m3.add(s)
      @m3.add(create(:polyscope_middle))
      end
      it "get the mimimal difference" do 
      d= Polyscope::Abstract.compare(@m,@m2,Polyscope::Middle)
      expect(d[:distance]).to eq(0)
      end
      it "get the mimimal sorted difference" do 
      d= Polyscope::Abstract.compare(@m,@m2,Polyscope::Middle)
      expect(d[:distance]).to eq(0)
      end
      it "get  0.5 difference" do 
      d= Polyscope::Abstract.compare(@m,@m3,Polyscope::Middle)
      expect(d[:distance]).to eq(0.5)
      end
      it "get 0.5 sorted difference" do 
      d= Polyscope::Abstract.compare(@m,@m3,Polyscope::Middle)
      expect(d[:distance]).to eq(0.5)
      end
    end
    
    describe "polyscope" do
      before do
      @polyscope_middle = create(:polyscope_middle)
      @polyscope_middle2 = create(:polyscope_middle)
      @polyscope_component = create(:polyscope_component)
      @polyscope_middle.add(@polyscope_middle2)
      @polyscope_middle2.add(@polyscope_component)
      end
      it "gives 2 dimensions value" do
      d = @polyscope_middle.polyscope(@polyscope_middle2)
      expect(d[:dimensions][:"polyscope/middle"]).to_not be_nil
      expect(d[:dimensions][:"polyscope/component"]).to_not be_nil
      end
      it "gives correct value" do
      d = @polyscope_middle.polyscope(Polyscope::Middle.create)
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
        @polyscope_middle = create(:polyscope_middle, :name => "My polyscope_abstract name")
        @polyscope_middle2 = create(:polyscope_middle, :name => "this is a polyscope_middle name")
        @polyscope_component = create(:polyscope_component)
        @polyscope_middle2.add(@polyscope_component)
        @polyscope_middle.add(@polyscope_middle2)
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
        @polyscope_middle = create(:polyscope_middle)
        @polyscope_middle2 = create(:polyscope_middle)
        @polyscope_component = create(:polyscope_component)
        @polyscope_middle.add(@polyscope_middle2)
        @polyscope_middle2.add(@polyscope_component)
      end
      it "shows 1 instance of" do
        p = @polyscope_middle.instance_of(Polyscope::Middle)
        expect(p.count).to eq(1)
      end
      it "shows 2 instances of type" do
        @polyscope_middle.add(Polyscope::Middle.create)
        p = @polyscope_middle.instance_of(Polyscope::Middle)
        expect(p.count).to eq(2)
      end
      it "doesnt count instances of type of child" do
        p = @polyscope_middle.instance_of(Polyscope::Component)
        expect(p.count).to eq(0)
      end
    end
  
    describe "Common" do
      before(:all) do
        @polyscope_middle1 = create(:polyscope_middle)
        @polyscope_middle11 = create(:polyscope_middle)
        @polyscope_component1 = create(:polyscope_component)
        @polyscope_middle1.add(@polyscope_middle11)
        @polyscope_middle1.add(@polyscope_component1)
        @polyscope_middle2 = Polyscope::Middle.copy(@polyscope_middle1)
        @polyscope_middle22 = create(:polyscope_middle)
        @polyscope_middle22.add(@polyscope_component1)
        @polyscope_middle2.add(@polyscope_middle22)
      end
      it "gives the intersection of shapes" do
        expect(@polyscope_middle1.intersect(@polyscope_middle2).include?(@polyscope_component1)).to be_truthy
        expect(@polyscope_middle1.intersect(@polyscope_middle2).include?(@polyscope_middle11)).to be_truthy
      end
      it "doesnt gives what is not in intersection" do
        expect(@polyscope_middle1.intersect(@polyscope_middle2).include?(@polyscope_middle22)).to be_falsey
      end
    end
    describe "Down" do
      before(:all) do
        @polyscope_middle = create(:polyscope_middle)
        @polyscope_middle2 = create(:polyscope_middle)
        @polyscope_middle3 = create(:polyscope_middle)
        @polyscope_component = create(:polyscope_component)
        @polyscope_middle.add(@polyscope_middle2)
        @polyscope_middle.add(@polyscope_middle3)
        @polyscope_middle2.add(@polyscope_component)
      end
      
      it "doesnt list the second level down" do
        expect(@polyscope_middle.down.include?(@polyscope_component)).to be_falsey      
      end
      it "lists the first level down" do
        expect(@polyscope_middle.down.include?(@polyscope_middle2)).to be_truthy
        expect(@polyscope_middle.down.include?(@polyscope_middle3)).to be_truthy
      end
      it "doesnt list the level up" do
        expect(@polyscope_middle2.down.include?(@polyscope_middle)).to be_falsey
      end
    end
    
   describe "Up" do
      before(:all) do
        @polyscope_middle = create(:polyscope_middle)
        @polyscope_middle2 = create(:polyscope_middle)
        @polyscope_middle3 = create(:polyscope_middle)
        @polyscope_component = create(:polyscope_component)
        @polyscope_middle.add(@polyscope_middle2)
        @polyscope_middle.add(@polyscope_middle3)
        @polyscope_middle2.add(@polyscope_component)
      end
      
      it "doesnt list the second level up" do
        expect(@polyscope_component.up.include?(@polyscope_middle)).to be_falsey      
      end
      it "lists the first level up" do
        expect(@polyscope_component.up.include?(@polyscope_middle2)).to be_truthy
        expect(@polyscope_middle2.up.include?(@polyscope_middle)).to be_truthy
      end
      it "doesnt list the level down" do
        expect(@polyscope_middle.up.include?(@polyscope_component)).to be_falsey
      end
    end
    
    describe "All" do
      before(:all) do
        @m = create(:polyscope_middle)
        @m2 = create(:polyscope_middle)
        @m3 = create(:polyscope_middle)
        @c = create(:polyscope_component)
        @c2 = create(:polyscope_component)
        @m.add(@m3)
        @m2.add(@m3)
        @m3.add(@c)
        @m3.add(@c2)
      end
      it "list all descendants of first level down" do
        expect(@m3.all.include?(@c)).to be_truthy
        expect(@m3.all.include?(@c2)).to be_truthy
        expect(@m.all.include?(@m3)).to be_truthy
        expect(@m2.all.include?(@m3)).to be_truthy
      end
       it "list all descendants of second level down" do
        expect(@m.all.include?(@c)).to be_truthy
        expect(@m2.all.include?(@c2)).to be_truthy
      end
    end
    describe "All" do
        before(:all) do
          @m3 = create(:polyscope_middle)
          @m2 = create(:polyscope_middle)
          @m = create(:polyscope_middle)
          @m.add(@m2)
          @m2.add(@m3)
          @c = create(:polyscope_component)
          @m3.add(@c)
        end
        it "list all descendants of N level down" do
        expect(@m.all.include?(@m3)).to be_truthy
        expect(@m.all.include?(@c)).to be_truthy
      end
    end
    describe "parents" do
       before(:all) do
          @polyscope_middle3 = create(:polyscope_middle)
          @polyscope_middle2 = create(:polyscope_middle)
          @polyscope_middle = create(:polyscope_middle)
          @polyscope_middle.add(@polyscope_middle2)
          @polyscope_middle2.add(@polyscope_middle3)
          @polyscope_component = create(:polyscope_component)
          @polyscope_component2 = create(:polyscope_component)
          @polyscope_middle3.add(@polyscope_component)
          @polyscope_middle2.add(@polyscope_component2)
        end
      it "list all parents of first level up" do
        expect(@polyscope_component.parents.include?(@polyscope_middle3)).to be_truthy
        expect(@polyscope_component2.parents.include?(@polyscope_middle2)).to be_truthy
        expect(@polyscope_middle2.parents.include?(@polyscope_middle)).to be_truthy
        expect(@polyscope_middle3.parents.include?(@polyscope_middle2)).to be_truthy
      end
       it "list all parents of second level up" do
        expect(@polyscope_component.parents.include?(@polyscope_middle2)).to be_truthy
        expect(@polyscope_component2.parents.include?(@polyscope_middle)).to be_truthy
        expect(@polyscope_middle3.parents.include?(@polyscope_middle)).to be_truthy
      end
     end
      describe "parents" do
        before(:all) do
          @polyscope_middle3 = create(:polyscope_middle)
          @polyscope_middle2 = create(:polyscope_middle)
          @polyscope_middle = create(:polyscope_middle)
          @polyscope_middle.add(@polyscope_middle2)
          @polyscope_middle2.add(@polyscope_middle3)
          @polyscope_component = create(:polyscope_component)
          @polyscope_middle3.add(@polyscope_component)
        end
        it "list all parents of N level up" do
        expect(@polyscope_component.parents.include?(@polyscope_middle)).to be_truthy
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
