Redis = require 'ioredis'
Promise = require 'bluebird'

create_redis = (redisConf, redisDB=0) ->
  if typeof redisConf is 'string'
    [ip, port] = redisConf.split ':'
    redis = new Redis {
      port: port
      host: ip
      db: redisDB
    }
  else
    redis = new Redis.Cluster redisConf, {
      redisOptions: {
        db: redisDB
      }
    }

module.exports = (opts, redis=null, prefix='') ->
  if opts?
    redis = create_redis opts.conf, opts.db
  ->
    {
      set: (key, value, expired) ->
        key = "#{prefix}#{key}"
        value = JSON.stringify {data: value}
        if expired?
          redis.set key, value, 'PX', expired
        else
          redis.set key, value
      get: (key) ->
        key = "#{prefix}#{key}"
        redis.get key
        .then (data) ->
          if data?
            data = JSON.parse data
            Promise.resolve data.data
          else
            Promise.resolve null
    }