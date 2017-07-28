require_relative 'chat'

chat = Chat.new
print 'Type in your name: '
chat.current_user = gets.strip
puts "Hi #{chat.current_user}, you just joined a chat room!Type your message in and press enter."
chat.listen_for_messages 
loop { chat.wait_for_message }
