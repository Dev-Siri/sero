package env

import (
	"errors"
	"os"
)

func GetUploadThingSecret() (string, error) {
	uploadThingSecret := os.Getenv("UPLOADTHING_SECRET")

	if uploadThingSecret == "" {
		return "", errors.New("No UPLOADTHING_SECRET set.")
	}

	return uploadThingSecret, nil
}
