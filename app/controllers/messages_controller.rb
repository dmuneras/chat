class MessagesController < ApplicationController

  before_filter :current_user?

  def create
    if current_user
      respond_to do |format| 
        begin
          @message = Message.new params[:message]
          @message.from , @message.channel_id  = current_user.id , current_channel.id 
          if @message.save
            format.js {
              if !(@message.to.nil?)
                @channel_user = "/messages/#{@message.to_user.id}"
              end
            }
          else
            @error_msg = @message.errors.full_messages[0]
            format.js {render 'create_error'}
          end
        rescue Exception => e
          @expection = e.message
          format.js {render 'new'}
        end
      end
    else
      redirect_to root_url
    end
  end

  def destroy 
    respond_to do |format|
      format.js{
        if current_user
          Message.destroy params[:id]
          PrivatePub.publish_to(current_channel_route, "$('li#message-#{params[:id]}').remove();")
          render :nothing => true
        else
          redirect_to root_url
        end
      }
    end
  end
end


