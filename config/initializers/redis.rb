$redis = Redis.connect(url: ENV['REDIS_URL'])

# clean up redis
$redis.del(:source_queue)
