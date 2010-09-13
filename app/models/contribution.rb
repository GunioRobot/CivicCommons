require 'parent_validator'

class Contribution < ActiveRecord::Base
  include Rateable
  include Visitable
  include TopItemable
  
  belongs_to :person, :foreign_key => "owner"
  belongs_to :conversation
  belongs_to :issue
  
  acts_as_tree :foreign_key => 'contribution_id'
  
  validates_with ContributionValidator
  validates :content, :presence=>true 
  validates_associated :conversation, :parent, :person
      
end