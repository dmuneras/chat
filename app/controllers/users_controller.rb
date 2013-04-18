class UsersController < ApplicationController
  
  #load_and_authorize_resource
  before_filter :current_user?
  
  def index
    @users = User.all
  end
  def new
    @user = User.new
     respond_to do |format|
       format.html  # new.html.erb
       format.json  { render :json => @user }
     end
  end

  def create
    @user = User.new(params[:user])
    @user.password = Digest::MD5.hexdigest @user.password
    @user.provider = 'local'
    respond_to do |format|
      if @user.save
        format.html  { redirect_to(root_url,
                      :notice => t(:user_was_successfully_created)) }
        format.json  { render :json => @user,
                      :status => :created, :location => @user }
      else
        format.html  { render :action => "new" }
        format.json  { render :json => @user.errors,
                      :status => :unprocessable_entity }
      end
    end
  end

  def edit
    @user = User.find(params[:id])
  end
  
   def update
     @user = User.find(params[:id])
     respond_to do |format|
       if @user.update_attributes(params[:user])
         format.html { 
           @user.password = Digest::MD5.hexdigest @user.password
           @user.save
           redirect_to users_path, notice: 'Channel was successfully updated.' 
         
         }
         format.json { head :ok }
       else
         format.html { render action: "edit" }
         format.json { render json: @user.errors, status: :unprocessable_entity }
       end
     end
   end
end 