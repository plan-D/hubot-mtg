# Description
#   In writing this script, I refered to djljr's M:tG hubot script.
#   https://github.com/github/hubot-scripts/blob/master/src/scripts/mtg.coffee
#
# Configuration:
#   LIST_OF_ENV_VARS_TO_SET
#
# Commands:
#   hubot cast <card name> - get a card image from gatherer
#   hubot draw - get a random card image from gatherer
#
# Notes:
#   <optional notes required for the script>
#
# Author:
#   plan-D

querystring = require 'querystring'

request = require 'request'

drawUrl = "http://gatherer.wizards.com/Pages/Card/Details.aspx?action=random"
imageUrl = "http://gatherer.wizards.com/Handlers/Image.ashx"

module.exports = (robot) ->
  robot.respond /cast (.+)/i, (msg) ->
    card = msg.match[1] || "_____"
    query = { type: "card", name: card }
    msg.send "#{imageUrl}?#{querystring.stringify(query)}#.jpg"

  robot.respond /draw/i, (msg) ->
    re = /<span id="ctl00_ctl00_ctl00_MainContent_SubContent_SubContentHeader_subtitleDisplay".*>(.*)<\/span>/i
    options = 
      url: drawUrl
      timeout: 2000

    request options, (error, response, body) ->
      card = body.match(re)
      msg.send "#{card[1]}"
      query = { type: "card", name: card[1] }
      msg.send "#{imageUrl}?#{querystring.stringify(query)}#.jpg"
