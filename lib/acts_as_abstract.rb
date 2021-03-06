require 'active_support/concern'
require "matrix"
module ActsAsAbstract
  extend ActiveSupport::Concern
  included do
    extend ClassMethods
      has_many :components, :as => :abstract, :dependent => :destroy, :class_name => 'Polyscope::Edge'
      has_one :shapes, :as => :shape, :dependent => :destroy, :class_name => 'Polyscope::Shaper'
  end
  def self.included(base)
    @classes ||= []
    @classes << base.name
  end

  def self.classes
    @classes
  end
  module ClassMethods
      def update_diffs
         self.all.each do |p|
           p.diff
         end
      end
     
      def copy (resource)
         clone = resource.class.new
         resource.attributes.each do |attr_name, attr_value|
         clone.update_attribute(attr_name,attr_value) if attr_name != "id"
         end
         clone.save!
         clone.copy_structure(resource)
         return clone
      end

      def distance(s, t,d=nil)
          m = s.length
          n = t.length
          return 1 if n == 0
          return 1 if m == 0
          d = Array.new(m+1) {Array.new(n+1)} if d.nil?
        
          (0..m).each {|i| d[i][0] = i}
          (0..n).each {|j| d[0][j] = j}
          (1..n).each do |j|
            (1..m).each do |i|
              d[i][j] = if s[i-1].is_a?(t[j-1].class) && s[i-1] == t[j-1]  # adjust index into string
                          d[i-1][j-1]       # no operation required
                        else
                          [ d[i-1][j]+1,    # deletion
                            d[i][j-1]+1,    # insertion
                            d[i-1][j-1]+1,  # substitution
                          ].min
                        end
            end
          end
          (d[m][n].to_f/[m,n].max)
    
      end

      def compare(r1,r2, res=r1.class.name)
        resource = self.create_resource(res)
        result = Hash.new
          set1 = r1.all(resource)
          set2 = r2.all(resource)
          result[:distance] = self.distance(set1,set2).round(3)
          result[:sorted_distance] = self.distance(set1.sort!,set2.sort!).round(3)
          return result
      end
      def create_resource(object_name)
      resource = object_name.to_s.camelize.constantize if object_name != :all
      return resource || :all
      end
  end
  def diff
      if shapes.nil?
            self.shapes=ShapeManager.create!(:shape_id=>id,:shape_type=>self.class.name)
      end
      self.class.all.each do |q|
         self.shapes.diffs[q.id] = self.class.compare(self,q)[:distance].round(3)
      end
      self.shapes.save
      return
  end
   def copy_structure(resource)
          copy_structure_up(resource) if is_component?
          copy_structure_down(resource) if is_abstract?
   end
   def copy_structure_down(resource)
            resource.components.each do |c|
               component = c.class.new(:abstract_id=>id,:abstract_type=>self.class.name)
               component.update_attributes(:component_id=>c.component_id,:component_type=>c.component_type)
            component.save!
            end
   end
   def intersect(r2)
        set1 = all
        set2 = r2.all
        (set1 & set2).compact
   end
   def polyscope(r2)
        s =dim(r2)
        result = Hash.new
        v1 = Array.new
        v2 = Array.new
        h = Hash.new
        s.each do |d|
          values = self.class.compare(self,r2,d)
          h[d.underscore.to_sym]=values
          v1 << values[:distance].round(3)
          v2 << values[:sorted_distance].round(3)
        end
        result[:dimensions]=h
        result[:distance]=Vector.elements(v1,true).r
        result[:sorted_distance]=Vector.elements(v2,true).r
        return result
   end
   def dim(r2)
        c1 = Array.new
        c2 = Array.new
        all.each {|a| c1 << a.class.name}
        r2.all.each {|a| c2 << a.class.name}
        return c1|c2
   end
   def add(part)
      if self == part
        raise("Can't add itself as part")
      end
      if part.has_components? && !part.all.nil? && part.all.include?(self)
        raise("Children as itself as part")
      end
      if is_component? && parents.include?(part)
        raise("Can't add a parent as part")
      end
      a = Polyscope::Edge.create!(:abstract_id=> self.id, :abstract_type=>self.class, :component_id => part.id,  :component_type=> part.class)
      self.components << a
   end
   def instance_of(resource)
      list = Array.new
      self.components.each {|c| list << resource.find(c.component_id) if c.component_type ==resource.name}
      return list
   end
   def down
      list = Array.new
      self.components.each {|c| list << create_resource(c.component_type).find(c.component_id)}
      return list.compact
   end
   def all (resource=:all,list = Array.new)
         abstract_list = Array.new
         components.each do |c|
            part = create_resource(c.component_type).find(c.component_id)
            specific_part = resource.find(c.component_id) if resource!=:all && c.component_type ==resource.name
            list << part if part.present? && resource==:all
            list << specific_part if specific_part.present?
            abstract_list << part if part.has_components?
         end
         abstract_list.each do |a|
            result = a.all(resource,Array.new)
            result.each {|e| list << e} if result
         end
      return  list.compact
   end
   def format(list,format_list=Array.new,level=1)
      abstract_list = Array.new
      list.each do |c|
         abstract_list << c if c.has_components?
         format_list << [c,level]
      end
      result = format(abstract_list,format_list,level+1) if abstract_list.any?
      result.each {|e| format_list << e} if result
      format_list
   end
   def down_level(resource=:all, level=0)
      return level if !has_components?
      level+=1
      level_array = Array.new
      down.uniq.each do |c|
         if resource!=:all && c.class.name ==resource.name
         part = c
         elsif resource==:all
         part = c
         end
         level_array << part.down_level(resource,level) if part
      end
      return level_array.max
   end
   def down_list (resource=:all, limit=-100, level=0, list=Hash.new)
      return if !has_components?
      return if level < limit
      level -=1
      down.uniq.each do |c|
         child = nil
         if resource!=:all && c.class.name ==resource.name
            child = c.down_list(resource,limit,level, list) if c.has_components?
         elsif resource==:all
            child= c.down_list(resource,limit,level, list) if c.has_components?
         end
      list[child[0]]=Array.new if child && child[0] && list[child[0]].nil?
      list[child[0]]<<child[1] if child && child[0]
      end
      list[-down_level]=Array.new if list[down_level].nil?
      list[-down_level] << down.uniq[0]
      return  list
   end
   def is_abstract?
    s = self.class.ancestors.select {|o| o.class == Module }
    s.include?(ActsAsAbstract)
   end
   def is_component?
    s = self.class.ancestors.select {|o| o.class == Module }
    s.include?(ActsAsComponent)
   end
   def has_components?
     is_abstract_count>=1
   end
   def is_abstract_count
     return Polyscope::Edge.where(:abstract_type => self.class,:abstract_id => self.id).count
   end
   def dependancy
     down_count
   end
   def down_count
      all.count
   end
   def size
      down_level
   end
   
   def print (limit=-100, level=0)
      return self if !has_components?
      return if level < limit
      level -=1
      list = Hash.new
      child = Hash.new
      down.each_with_index do |c,index|
         child[index+1]= c.print(limit,level)
      end
      list[:parent]=self
      list[:child] =  child if !child.empty?
      return  list
   end
   def all_diffs
      d = Array.new
      resource = self.class
      set1 = all(resource)
      matrix =  create_matrix(set1,1)
      self.class.all.each do |e|
         set2 = e.all(resource)
         if set2.length>matrix.length
            matrix = create_matrix(set2,2)
         end
      d << self.class.distance(set1,set2,matrix).round(3)
      end
      return d
   end
   def all_diffs2
      d = Array.new
      resource = self.class
      set1 = all(resource)
      self.class.all.each do |e|
         set2 = e.all(resource)
      d << self.class.distance(set1,set2).round(3)
      end
      return d
   end
   def create_matrix(s,l=1)
      Array.new(l*s.length) {Array.new(l*s.length)}
   end
   def find_by_index(s,t)
      d =Array.new
      Diff.where("first_id=? AND diff>=? AND diff<=?",id,s,t).all.each {|e| d<< e.second_id}
      Diff.where("second_id=? AND diff>=? AND diff<=?",id,s,t).all.each {|e| d<< e.first_id}
      return d
   end
   def find_by_hash(s,t)
      d = Array.new
      shapes.diffs.each {|e| d<<e[0] if e[1]>=s && e[1]<=t }
      return d
   end
   
   def has?(other)
      all.include?(other)
   end
   
   def create_resource(object_name)
   resource = object_name.to_s.camelize.constantize if object_name != :all
   return resource || :all
   end
   def polyshape
     true
   end
   def compare_read_diffs
      t1 = Time.now
      all_diffs
      t2 = Time.now
      fetch_diffs
      t3 = Time.now
      all_diffs2
      t4 = Time.now
      shapes.diffs
      t5 = Time.now
      h = Hash.new
      index=(t3-t2)
      flexible_matrix=(t2-t1)
      fix_matrix=(t4-t3)
      hash_read=(t5-t4)
      optimal = [fix_matrix,flexible_matrix].min
      h = {:index=>index,:hash_read=>hash_read, :flexible_matrix=>flexible_matrix,:optimal_vs_index=>(optimal)/(index),:fix_matrix=>(fix_matrix),:flexible_vs_fix=>(flexible_matrix)/(fix_matrix)}
   end 
end
