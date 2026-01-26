package env

import (
	"errors"
	"os"
)

func GetAttachmentServiceUrl() (string, error) {
	attachmentServiceUrl := os.Getenv("ATTACHMENT_SERVICE_URL")

	if attachmentServiceUrl == "" {
		return "", errors.New("environment 'ATTACHMENT_SERVICE_URL' variable not set")
	}

	return attachmentServiceUrl, nil
}
