require 'json'
require 'bunny'
class Chat

  attr_accessor :current_user, :channel, :exchange, :session

  def initialize( current_user = 'default', channel = new_channel )
    @current_user = current_user
    @session = channel
    @channel = @session.create_channel
    @exchange = @channel.fanout('super.chat')
  end

  def display_message(user, message)
    $stdout.puts "#{user}: #{message}"
  end

  def listen_for_messages
    queue = @channel.queue('')
    queue.bind(@exchange).subscribe do |_delivery_info, _metadata, payload|
      data = JSON.parse(payload)
      display_message(data['user'], data['message'])
    end
  end

  def publish_message(user, message)
    data = JSON.generate(user: user, message: message)
    @exchange.publish(data)
  end

  def wait_for_message
    message =  $stdin.gets.strip
    publish_message(@current_user, message)
  end


  def self.run
    chat = Chat.new
    $stdout.print 'Type in your name: '
    chat.current_user = $stdin.gets.strip
    $stdout.puts "Hi #{chat.current_user}, you just joined a chat room!Type your message in and press enter."
    chat.listen_for_messages if 
    loop { chat.wait_for_message }
  end

private
  def new_channel
    Bunny.new.start
  end
end

