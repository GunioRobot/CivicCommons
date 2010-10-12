class SubscriptionsController < ApplicationController
  def subscribe
    Rails.logger.info("We are in the ajax subscribe.")
    
    subscription = Subscription.subscribe(params[:type], params[:id], current_person)
    
    respond_to do |format|
      format.js { render :partial => "subscriptions/subscribed", :locals => {:subscribable_type => params[:type], :subscribable_id => params[:id]}, :layout => false}
      format.html # show.html.erb
      format.xml  { render :xml => nil }
    end
  end
  
  def unsubscribe
    Rails.logger.info("We are in the ajax unsubscribe.")
    subscription = Subscription.unsubscribe(params[:type], params[:id], current_person)
    
    respond_to do |format|
      format.js { render :partial => "subscriptions/notsubscribed", :locals => {:subscribable_type => params[:type], :subscribable_id => params[:id]}, :layout => false}
      format.html # show.html.erb
      format.xml  { render :xml => nil }
    end
  end
  
end