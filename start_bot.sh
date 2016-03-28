#!/bin/sh

export HUBOT_SLACK_TOKEN=my_hubot_slack_token

forever start -c coffee node_modules/.bin/hubot --adapter slack
