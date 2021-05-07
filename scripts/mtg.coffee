# Description
#   In writing this script, I refered to djljr's M:tG hubot script.
#   https://github.com/github/hubot-scripts/blob/master/src/scripts/mtg.coffee
#
#   I thank Whisper Card Database for the Japanese card data.
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

# card format array
EXPS_STANDARD = ["STX", "KHM", "ZNR", "M21", "IKO", "THB", "ELD"]
EXPS_PIONEER = ["STX", "KHM", "ZNR", "M21", "IKO", 
  "THB", "ELD", "M20", "WAR", "RNA", "GRN", "M19", "DOM", "RIX", "XLN",
  "HOU", "AKH", "AER", "KLD", "EMN", "SOI", "OGW", "BFZ", "ORI", "DTK", 
  "FRF", "KTK", "M15", "JOU", "BNG", "THS", "M14", "DGM", "GTC", "RTR"]
EXPS_MODERN = ["STX",
  "KHM", "ZNR", "M21", "IKO", "THB", "ELD", "M20", "WAR", "RNA", "GRN",
  "M19", "DOM", "RIX", "XLN", "HOU", "AKH", "AER", "KLD", "EMN", "SOI",
  "OGW", "BFZ", "ORI", "DTK", "FRF", "KTK", "M15", "JOU", "BNG", "THS",
  "M14", "DGM", "GTC", "RTR", "M13", "AVR", "DKA", "ISD", "M12", "NPH",
  "MBS", "SOM", "M11", "ROE", "WWK", "ZEN", "M10", "ARB", "CON", "ALA",
  "EVE", "SHM", "MOR", "LRW", "10E", "CSP", "FUT", "PLC", "TSP", "DIS",
  "GPT", "RAV", "9ED", "SOK", "BOK", "CHK", "5DN", "DST", "MRD", "8ED"]

# regexp to get cardname from cadlist text
WHISPER_REGEXP = /日本語名：([^（\n]*)[（\n]/g

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

# get cardlist text from whisper card database
whisper = (query) ->
  options = 
    url: "http://whisper.wisdom-guild.net/#{query}"
    timeout: 10000
    encoding: null
  return options 

# search from gatherer
gatherer = (query) ->
  options = 
    url: "http://gatherer.wizards.com/Pages/Search/Default.aspx?#{querystring.stringify(query)}"
    timeout: 10000
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
        msg.send "#{response.statusCode} fizzled!"

  # pick(no args)
  robot.respond /pick$/i, (msg) ->
    cardFormat = EXPS_STANDARD[Math.floor(Math.random()*EXPS_STANDARD.length)]
    cardQuery = "cardlist/#{cardFormat}.txt"

    request whisper(cardQuery), (error, response, body) ->
      if (!error && response.statusCode == 200)
        cards = toUtf8(body).match(WHISPER_REGEXP)
        if cards
          picker = Math.floor(Math.random()*cards.length)
          picked = cards[picker]
          targetName = picked.substring(5,picked.length-1)
          msg.send "I picked #{targetName}(#{cardFormat})"
          msg.send getCardImage(targetName)
        else
          msg.send "no #{cardFormat} cards in library."
      else
        msg.send "#{response.statusCode} fizzled!"

  # pick(args)
  robot.respond /pick (.*)/i, (msg) ->
    cardFormat = "AKH"
    cardQuery = "cardlist/#{cardFormat}.txt"
    # if the argument is format, choose random one from available expansions.
    if msg.match[1].toUpperCase() == "STANDARD"
      cardFormat = EXPS_STANDARD[Math.floor(Math.random()*EXPS_STANDARD.length)]
      cardQuery = "cardlist/#{cardFormat}.txt"
    else if msg.match[1].toUpperCase() == "PIONEER"
      cardFormat = EXPS_PIONEER[Math.floor(Math.random()*EXPS_PIONEER.length)]
      cardQuery = "cardlist/#{cardFormat}.txt"
    else if msg.match[1].toUpperCase() == "MODERN"
      cardFormat = EXPS_MODERN[Math.floor(Math.random()*EXPS_MODERN.length)]
      cardQuery = "cardlist/#{cardFormat}.txt"
    else if msg.match[1].toUpperCase() == "COMMANDER"
      cardFormat = "COMMANDER"
      cardQuery = "search.php?&mcost_op=able&mcost_x=may&color_multi=able&color_ope=and&display=cardname&supertype[]=legendary&supertype_ope=or&cardtype[]=creature&cardtype_ope=or&subtype_ope=or&format=all&exclude=no&set_ope=or&sort=name_en&sort_op=&output=text"
    else
      cardFormat = msg.match[1]
      cardQuery = "cardlist/#{cardFormat}.txt"
    request whisper(cardQuery), (error, response, body) ->
      if (!error && response.statusCode == 200)
        # console.log("#{body}")
        cards = toUtf8(body).match(WHISPER_REGEXP)
        if cards
          picker = Math.floor(Math.random()*cards.length)
          picked = cards[picker]
          targetName = picked.substring(5,picked.length-1)
          msg.send "I picked #{targetName}(#{cardFormat})"
          msg.send getCardImage(targetName)
        else
          msg.send "no #{cardFormat} cards in library."
      else
        msg.send "#{response.statusCode} fizzled!"

  robot.respond /pickel/i, (msg) ->
    msg.send "uh... is this what you want?"
    msg.send getCardImage("重いつるはし")

  # momir(wip)
  # robot.respond /momir ([0-9]+)/i, (msg) ->
    
