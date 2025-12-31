package env

import (
	"errors"
	"os"
)

func GetAuthServiceURL() (string, error) {
	authServiceUrl := os.Getenv("AUTH_SERVICE_URL")

	if authServiceUrl == "" {
		return "", errors.New("environment 'AUTH_SERVICE_URL' variable not set")
	}

	return authServiceUrl, nil
}
