require 'slack-ruby-client'

Slack.configure do |config|
  config.token = ENV['SLACK_API_TOKEN']
  config.logger = Logger.new(STDOUT)
  config.logger.level = Logger::INFO
  fail 'Missing ENV[SLACK_API_TOKEN]!' unless config.token
end

@presence_channel = nil

def is_lunch_emoji(status_emoji)
  lunch_emojis = [
    ':fork_and_knife:',
    ':meat_and_bone:',
    ':hotdog:',
    ':hamburger:',
    ':spaghetti:',
    ':sushi:',
    ':rice:',
    ':bento:',
    ':pizza:'
  ]
  
  lunch_emojis.include? status_emoji
end

##
# Check if the status is a lunch status.
def is_lunch_status(status_text, status_emoji)
  return true if is_lunch_emoji(status_emoji)
  
  case status_text
  when /[M,m]ahlzeit/ then
    return true
  end
  
  false
end

##
# Check if the status is a empty status.
def is_home_status(status_text, status_emoji)
  if status_text.empty? && status_emoji.empty?
    return true
  end
  
  false
end

client = Slack::RealTime::Client.new

client.on :hello do
  puts "Successfully connected, welcome '#{client.self.name}' to the '#{client.team.name}' team at https://#{client.team.domain}.slack.com."
  
  client.channels.each do |channel|
    channel_data = channel[1]
    return if channel_data.nil?
    
    if channel_data.is_member == true
      puts "Using channel - name: #{channel_data.name} id: #{channel_data.id}"
      @presence_channel = channel_data.id
    end
  end
end

client.on :user_change do |data|
  status_channel = @presence_channel
  return if status_channel.nil?
  
  client.typing channel: status_channel
  
  if is_lunch_status(data.user.profile.status_text, data.user.profile.status_emoji)
    client.message channel: status_channel, text: "#{data.user.profile.first_name} ist jetzt Mittagessen. 🍴"
  elsif is_home_status(data.user.profile.status_text, data.user.profile.status_emoji)
    client.message channel: status_channel, text: "#{data.user.profile.first_name} ist jetzt zu Hause."
  else
    client.message channel: status_channel, text: "#{data.user.profile.first_name}'s neuer Status: #{data.user.profile.status_text}"
  end
end

client.on :close do |_data|
  puts 'Connection closing, exiting.'
end

client.on :closed do |_data|
  puts 'Connection has been disconnected.'
end

client.start!
