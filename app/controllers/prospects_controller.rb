class ProspectsController < ApplicationController

  before_action :set_session_and_prospect, only: [ :new, :create ]
  
  def new
    @prospect.current_step = session[:prospect_step] 
  end

  def create
    @prospect.current_step = session[:prospect_step]
    if @prospect.valid?
      if params[:back_button]
        @prospect.previous_step
      elsif @prospect.last_step?
        @prospect.save if @prospect.all_valid?
      else
        @prospect.next_step
      end
      session[:prospect_step] = @prospect.current_step 
    end
    if @prospect.new_record?
      render "new"
    else
      session[:prospect_step] = session[:prospect_params] = nil
      flash[:notice] = "Saved!"
      redirect_to @prospect
    end
  end
  
  def show
  end

  def index 
    redirect_to action: "new"
  end
  private

    def prospect_from_session
      begin 
        Prospect.new(ActionController::Parameters.new(session[:prospect_params]).permit!)
      rescue
        byebug
      end
    end
    
    # match the value stored in the session with the incoming values in the
    # param
    def set_session_and_prospect 
      session[:prospect_params] ||= {}.with_indifferent_access
      session[:prospect_params].deep_merge!(prospect_params)
      session[:prospect_params].keys.select { |a| a =~ /_attributes$/ }.each do |attr|
        session[:prospect_params][attr] = params[:prospect][attr] unless params[:prospect][attr].blank?
      end
      @prospect = prospect_from_session
    end
    
    def prospect_params
      # this is just a sanity check since sometimes we don't actually have
      # anything to add when using the back button. If we don't have a prospect
      # param, we just go to the step in session. if we don't have a session,
      # we just go to first step. 
      params[:prospect] ||=  { current_step: ( session[:prospect_step] || Prospect.steps.first  ) } 
      whitelisted_attrs = %i( current_step commit in_federal_study directory_id first_name last_name local_address 
                       local_phone perm_address perm_phone email family_member class_status
                       graduation_year additional_comments ) 
      whitelisted_attrs << { skill_ids: [], skills: [ :id, :name, :_destroy ], work_experiences: [ :id, :name, :_destroy ] } 
      params.require(:prospect).permit(*whitelisted_attrs).tap do |wl|
        wl[:work_experiences_attributes] = params[:prospect][:work_experiences_attributes] unless params[:prospect][:work_experiences_attributes].blank?
        wl[:available_times_attributes] = params[:prospect][:available_times_attributes] unless params[:prospect][:available_times_attributes].blank?
      end
    end

end
