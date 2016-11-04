How to use
------------
```javascript
var CacheTool = require('express-cache-tool');
var cache = new CacheTool.Cache({
    duplicate: false, //default false, if true, will create a no expiration cache for this key
    expired: null //default null, ms
}, [debug]);
cache.use(CacheTool.MemoryCache);

var test_cache1 = cache.set('key1', {duplicate: true, expired: 60000}, [alias]);

app.get('/', test_cache1, function(req, res, next){
  //if define alias, use req.cache.alias
  //else use req.cache
  req.cache.get_or_create(function(fail, done){
    asyncFunc().then(done).catch(fail);
  }).then(function(result){
    res.json(result);
  }).catch(next);
});
```

> You also can set multiple cache in one route, like `app.get('/', test_cache1, test_cache2, function(req, res, next){})`

Cache scheme in express-cache-tool
------------------------------------
1. MemoryCache - `cache.use(MemoryCache)`
2. FileCache - `cache.use(FileCache)`
3. RedisCache - base on ioredis

#### Use RedisCache
```javascript
redisCache = RedisCache({
    conf: 'host:port', //or use cluster [{host: host, port: port}, ...]
    db: 0
}, [redis], [prefix]);
//if set redis, use a already exists redis connet, must be base on ioredis

cache.use(redisCache);
```

Custom cache scheme
--------------------
```javascript
var scheme = {
    set: function(key, value, expired){
        //return promise
    },
    get: function(key){
        //return promise
    }
}
cache.use(scheme);
```