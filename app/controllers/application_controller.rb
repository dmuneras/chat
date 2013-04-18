class ApplicationController < ActionController::Base

  include Scripts
  
  helper_method :current_user
  helper_method :current_channel
  helper_method :current_channel_route
  helper_method :current_user_channel
  
  protect_from_forgery
  rescue_from CanCan::AccessDenied do |exception|    
        flash[:error] = "No tiene privilegios para ingresar"
        redirect_to root_url
  end
    
  private
  def current_user?
    redirect_to(root_url, :notice => "Debe iniciar sesion") unless current_user
  end

  def current_user
    return @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  
  def current_user_client username 
      return User.find_by_username username  if username
  end
  
  def current_channel_client channel_id
     return Channel.find channel_id  if channel_id
  end
  
  def current_channel
    begin
       @current_channel = Channel.find(session[:channel_id]) if session[:channel_id]   
       return @current_channel  
    rescue Exception => e
        return nil
    end
  end
  
  def current_channel_route
    return "/messages/new/#{current_channel.name}" if current_channel
  end
  
  def current_user_channel
     return "/messages/#{current_user.id}"
   end
end
