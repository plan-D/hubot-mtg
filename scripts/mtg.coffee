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
#   hubot pick <format> - get a random card image that is available at specified format.
#
# Notes:
#   
#
# Author:
#   plan-D

querystring = require 'querystring'
request = require 'request'
{Iconv} = require 'iconv'
{buffer} = require 'buffer'
fs = require 'fs'
soi_list = fs.readFileSync './soi.list'
soi_list = soi_list.toString().split("\n")
ogw_list = fs.readFileSync './ogw.list'
ogw_list = ogw_list.toString().split("\n")
bfz_list = fs.readFileSync './bfz.list'
bfz_list = bfz_list.toString().split("\n")
ori_list = fs.readFileSync './ori.list'
ori_list = ori_list.toString().split("\n")
dtk_list = fs.readFileSync './dtk.list'
dtk_list = dtk_list.toString().split("\n")

standard_list = []
standard_list = standard_list.concat(soi_list, ogw_list, bfz_list, ori_list, dtk_list)

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

# search from wisdomguild
wisdomguild = (query) ->
  options = 
    url: "http://whisper.wisodm-guild.net/search.php?#{querystring.stringify(query)}"
    timeout: 30000
    encoding: null
  return options 

# search from gatherer
gatherer = (query) ->
  options = 
    url: "http://gatherer.wizards.com/Pages/Search/Default.aspx?#{querystring.stringify(query)}"
    timeout: 60000
    headers: {
      'Accept-Language' : 'ja,en'
      'Cookie' : 'CardDatabaseSettings=0=1&1=ja-JP&2=0&14=1&3=13&4=0&5=1&6=15&7=0&8=1&9=1&10=VisualSpoiler&11=7&12=8&15=1&16=1&13=;'
      'Connection' : 'keep-alive'
    }
  return options

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
    msg.send "Now searching please do not request rapidly."

    # 実際はpickの後に文字が必ず入るのでnullはあり得ない
    cardFormat = msg.match[1] || "Standard"
    query = { action: "advanced", output: "spoiler", method: "visual", format:"\+[\"#{cardFormat}\"]" }

    # alt="JP_CARD_NAME(EN_CARD_NAME)"
    jpre = /alt=\"([^\(>]*)\(/g

    request gatherer(query), (error, response, body) ->
      if (!error && response.statusCode == 200)
        # console.log("#{body}")
        cards = body.match(jpre)
        picker = Math.floor(Math.random()*cards.length)
        picked = cards[picker]
        targetName = picked.substring(picked.indexOf('"')+1,picked.length-1)
        msg.send "I picked #{targetName}(#{cardFormat})"
        msg.send getCardImage(targetName)

      else
        msg.send "fizzled!"

  robot.respond /standard/i, (msg) ->
    card = standard_list[Math.floor(Math.random() * standard_list.length)] || "_____"
    msg.send getCardImage(card)

  robot.respond /soi/i, (msg) ->
    card = soi_list[Math.floor(Math.random() * soi_list.length)] || "_____"
    msg.send getCardImage(card)

  robot.respond /ogw/i, (msg) ->
    card = ogw_list[Math.floor(Math.random() * ogw_list.length)] || "_____"
    msg.send getCardImage(card)

  robot.respond /bfz/i, (msg) ->
    card = bfz_list[Math.floor(Math.random() * bfz_list.length)] || "_____"
    msg.send getCardImage(card)

  robot.respond /ori/i, (msg) ->
    card = ori_list[Math.floor(Math.random() * ori_list.length)] || "_____"
    msg.send getCardImage(card)

  robot.respond /dtk/i, (msg) ->
    card = dtk_list[Math.floor(Math.random() * dtk_list.length)] || "_____"
    msg.send getCardImage(card)
