import Redis from "ioredis";

const redisUrl = process.env.REDIS_URL || "redis://127.0.0.1:6379";

declare global {
  var redis: Redis | undefined;
}

const redis =
  global.redis ||
  new Redis(redisUrl, {
    family: 4, // Forza IPv4
    retryStrategy(times) {
      const delay = Math.min(times * 50, 2000);
      return delay;
    },
    maxRetriesPerRequest: null,
  });

if (process.env.NODE_ENV !== "production") {
  global.redis = redis;
}

redis.on("error", (err) => {
  console.error("Redis Error: ", err);
});

export default redis;
