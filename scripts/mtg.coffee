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
{Iconv} = require 'iconv'
{buffer} = require 'buffer'

# get card image url from gatherer
getCardImage = (cardname) ->
  imageUrl = "http://gatherer.wizards.com/Handlers/Image.ashx"
  query = { type: "card", name: cardname }
  "#{imageUrl}?#{querystring.stringify(query)}#.jpg"

# sjis to utf8 for wisdomguild
toUtf8 = (body) ->
  iconv = new Iconv('SHIFT_JIS', 'UTF-8//TRANSLIT//IGNORE')
  body = new Buffer(body, 'binary')
  body = iconv.convert(body).toString()

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
      if (!error && response.statusCode == 200)
        card = body.match(re)
        msg.send "#{card[1]}"
        msg.send getCardImage(card[1])
      else
        msg.send "fizzled!"

  # pick
  robot.respond /pick (.*)/i, (msg) ->
    searchUrl = "http://whisper.wisdom-guild.net/search.php"
    cardFormat = msg.match[1] || "standard"
    query = { format: cardFormat, output: "text" }
    jpre = /日本語名：([^（]*)（/g
    options = 
      url: "#{searchUrl}?#{querystring.stringify(query)}"
      timeout: 30000
      encoding: null
 
    request options, (error, response, body) ->
      if (!error && response.statusCode == 200)
        cards = toUtf8(body).match(jpre)
        picker = Math.floor(Math.random()*cards.length)
        picked = cards[picker]
        targetName = picked.substring(picked.indexOf('：')+1,picked.length-1)
        msg.send "#{targetName}"
        msg.send getCardImage(targetName)
      else
        msg.send "fizzled!"
