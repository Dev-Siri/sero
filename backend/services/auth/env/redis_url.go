package env

import (
	"errors"
	"os"
)

func GetRedisURL() (string, error) {
	redisUrl := os.Getenv("REDIS_URL")

	if redisUrl == "" {
		return "", errors.New("environment 'REDIS_URL' variable not set")
	}

	return redisUrl, nil
}
