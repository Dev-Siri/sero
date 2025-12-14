package env

import (
	"errors"
	"os"
)

func GetJwtSecret() ([]byte, error) {
	jwtSecret := os.Getenv("JWT_SECRET")

	if jwtSecret == "" {
		return nil, errors.New("environment 'JWT_SECRET' variable not set")
	}
	return []byte(jwtSecret), nil
}
