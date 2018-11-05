require 'discordrb'

token = File.read('token.dat')
client_id = File.read('client_id.dat')
prefix = '/'

bot = Discordrb::Commands::CommandBot.new token: token, client_id: client_id, prefix: prefix

bot.member_join do |event|
    event.server.text_channels[0].send_embed do |embed|
        embed.title = event.user.name + "さんが参加しました"
        embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(
            url: event.user.avatar_url
        )
        embed.color = '00dd00'
        embed.add_field(
            name: 'シス研へようこそ！',
            value: "このサーバーにはいくつかのルールがあります。\nはじめに #readme をお読みください。",
        )
    end
end

bot.command :test do |event|
    event.server.text_channels[0].send_embed do |embed|
        embed.title = event.user.name + "さんが参加しました"
        embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(
            url: event.user.avatar_url
        )
        embed.color = '00dd00'
        embed.add_field(
            name: 'シス研へようこそ！',
            value: "このサーバーにはいくつかのルールがあります。\nはじめに #readme をお読みください。",
        )
    end
end

# /neko: にゃーんと鳴きます
bot.command :neko do |event|
    event << 'にゃーん'
end

# /random [min] [max]: min以上max以下の乱数を返します
# /random [max]: max未満の乱数を返します
bot.command :random do |event, min, max|
    unless max.nil?
        event << rand(min.to_i .. max.to_i)
    else
        event << rand(min.to_i)
    end
end

# /echo [message]: [message]を返します
bot.command :echo do |event|
    s = event.content
    s.slice!(prefix + 'echo').strip!
    unless s.empty?
        event << s
    else
        event << "**error** argument is missing.\nexpected `/echo [message]`\nex. `/echo hello` > hello"
    end
end

# /say [message]: [message]を返します
bot.command :say do |event|
    s = event.content
    s.slice!(prefix + 'say').strip!
    unless s.empty?
        event << s
    else
        event << "**error** argument is missing.\nexpected `/say [message]`\nex. `/say hello` > hello"
    end
end

bot.run
