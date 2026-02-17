package env

import (
	"errors"
	"os"
)

func GetChatServiceURL() (string, error) {
	chatServiceURL := os.Getenv("CHAT_SERVICE_URL")
	if chatServiceURL == "" {
		return "", errors.New("environment 'CHAT_SERVICE_URL' variable not set")
	}

	return chatServiceURL, nil
}
