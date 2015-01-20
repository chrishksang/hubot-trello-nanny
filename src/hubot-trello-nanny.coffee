# Description
#   Hubot is your Trello Nanny and keeps your users and cards in order.
#
# Dependencies
#   node-trello
#   cron
#
# Configuration
#   HUBOT_TRELLO_NANNY_TOKEN - trello token
#   HUBOT_TRELLO_NANNY_APPLICATION_KEY - trello application key
#   HUBOT_TRELLO_NANNY_BOARDS - comma-separated list of boards
#   HUBOT_TRELLO_NANNY_USERS - comma-separated list of users to nanny
#   HUBOT_TRELLO_NANNY_USER_CARD_LIMIT - maximum number of cards a user card be assigned to (defaults to 1)
#   HUBOT_TRELLO_NANNY_ROOM - the room in which hubot should message
#

Trello = require("node-trello");
cronJob = require('cron').CronJob;

module.exports = (robot) ->

  # Initialise variables.
  userNames = process.env.HUBOT_TRELLO_NANNY_USERS.split ','
  boardNames = process.env.HUBOT_TRELLO_NANNY_BOARDS.split ','
  room = process.env.HUBOT_TRELLO_NANNY_ROOM
  cardLimit = process.env.HUBOT_TRELLO_NANNY_USER_CARD_LIMIT || 1
  trello = new Trello process.env.HUBOT_TRELLO_NANNY_APPLICATION_KEY, process.env.HUBOT_TRELLO_NANNY_TOKEN

  # Cron config for how often to check Trello.
  cronConfig = {
    cronTime: '* * * * 1-5'
    onTick: ()->
      trelloNanny()
    onComplete: null
    start: true
  }
  cron = new cronJob cronConfig

  checkUser = (username) ->
    trello.get '/1/members/' + username, {cards: 'open'}, (err, user)->
      if err then throw err
      openCards = []
      for card in user.cards
        if boardNames.indexOf(card.idBoard) isnt -1
          openCards.push card
      if openCards.length is 0
        robot.messageRoom room, user.fullName + ' is not listed on any cards'
      else if openCards.length > cardLimit
        names = []
        for card in openCards
          names.push card.name
        robot.messageRoom room, user.fullName + ' is listed on ' + openCards.length + 'cards: ' + names.join ', '

  trelloNanny = ()->
    try
      checkUser for user in userNames
    catch error
      console.log error

