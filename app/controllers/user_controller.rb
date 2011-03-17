class UserController < ApplicationController

  before_filter :require_ssl, :only => [:edit, :update]
  before_filter :verify_ownership?, :only => [:edit, :update, :destroy_avatar]

  def verify_ownership?
    unless(current_person && current_person == Person.find(params[:id]))
      redirect_to community_path
    end
  end

  def edit
    @person = Person.find(params[:id])
  end

  def show
    @user = Person.includes(:contributions, :subscriptions).find(params[:id])

    @contributions = @user.contributions.order('contributions.created_at DESC')
    @contributions = @contributions.paginate(page: params[:page], per_page: 6)
    @contributions.collect do |contribution|
      ContributionPresenter.new(contribution)
    end

    @issue_subscriptions = @user.subscriptions.select do |subscription|
      subscription.subscribable_type == "Issue"
    end

    @conversation_subscriptions = @user.subscriptions - @issue_subscriptions
  end

  def update
    @person = Person.find(params[:id])
    respond_to do |format|
      if @person.update_attributes(params[:person])
        flash[:notice] = "Successfully edited your profile"
        format.html { redirect_to user_url(@person) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

 def destroy_avatar
  @person = Person.find(params[:id])
  @person.avatar = nil
  if @person.save
    respond_to do |format|
      format.js { render :json => { :avatarUrl => ( @person.facebook_authenticated? && !@person.avatar? ? @person.facebook_profile_pic_url : @person.avatar.url )} }
    end
  else
    respond_to do |format|
      format.js { render :nothing => true, :status => 500 }
    end
  end
 end
end
