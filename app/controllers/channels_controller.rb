class ChannelsController < ApplicationController
  
  
  before_filter :current_user? , :except => [:index]

  # GET /channels
  # GET /channels.json
  def index
    @channels = Channel.all
    @messages = Message.messages_by_channel(current_channel,current_user) 
    @users = User.users_by_channel current_channel
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @channels }
      format.xml {render xml: @channels}
    end
  end

  # GET /channels/1
  # GET /channels/1.json
  def show
    @channel = Channel.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @channel }
    end
  end

  # GET /channels/new
  # GET /channels/new.json
  def new
    @channel = Channel.new
    respond_to do |format|
      format.json { render json: @channel }
      format.html
    end
  end

  # GET /channels/1/edit
  def edit
    @channel = Channel.find(params[:id])
  end

  # POST /channels
  # POST /channels.json
  def create
    @channel = Channel.new(params[:channel])
    respond_to do |format|
      if @channel.save
        format.js {@user_msg = "#{t(:new_channel_created)} : #{@channel.name}"}
        format.json { render json: @channel, status: :created, location: @channel }
        format.html{
           PrivatePub.publish_to('/messages',
           "$('select#channel_id').append('<option value = #{@channel.id} > #{@channel.name}</option>');
           $('#msg-channel').css('display','block');$('#msg-channel').html('se ha creado un nuevo canal');
           $('#msg-channel').fadeOut(2000);$('#channel_id').trigger('liszt:updated');")
           redirect_to channels_path
        }
      else
        @error_msg = @channel.errors.full_messages[0]
        format.js { render action: "errors" }
        format.json { render json: @channel.errors, status: :unprocessable_entity }
        format.html {render action: "new"}
      end
    end
  end

  # PUT /channels/1
  # PUT /channels/1.json
  def update
    @channel = Channel.find(params[:id])
    respond_to do |format|
      if @channel.update_attributes(params[:channel])
        format.html { redirect_to @channel, notice: 'Channel was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @channel.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /channels/1
  # DELETE /channels/1.json
  def destroy
    @channel = Channel.find(params[:id])
    @channel.destroy
    respond_to do |format|
      format.html { 
        PrivatePub.publish_to('/messages', "$(\"#channel_id option:regex(value,#{@channel.id})\").remove();
        $('#msg-channel').css('display','block');$('#msg-channel').html('se ha eliminado un nuevo canal');
        $('#channel_id').trigger('liszt:updated');$('#msg-channel').fadeOut(2000);")
        redirect_to channels_url
      }
      format.json { head :ok }
    end
  end
  
  def update_chat  
    unless params[:channel_id].blank?
        session[:channel_id] = params[:channel_id] 
        previous_channel = current_user.channel
        @user_msg = "#{t(:new_channel_selected)} : #{current_channel.name}"
        current_user.channel_id = params[:channel_id]
        current_user.save
        logger.info "PREVIOUS CHANNEL : #{previous_channel.name if previous_channel}," <<
         "CURRENT_CHANNEL : #{current_channel.name if current_channel}"
        if previous_channel
          if previous_channel != current_channel
            logger.info "\n\n\n-------------> REMOVI #{current_user.username} de /messages/new/#{previous_channel.name}\n\n\n"
            PrivatePub.publish_to("/messages/new/#{previous_channel.name}",remove_user_from_list(current_user.id)) 
          end
        end
        logger.info "\n\n\n----------------> AGREGE #{current_user.username} de #{current_channel_route}\n\n\n"
        PrivatePub.publish_to(current_channel_route,append_user_to_list(current_user.id , current_user.username))  
            
    else
      redirect_to root_url
    end
  end
  
  def chat
    respond_to do |format|  
      format.html{
        @messages = Message.messages_by_channel(current_channel, current_user) 
        @users = User.users_by_channel current_channel
        render :layout => false
      }
      format.json{
        chat_data = Hash.new
        channel = Channel.find_by_name(params["channel"])
        user = User.find_by_username(params["username"])
        @messages = Message.messages_by_channel(channel, user) 
        @users = User.users_by_channel channel
        chat_data = {:msgs => @messages, :users => @users}
        render json: chat_data
      }
    end
  end
end


