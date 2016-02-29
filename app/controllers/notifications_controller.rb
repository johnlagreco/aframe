class NotificationsController < ApplicationController
  
  def incoming
	  	@phone_number = params[:From]
	  	
	  	@new_subscriber = Subscriber.exists?(:phone_number => @phone_number) === false
	  	@subscriber = Subscriber.first_or_create(:phone_number => @phone_number)
	  	
	  	@body = if params[:Body].nil? then '' else params[:Body].downcase end
	  	begin
	  		if @new_subscriber
	  			output = "Thanks for contacting Aframe! Text 'subscribe' if you would like to receive daily specials."
	  		else
	  			output = process_message(@body, @subscriber)
	  		end
	  	rescue
	  		output = "Didn't work. Please try again."
	  	end

	  	respond(output)
  end

  def new
  	message = params[:message]

  	Subscriber.all.each do |s|
  		begin
  			s.send_message(message)
  			flash[:success] = "Text is being sent!"
  		rescue
  			flash[:alert] = "Didn't work!"
  		end
  	end
  	redirect_to '/'
  end

  def index
  end

  private

  def process_message(message, subscriber)
    if message == 'subscribe' || message == 'unsubscribe'

      subscribed = message === 'subscribe'
      subscriber.update :subscribed => subscribed

      output = "You are now in the know!"
      if !subscriber.subscribed
        output = "You are now out of the loop. Text 'subscribe' to get back in."
      end
    else
      output = "Sorry, we didn't understand. The commands are 'subscribe' or 'unsubscribe'."
    end
    return output
  end
  
  def respond(message)
    response = Twilio::TwiML::Response.new do |r|
      r.Message message
    end
    render text: response.text
  end
end
