class ConversationsController < ApplicationController
  before_filter :require_user, :only=>[:new, :create, :new_node_contribution, :preview_node_contribution, :confirm_node_contribution, :toggle_rating]

  # GET /conversations
  def index
    @active = Conversation.includes(:participants).latest_updated.limit(3)
    @popular = Conversation.includes(:participants).get_top_visited(3)
    @recent = Conversation.includes(:participants).latest_created.limit(3)
    @recommended = Conversation.includes(:participants).recommended.limit(3)

    @regions = Region.all
    @recent_items = TopItem.newest_items(3).with_items_and_associations.collect(&:item)
    render :index
  end

  def filter
    @filter = params[:filter]
    @conversations = Conversation.includes(:participants).filtered(@filter).paginate(:page => params[:page], :per_page => 12)

    @regions = Region.all
    @recent_items = TopItem.newest_items(3).with_items_and_associations.collect(&:item)
    render :filter
  end

  # GET /conversations/1
  def show
    @conversation = Conversation.includes(:issues).find(params[:id])
    @conversation.visit!((current_person.nil? ? nil : current_person.id))
    @contributions = Contribution.for_conversation(@conversation)
    @ratings = RatingGroup.ratings_for_conversation_by_contribution_with_count(@conversation, current_person)
    # Build rating totals into contribution
    # @contributions.each do |c|
    #   c.ratings       #=> {'some-descriptor' => {:total => 5, :person => true}, 'some-other' => 0, 'and-again' => 1}
    # end

    @top_level_contributions = @contributions.select{ |c| c.is_a?(TopLevelContribution) }
    # grab all direct contributions to conversation that aren't TLC
    @conversation_contributions = @contributions.select{ |c| !c.is_a?(TopLevelContribution) && c.parent_id.nil? }

    @top_level_contribution = Contribution.new # for conversation comment form
    @tlc_participants = @top_level_contributions.collect{ |tlc| tlc.owner }

    @latest_contribution = @conversation.confirmed_contributions.most_recent.first

    @recent_items = TopItem.newest_items(5).for(:conversation => @conversation.id).collect(&:item)

    render :show
  end

  def node_conversation
    @contribution = Contribution.find(params[:id])
    @contributions = @contribution.descendants.confirmed.includes(:person)
    @contribution.visit!((current_person.nil? ? nil : current_person.id))

    respond_to do |format|
      format.js { render :partial => "conversations/node_conversation", :layout => false}
      format.html { render :partial => "conversations/node_conversation", :layout => false}
    end
  end

  def node_permalink
    contribution = Contribution.find(params[:id])
    @contributions = contribution.self_and_ancestors
    @top_level_contribution = @contributions.root
    contribution.visit!((current_person.nil? ? nil : current_person.id))

    respond_to do |format|
      format.js
    end
  end

  def edit_node_contribution
    @contribution = Contribution.find(params[:contribution_id])
    respond_to do |format|
      format.js{ render(:partial => 'conversations/new_contribution_form', :locals => {:div_id => params[:div_id], :type => @contribution.type.underscore.to_sym}, :layout => false) }
    end
  end

  def update_node_contribution
    @contribution = Contribution.find(params[:contribution][:id])
    respond_to do |format|
      if @contribution.update_attributes_by_user(params[:contribution], current_person)
        format.js{ render(:partial => "conversations/contributions/threaded_contribution_template", :locals => {:contribution => @contribution, :div_id => params[:div_id]}, :layout => false, :status => :ok) }
      else
        format.js   { render :json => @contribution.errors, :status => :unprocessable_entity }
      end
    end
  end

  def new_node_contribution
    @contribution = Contribution.find_or_new_unconfirmed(params, current_person)
    respond_to do |format|
      format.js { render(:partial => "conversations/tabbed_post_box", :locals => {:div_id => params[:div_id], :layout => false}) }
      format.html { render(:partial => "conversations/tabbed_post_box", :locals => {:div_id => params[:div_id], :layout => false}) }
    end
  end

  #TODO Test, baby. Test!
  def preview_node_contribution

    errors = []
    if params[:contribution][:type].constantize == EmbedlyContribution
      embedly = EmbedlyService.new
      embedly.fetch_and_merge_params!(params)
    end
    @contribution = Contribution.update_or_create_node_level_contribution(params[:contribution], current_person)

    if @contribution.invalid?
      errors = @contribution.errors.full_messages
    elsif embedly and (embedly.bad_request? or embedly.not_found?)
      errors = ["There was a problem retrieving information for '#{params[:contribution][:url]}'"]
    elsif embedly and not embedly.ok?
      errors = ['There was a problem with our system. Please try again.']
    end
    
    respond_to do |format|
      if errors.size == 0
        format.js   { render(:partial => "conversations/new_contribution_preview", :locals => {:div_id => params[:div_id], :layout => false}) }
        format.html { render(:partial => "conversations/new_contribution_preview", :locals => {:div_id => params[:div_id], :layout => 'application'}) }
      else
        format.js   { render :json => errors, :status => :unprocessable_entity }
        format.html { render :text => errors, :status => :unprocessable_entity }
      end
    end
  end

  #TODO: consider moving this to its own controller?
  def confirm_node_contribution
    @contribution = Contribution.unconfirmed.find_by_id_and_owner(params[:contribution][:id], current_person.id)
    @ratings = RatingGroup.default_contribution_hash

    respond_to do |format|
      if @contribution.confirm!
        Subscription.create_unless_exists(current_person, @contribution.item)
        format.js   { render :partial => "conversations/contributions/threaded_contribution_template", :locals => {:contribution => @contribution}, :status => (params[:preview] ? :accepted : :created) }
        format.html   { render :partial => "conversations/contributions/threaded_contribution_template", :locals => {:contribution => @contribution}, :status => (params[:preview] ? :accepted : :created) }
      else
        format.js   { render :json => @contribution.errors, :status => :unprocessable_entity }
        format.html { render :text => @contribution.errors, :status => :unprocessable_entity }
      end
    end
  end

  # GET /conversations/new
  def new
    return redirect_to :conversation_responsibilities unless params[:accept]
    @conversation = Conversation.new
    @contributions = [Contribution.new]

    render :new
  end

  # GET /conversations/1/edit
  # NOT IMPLEMENTED YET, I.E. NOT ROUTEABLE
  def edit
    @conversation = Conversation.find(params[:id])
  end

  # POST /conversations
  def create
    @conversation = Conversation.new_user_generated_conversation(params[:conversation], current_person)
    @conversation.started_at = Time.now
    # Load @contributions to populate re-rendered :new form if save is unsuccessful
    @contributions = @conversation.contributions | @conversation.rejected_contributions

    respond_to do |format|
      if @conversation.save
        format.html { redirect_to(new_invite_path(:source_type => :conversations, :source_id => @conversation.id, :conversation_created => true), :notice => 'Your conversation has been created!') }
      else
        #TODO: Find a better way to handle erros on submission
        @contributions = [Contribution.new]
        format.html { render :new, :status => :unprocessable_entity  }
      end
    end
  end

  # PUT /conversations/1
  # NOT IMPLEMENTED YET, I.E. NOT ROUTEABLE
  def update
    @conversation = Conversation.find(params[:id])

    if @conversation.update_attributes(params[:conversation])
      redirect_to(@conversation, :notice => 'Conversation was successfully updated.')
    else
      render :action => "edit", :status => :unprocessable_entity
    end
  end

  def toggle_rating
    @contribution = Contribution.find(params[:contribution_id])
    @rating_descriptor = RatingDescriptor.find_by_title(params[:rating_descriptor_title])

    @rating_group = RatingGroup.toggle_rating!(current_person, @contribution, @rating_descriptor)
    respond_to do |format|
      format.js
    end
  end

  # DELETE /conversations/1
  # NOT IMPLEMENTED YET, I.E. NOT ROUTEABLE
  def destroy
    @conversation = Conversation.find(params[:id])
    @conversation.destroy

    redirect_to(conversations_url)
  end

end
