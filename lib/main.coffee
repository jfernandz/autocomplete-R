provider = require './provider'

module.exports =
  activate: ->
    provider.loadKeywords()

  getProvider: -> provider
