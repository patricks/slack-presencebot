# Slack Presence Bot

A Slack bot that monitors the status of all users and posts status changes into a channel.

## Usage

### Create a New Bot Integration

This is something done in Slack, under [integrations](https://my.slack.com/services). Create a [new bot](https://my.slack.com/services/new/bot), and note its API token.

### Use the API Token

Set the API token in the ```docker-compose.yml``` file.

### Starting the Bot

#### Manually

Start the bot ```ruby presencebot.rb ``` (Don't forget the set the API token environment variable)

#### Via docker

Build the docker image and run it on your server.

### Add the Bot to Slack Channel

To get the status messages posted, you have to invite the Slack bot to a channel.
