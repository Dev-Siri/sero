package env

import (
	"errors"
	"os"
)

func GetAuthServiceURL() (string, error) {
	authServiceURL := os.Getenv("AUTH_SERVICE_URL")
	if authServiceURL == "" {
		return "", errors.New("environment 'AUTH_SERVICE_URL' variable not set")
	}

	return authServiceURL, nil
}
