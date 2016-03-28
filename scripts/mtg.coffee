# Description
#   In writing this script, I refered to djljr's M:tG hubot script.
#   https://github.com/github/hubot-scripts/blob/master/src/scripts/mtg.coffee
#
# Configuration:
#   LIST_OF_ENV_VARS_TO_SET
#
# Commands:
#   hubot cast <card name> - get a specified card image from gatherer
#   hubot draw - get a random card image from gatherer
#
# Notes:
#   <optional notes required for the script>
#
# Author:
#   plan-D

querystring = require 'querystring'
request = require 'request'

# get card image url from gatherer
getCardImage = (cardname) ->
  imageUrl = "http://gatherer.wizards.com/Handlers/Image.ashx"
  query = { type: "card", name: cardname }
  "#{imageUrl}?#{querystring.stringify(query)}#.jpg"

module.exports = (robot) ->
  # cast
  robot.respond /cast (.+)/i, (msg) ->
    card = msg.match[1] || "_____"
    msg.send getCardImage(card)
  
  # draw
  robot.respond /draw/i, (msg) ->
    drawUrl = "http://gatherer.wizards.com/Pages/Card/Details.aspx?action=random"
    re = /<span id="ctl00_ctl00_ctl00_MainContent_SubContent_SubContentHeader_subtitleDisplay".*>(.*)<\/span>/i
    options = 
      url: drawUrl
      timeout: 2000
      headers: {
        'Accept-Language' : 'ja,en'
      }

    request options, (error, response, body) ->
      card = body.match(re)
      msg.send "#{card[1]}"
      msg.send getCardImage(card[1])
