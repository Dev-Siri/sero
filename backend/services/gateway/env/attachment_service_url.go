package env

import (
	"errors"
	"os"
)

func GetAttachmentServiceURL() (string, error) {
	attachmentServiceURL := os.Getenv("ATTACHMENT_SERVICE_URL")
	if attachmentServiceURL == "" {
		return "", errors.New("environment 'ATTACHMENT_SERVICE_URL' variable not set")
	}

	return attachmentServiceURL, nil
}
