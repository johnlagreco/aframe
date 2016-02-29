class Subscriber < ActiveRecord::Base
	def send_message(msg)
  	@twilio_number = ENV['TWILIO_NUMBER']
  	@client = Twilio::REST::Client.new ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN']
  	message = @client.account.message.create(
  		:from => @twilio_number,
  		:to => self.phone_number,
  		:body => msg,
  	)
  	puts message.to
  end
end
