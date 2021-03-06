// Generated by CoffeeScript 1.10.0
(function() {
  var FileCacheSimple, Promise, cache;

  FileCacheSimple = require('file-cache-simple');

  Promise = require('bluebird');

  cache = new FileCacheSimple({
    'cacheDir': './cache',
    'prefix': '',
    'fixCacheExpire': false,
    'rejectOnNull': false
  });

  module.exports = function() {
    return {
      set: function(key, value, expired) {
        if (expired != null) {
          cache.set(key, value, expired);
        } else {
          cache.set(key, value);
        }
        return Promise.resolve();
      },
      get: function(key) {
        return cache.get(key);
      }
    };
  };

}).call(this);

//# sourceMappingURL=FileCache.js.map
