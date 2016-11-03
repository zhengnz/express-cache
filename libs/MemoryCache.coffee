cache = require 'memory-cache'
Promise = require 'bluebird'

module.exports = ->
  {
    set: (key, value, expired) ->
      if expired?
        cache.put key, value, expired
      else
        cache.put key, value
      Promise.resolve
    get: (key) ->
      Promise.try ->
        cache.get key
  }