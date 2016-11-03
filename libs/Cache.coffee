_ = require 'lodash'
Promise = require 'bluebird'

class Cache
  constructor: (@opts={}, @debug=false, @sync_key='_cacheSync') ->
    @opts = _.assign {
      duplicate: false
    }, @opts
    @cache = null

  log: (msg) ->
    if @debug is on
      console.log msg

  use: (plane) ->
    @cache = plane()

  set: (name, opts, alias) ->
    if not _.has(@cache, 'set') or not _.has @cache, 'get'
      throw new Error 'Please set a cache plane'
    (req, res, next) =>
      sync = _.has req.query, @sync_key

      if _.isFunction name
        _cache = (obj) =>
          @create Promise.resolve(name obj), ->
            [sync, _.assign @opts, opts]
      else
        _cache = @create Promise.resolve(name), ->
          [sync, _.assign @opts, opts]

      is_init = false
      if not _.has req, 'cache'
        is_init = true
        req.cache = {}

      if alias?
        req.cache[alias] = _cache
      else if is_init is off
        next new Error 'You have to set alias of every cache when use multiple cache in one route'
        return
      else
        req.cache = _cache

      next()

  create: (get_name, get_config) ->
    {
      get_or_create: (func) =>
        get_name.then (name) =>
          [sync, opts] = get_config()
          if sync is on
            @log "#{name} force sync"
            @getData name, func, sync, opts
          else
            @log "#{name} get from cache"
            @cache.get name
            .then (data) =>
              if data?
                @log "#{name} cache hit"
                Promise.resolve data
              else
                @log "#{name} cache miss"
                @getData name, func, sync, opts
    }

  getData: (name, func, sync, opts) ->
    func (err) =>
      @error err, name, sync, opts
    , (data) =>
      @success data, name, opts

  error: (err, name, sync, opts) ->
    if opts.duplicate and not sync
      @log "#{name} get from duplicate"
      @cache.get "#{name}-duplicate"
      .then (data) =>
        if data?
          @log "#{name} duplicate hit"
          Promise.resolve data
        else
          @log "#{name} duplicate miss"
          Promise.reject err
      .catch (_err) ->
        Promise.reject _err
    else
      Promise.reject err

  success: (data, name, opts) ->
    arr = [
      @cache.set name, data, opts.expired
    ]
    if opts.duplicate is on
      @log "#{name} create duplicate"
      arr.push @cache.set "#{name}-duplicate", data, null
    Promise.all arr
    .then ->
      Promise.resolve data

module.exports = Cache