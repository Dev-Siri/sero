package env

import (
	"errors"
	"os"
)

func GetJwtSecret() (string, error) {
	jwtSecret := os.Getenv("JWT_SECRET")

	if jwtSecret == "" {
		return "", errors.New("environment 'JWT_SECRET' variable not set")
	}
	return jwtSecret, nil
}
