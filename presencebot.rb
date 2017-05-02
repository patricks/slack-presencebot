require 'slack-ruby-client'

Slack.configure do |config|
  config.token = ENV['SLACK_API_TOKEN']
  config.logger = Logger.new(STDOUT)
  config.logger.level = Logger::INFO
  fail 'Missing ENV[SLACK_API_TOKEN]!' unless config.token
end

@presence_channel = nil

##
# Check if the the status is a lunch status.
def is_lunch_status(status_text, status_emoji)
  case status_emoji
  when ':fork_and_knife:' then
    return true
  end
  
  case status_text
  when /[M,m]ahlzeit/ then
    return true
  end
  
  false
end

client = Slack::RealTime::Client.new

client.on :hello do
  puts "Successfully connected, welcome '#{client.self.name}' to the '#{client.team.name}' team at https://#{client.team.domain}.slack.com."
end

client.on :message do |data|
  puts "Using channel: #{data.channel}"
  @presence_channel = data.channel
end

client.on :user_change do |data|
  status_channel = @presence_channel
  
  client.typing channel: status_channel
  
  if is_lunch_status(data.user.profile.status_text, data.user.profile.status_emoji)
    client.message channel: status_channel, text: "#{data.user.profile.first_name} ist jetzt Mittagessen. 🍴"
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
