require 'discordrb'

year_roles = [
    "2014",
    "2015",
    "2016",
    "2017",
    "2018",
]

major_roles = [
    "Mechanical",
    "Electrical and Electronic",
    "Electronic Control",
    "Information",
    "Department of Urban Environmental Design",
]

token = File.read('token.dat')
client_id = File.read('client_id.dat')
prefix = '/'

# 改行を削除
token.chomp!
client_id.chomp!

bot = Discordrb::Commands::CommandBot.new token: token, client_id: client_id, prefix: prefix

bot.ready do |e|
    bot.game = "さくらインターネット"
end

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

bot.command :bold do |event, *args|
    # Again, the return value of the block is sent to the channel
    "**#{args.join(' ')}**"
end
  
bot.command :italic do |event, *args|
    "*#{args.join(' ')}*"
end

# /iam [role]: 役職[role]になります
bot.command [:iam, :im] do |event, *args|
    role_name = args.join(' ')
    if event.server.roles.find{|r| r.name == role_name}.nil?
        event << "「" + role_name + "」という役職はこのサーバーには存在しません"
        return
    elsif !event.user.roles.find{|r| r.name == role_name}.nil?
        event << "あなたは既に「" + role_name + "」です"
        return
    elsif year_roles.include? role_name
        event << "あなたは「" + role_name + "」という年代になることはできません"
        event << "もし、割り当てられた年代が違う場合は、管理者に連絡してください"
        return
    elsif major_roles.include? role_name
        event << "あなたは「" + role_name + "」という学科になることはできません"
        event << "もし、割り当てられた学科が違う場合は、管理者に連絡してください"
        return
    else
        event.user.add_role(event.server.roles.find{|r| r.name == role_name})
        event << "あなたは「" + role_name + "」になりました"
    end
end

# /iamnot [role]: 役職[role]をやめます
bot.command [:iamnot, :imnot] do |event, *args|
    role_name = args.join(' ')
    if event.server.roles.find{|r| r.name == role_name}.nil?
        event << "「" + role_name + "」という役職はこのサーバーには存在しません"
        return
    elsif event.user.roles.find{|r| r.name == role_name}.nil?
        event << "あなたは既に「" + role_name + "」ではありません"
        return
    elsif year_roles.include? role_name
        event << "あなたは「" + role_name + "」という年代をやめることはできません"
        event << "もし、割り当てられた年代が違う場合は、管理者に連絡してください"
        return
    elsif major_roles.include? role_name
        event << "あなたは「" + role_name + "」という学科をやめることはできません"
        event << "もし、割り当てられた学科が違う場合は、管理者に連絡してください"
        return
    else
        event.user.remove_role(event.server.roles.find{|r| r.name == role_name})
        event << "あなたは「" + role_name + "」をやめました"
    end
end

bot.run
