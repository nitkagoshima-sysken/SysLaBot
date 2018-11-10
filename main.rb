require 'discordrb'
require 'timers'
require 'date'

year_roles = [
    '2014',
    '2015',
    '2016',
    '2017',
    '2018',
]

major_roles = [
    'Mechanical',
    'Electrical and Electronic',
    'Electronic Control',
    'Information',
    'Department of Urban Environmental Design',
]

admin_roles = [
    'Sys La',
    'Bot Developer',
    'Re;Hydro-Go',
]

games = [
    "Bad North",
    "Dead by Daylight",
    "Hearthstone",
    "Minecraft",
    "Moonlighter",
    "Overwatch",
    "PLYAERUNKNOWN'S BATTLEGROUNDS",
    "StarCraft II",
    "Yandere Simulator",
    "黒い砂漠",
    "見上げてごらん夜の星を",
]

token = File.read('token.dat')
client_id = File.read('client_id.dat')
prefix = '/'

# 改行を削除
token.chomp!
client_id.chomp!

bot = Discordrb::Commands::CommandBot.new token: token, client_id: client_id, prefix: prefix

bot.ready do |event|
  bot.game = bot.game = games[rand(games.count)]
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

# /neko: にゃーんと鳴きます
bot.command :neko do |event, *args|
  event << "#{args.join(' ')}にゃーん"
end

# /random [min] [max]: min以上max以下の乱数を返します
# /random [max]: max未満の乱数を返します
bot.command(:random, min_args: 0, max_args: 2, description: 'Generates a random number between 0 and 1, 0 and max or min and max.', usage: 'random [min/max] [max]') do |event, min, max|
  if max
    rand(min.to_i..max.to_i)
  elsif min
    rand(0..min.to_i)
  else
    rand
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
  # Again, the return role of the block is sent to the channel
  "**#{args.join(' ')}**"
end

bot.command :italic do |event, *args|
  "*#{args.join(' ')}*"
end

# /iam [role]: 役職[role]になります
bot.command [:iam, :im] do |event, *args|
  role_name = args.join(' ')
  if event.server.roles.find {|r| r.name == role_name}.nil?
    event << "「" + role_name + "」という役職はこのサーバーには存在しません"
    return
  elsif !event.user.roles.find {|r| r.name == role_name}.nil?
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
    event.user.add_role(event.server.roles.find {|r| r.name == role_name})
    event << "あなたは「" + role_name + "」になりました"
  end
end

# /iamnot [role]: 役職[role]をやめます
bot.command [:iamnot, :imnot] do |event, *args|
  role_name = args.join(' ')
  if event.server.roles.find {|r| r.name == role_name}.nil?
    event << "「" + role_name + "」という役職はこのサーバーには存在しません"
    return
  elsif event.user.roles.find {|r| r.name == role_name}.nil?
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
    event.user.remove_role(event.server.roles.find {|r| r.name == role_name})
    event << "あなたは「" + role_name + "」をやめました"
  end
end

# 役職を表示します。
bot.command :role do |event|
  roles = "あなたがなれる役職一覧です\n"
  event.server.roles.each do |role|
    unless role.nil? or
        role.name == '@everyone' or
        admin_roles.include? role.name or
        year_roles.include? role.name or
        major_roles.include? role.name
      roles += "「#{role.name}」"
    end
  end
  event << roles
end

thread1 = Thread.new do
  timers = Timers::Group.new
  timer = timers.every(60 * 15) {bot.game = games[rand(games.count)]}
  loop {timers.wait}
end
thread2 = Thread.new do
  bot.run :await
end
thread3 = Thread.new do
  timers = Timers::Group.new
  timer = timers.every(60) do
    if Date.today.tuesday? or Date.today.thursday?
      if Time.now.hour == 17 and Time.now.min == 10
        bot.servers.find {|key, value| value.name == "電子・情報・システム研究部"}[1]
            .text_channels.find {|channel| channel.name == "general"}
            .send_embed do |embed|
          embed.title = "シス研の時間です"
          if Date.today.tuesday?
            embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(
                url: 'https://3.bp.blogspot.com/-Vd9_UP69TR8/VJ6XtvAuTaI/AAAAAAAAqPA/DqxFZTy-B5o/s400/syougakkou_souji.png'
            )
            embed.color = '4169e1'
            embed.add_field(
                name: '今日は掃除があります',
                value: 'みなさん、掃除を忘れずにしましょう',
            )
          elsif Date.today.thursday?
            embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(
                url: 'https://2.bp.blogspot.com/-JPa0Nzk_E8M/Vf-aIH2jsyI/AAAAAAAAyDc/2FG8dSNSk-k/s400/computer_girl.png'
            )
            embed.color = '4169e1'
            embed.add_field(
                name: '今日は木曜日です',
                value: 'プログラミングを楽しみましょう',
            )
          end
        end
      end
    end
  end
  loop {timers.wait}
end

thread1.join
thread2.join
thread3.join
