require 'active_support/concern'
module ActsAsComponent
  extend ActiveSupport::Concern
  included do
      extend ClassMethods
      has_many :abstracts, :as => :component, :dependent => :destroy, :class_name => 'Polyscope::Edge'
  end
  module ClassMethods
    def copy (resource)
         clone = resource.class.new
         resource.attributes.each do |attr_name, attr_value|
         clone.update_attribute(attr_name,attr_value) if attr_name != "id"
         end
         clone.save!
         clone.copy_structure(resource,:up)
         return clone
    end
    def create_resource(object_name)
      resource = object_name.to_s.capitalize.constantize if object_name != :all
      return resource || :all
    end
  end

  def copy_structure_up(resource)
      resource.abstracts.each do |a|
        abstract = c.class.new(:component_id=>id,:component_type=>self.class.name)
        component.update_attributes(:abstract_id=>c.abstract_id,:abstract_type=>c.abstract_type)
        abstract.save!
      end
  end
  def up
      list = Array.new
      self.abstracts.each {|a| list << create_resource(a.abstract_type).find(a.abstract_id)}
      return list.compact
  end
  def parents (resource=:all,list = Array.new)
      abstract_list = Array.new
      abstracts.each do |c|
         abstract = create_resource(c.abstract_type).find(c.abstract_id)
         specific_abstract = resource.find(c.abstract_id) if resource!=:all && c.abstract_type ==resource.name
         list << abstract if abstract.present? && resource==:all
         list << specific_abstract if specific_abstract.present?
         abstract_list << abstract if abstract.has_components?
         abstract_list.each do |a|
         result = a.parents(resource,Array.new) if a.is_component?
         result.each {|e| list << e} if result
         end
      end
      return  list.compact
  end
  def down_level(resource=:all, level=0)
    return level
  end
  def up_level(resource=:all, level=0)
      return level if !has_abstracts?
      level+=1
      level_array = Array.new
      up.uniq.each do |c|
         if resource!=:all && c.class.name ==resource.name
         parent = c
         elsif resource==:all
         parent = c
         end
         if parent && parent.is_component?
          level_array << parent.up_level(resource,level) if parent#code
         else
         return level
         end
      end
      return level_array.max
  end
  def up_list (resource=:all, limit=100, level=0, list=Hash.new)
      return if !has_abstracts?
      return if level > limit
      level +=1
      up.uniq.each do |c|
         parent = nil
         if resource!=:all && c.class.name ==resource.name
            parent = c.up_list(resource,limit,level, list) if c.has_abstracts?
         elsif resource==:all
            parent= c.up_list(resource,limit,level, list) if c.has_abstracts?
         end
      list[parent[0]]=Array.new if parent && parent[0] && list[parent[0]].nil?
      list[parent[0]]<<parent[1] if parent && parent[0]
      end
      list[level]=Array.new if list[level].nil?
      list[level] << up.uniq[0]
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
  def has_abstracts?
     abstracts_count>=1
  end
  def has_components?
     false
  end
  def abstracts_count
     return Polyscope::Edge.where(:component_type => self.class,:component_id => self.id).count
  end
   def belongs_to?(other)
      parents.include?(other)
   end
  def dependancy
   up_count
  end
  def up_count
      parents.count
  end
  def size
    up_level
  end
  def create_resource(object_name)
  resource = object_name.to_s.capitalize.constantize if object_name != :all
  return resource || :all
  end
end
