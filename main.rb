require 'discordrb'

token = File.read('token.dat')
client_id = File.read('client_id.dat')

bot = Discordrb::Commands::CommandBot.new token: token, client_id: client_id, prefix:'/'

bot.command :neko do |event|
    event.send_message('にゃーん')
end   

bot.run
