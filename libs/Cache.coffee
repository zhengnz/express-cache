_ = require 'lodash'
Promise = require 'bluebird'

class Cache
  constructor: (opts, @debug=false, @sync_key='_cacheSync') ->
    @opts = _.assign {
      duplicate: false
      expired: null
    }, opts
    @cache = null

  log: (msg) ->
    if @debug is on
      console.log msg

  use: (plane) ->
    @cache = plane()

  set: (name, opts={}, alias=null) ->
    self = @
    (req, res, next) ->
      if not _.has(self.cache, 'set') or not _.has self.cache, 'get'
        next new Error 'Please set cache plane'
        return

      if not _.has req, 'cache'
        req.cache = {}

      cache = req.cache

      if _.has cache, 'get_or_create'
        next new Error 'You have to set alias of every cache when use multiple cache in one route'
        return

      sync = _.has req.query, self.sync_key

      if _.isFunction name
        _cache = (obj) ->
          self._make Promise.resolve(name obj), opts, sync
      else
        _cache = self._make Promise.resolve(name), opts, sync

      if alias?
        cache[alias] = _cache
      else
        cache = _cache

      req.cache = cache

      next()

  _make: (get_name, opts, sync) ->
    self = @
    {
      get_or_create: (func) ->
        get_name.then (name) ->
          opts = _.assign self.opts, opts
          if sync is on
            self.log "#{name} force sync"
            self._getData name, func, opts, sync
          else
            self.log "#{name} get from cache"
            self.cache.get name
            .then (data) ->
              if data?
                self.log "#{name} cache hit"
                Promise.resolve data
              else
                self.log "#{name} cache miss"
                self._getData name, func, opts, sync
    }

  _getData: (name, func, opts, sync) ->
    self = @
    func (err) ->
      if opts.duplicate is on and sync is off
        self.log "#{name} get from duplicate"
        self.cache.get "#{name}-duplicate"
        .then (data) ->
          if data?
            self.log "#{name} duplicate hit"
            Promise.resolve data
          else
            self.log "#{name} duplicate miss"
            Promise.reject err
        .catch (_err) ->
          Promise.reject _err
      else
        Promise.reject err
    , (data) ->
      arr = [
        self.cache.set name, data, opts.expired
      ]
      if opts.duplicate is on
        self.log "#{name} create duplicate"
        arr.push self.cache.set "#{name}-duplicate", data, null
      Promise.all arr
      .then ->
        Promise.resolve data

module.exports = Cache