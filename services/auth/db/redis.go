package db

import (
	"github.com/Dev-Siri/sero/services/auth/env"
	"github.com/redis/go-redis/v9"
)

var Redis *redis.Client

func InitRedis() error {
	redisUrl, err := env.GetRedisURL()
	if err != nil {
		return err
	}

	options, err := redis.ParseURL(redisUrl)
	if err != nil {
		return err
	}

	Redis = redis.NewClient(options)
	return nil
}

func DestroyRedis() error {
	if Redis != nil {
		return Redis.Close()
	}

	return nil
}
