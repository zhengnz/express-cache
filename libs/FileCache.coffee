FileCacheSimple = require 'file-cache-simple'
Promise = require 'bluebird'

cache = new FileCacheSimple {
  'cacheDir': './cache'
  'prefix': ''
  'fixCacheExpire': false
  'rejectOnNull': false
}

module.exports = ->
  {
    set: (key, value, expired) ->
      if expired?
        cache.set key, value, expired
      else
        cache.set key, value
      Promise.resolve()
    get: (key) ->
      cache.get key
  }