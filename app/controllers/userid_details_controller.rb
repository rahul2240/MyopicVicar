class UseridDetailsController < ApplicationController
 require 'userid_role'

	def index
    @userid = session[:userid]
    @first_name = session[:first_name]
    @user = UseridDetail.where(:userid => session[:userid]).first
    session[:user] = @user

    case
    when @user.person_role == 'system_administrator' ||  @user.person_role == 'volunteer_coordinator'
        @userids = UseridDetail.all.order_by(userid_lower_case: 1)
    when  @user.person_role == 'country_cordinator'
        @userids = UseridDetail.where(:syndicate => @user.syndicate ).all.order_by(userid_lower_case: 1) # need to add ability for more than one county
    when  @user.person_role == 'county_coordinator'  
        @userids = UseridDetail.where(:syndicate => @user.syndicate ).all.order_by(userid_lower_case: 1) # need to add ability for more than one syndicate  
    when  @user.person_role == 'sydicate_coordinator'  
        @userids = UseridDetail.where(:syndicate => @user.syndicate ).all.order_by(userid_lower_case: 1) # need to add ability for more than one syndicate  
    
    end #end case

 	end #end method

  def new
    @userid = UseridDetail.new
    @first_name = session[:first_name]
    synd = Syndicate.all.order_by(syndicate_code: 1)
     session[:type] = "add"
     @syndicates = Array.new
     synd.each do |syn|
      @syndicates << syn.syndicate_code
     end
  end
   
  def show
    load(params[:id])
     @first_name = session[:first_name]
   
  end
  def my_own
    @user = session[:user]
    @first_name = session[:first_name]
    @userids = UseridDetail.where(:userid => @user.userid ).first
    redirect_to userid_detail_path(@userids)

  end

  def edit
    
     load(params[:id])
     @first_name = session[:first_name]
     session[:type] = "edit"
     synd = Syndicate.all.order_by(syndicate_code: 1)
     @syndicates = Array.new
     synd.each do |syn|
      @syndicates << syn.syndicate_code
     end

  end

  def create
     @userid = UseridDetail.new
    params[:userid_detail][:sign_up_date] = DateTime.now
    p session
    p params
     @userid.update_attributes!(params[:userid_detail])
     flash[:notice] = 'The update of the Userid was succsessful'
      if @userid.errors.any?
     session[:form] =  @userid
     session[:errors] = @userid.errors.messages
     flash[:notice] = 'The addition of the Place was unsuccsessful'
     redirect_to :action => 'edit'
     return
     else
    session[:type] = "edit"
    
    redirect_to userid_details_path
     end
  end
  def update
    load(params[:id])
  	if session[:type] == "disable" 
  	 params[:userid_detail][:disabled_date]  = DateTime.now if  @userid.disabled_date.nil? || @userid.disabled_date.empty?
     params[:userid_detail][:active]  = false  
    end
    params[:userid_detail][:person_role] = UseridRole.has_key(params[:userid_detail][:person_role]).to_s
    @userid.update_attributes!(params[:userid_detail])
    if @userid.errors.any?
      session[:form] =  @userid
      session[:errors] = @userid.errors.messages
      flash[:notice] = 'The update of the Userid was unsuccsessful'
      redirect_to :action => 'edit'
      return
    else
      session[:type] = "edit"
      flash[:notice] = 'The update of the Userid was succsessful'
      redirect_to userid_details_path(:anchor => "#{ @userid.id}")
     end
end

def destroy
end

 def disable
  load(params[:id])
 	@first_name = session[:first_name]
  session[:type] = "disable"

  end

  def load(userid_id)
   @userid = UseridDetail.find(userid_id)
   session[:userid_id] = userid_id
  end
end

