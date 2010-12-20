class TopItem < ActiveRecord::Base
  belongs_to :item, :polymorphic => true
  belongs_to :person

  ITEMS = [:contribution]
  ITEMS.each do |assoc|
    belongs_to assoc, :foreign_key => :item_id, :conditions => {:item_type => assoc.to_s.classify}
  end
  
  before_create :set_item_created_at
  before_create :set_item_recent_rating, :if => :item_rateable?
  before_create :set_item_recent_visits, :if => :item_visitable?

  def self.for(for_item, options={})
    if for_item.is_a?(Hash)
      for_item_type = for_item.keys[0]
      for_item_id = for_item[for_item_type]
    else
      for_item_type = for_item
      for_item_id = nil
    end

    # for :conversation means:
    # a) top_items[:item_type] or
    # b) top_items[:item][:conversation_id] IS NOT NULL
    #
    # For :person means:
    # item has person and person_id = :person_id
    
    # direct_items for (a)
    direct_items = self.includes(:item).where(:item_type => for_item_type.to_s.classify)
    direct_items.where(:item_id => for_item_id) if for_item_id

    # associated_items for (b)
    top_items = TopItem.arel_table
    ITEMS.each do |item|
      item_table = Arel::Table.new(item.to_s.pluralize)
      for_item_column_id = item.to_s.classify.constantize.
        reflect_on_association(for_item_type).options[:foreign_key] ||
        "#{for_item_type}_id"

      top_items = top_items.
        join(item_table).
        on(
           top_items[:item_id].eq( item_table[:id] ),
           top_items[:item_type].eq( item.to_s.classify ),
           item_table[for_item_column_id].not_eq( nil )
          )
      top_items = top_items.where( item_table[for_item_column_id].eq( for_item_id ) ) if for_item_id
      top_items = top_items.where( options.collect{ |key,value| item_table[key].eq( value ) } )
    end
    associated_items = TopItem.find_by_sql( top_items.to_sql )

    #p top_items.to_sql
    return direct_items | associated_items
  end
  
  def self.newest_items(limit=10)
    self.order("item_created_at DESC").limit(limit)
  end
  
  def TopItem.highest_rated(limit=10)
    self.order("recent_rating DESC").limit(limit)
  end
  
  def TopItem.most_visited(limit=10)
    self.order("recent_visits DESC").limit(limit)
  end
  
  protected
  
  def item_rateable?
    self.item.respond_to?(:recent_rating)
  end
  
  def item_visitable?
    self.item.respond_to?(:recent_visits)
  end
  
  def set_item_created_at
    self.item_created_at = self.item.created_at
  end
  
  def set_item_recent_rating
    self.recent_rating = self.item.recent_rating
  end
  
  def set_item_recent_visits
    self.recent_visits = self.item.recent_visits
  end
end
