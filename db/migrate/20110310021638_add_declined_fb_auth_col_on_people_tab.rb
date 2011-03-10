class AddDeclinedFbAuthColOnPeopleTab < ActiveRecord::Migration
  def self.up
    add_column :people, :declined_fb_auth, :boolean
  end

  def self.down
    remove_column :people, :declined_fb_auth
  end
end