package env

import (
	"errors"
	"os"

	"github.com/twilio/twilio-go"
)

func GetTwilioCredentials() (twilio.ClientParams, error) {
	accountSid := os.Getenv("TWILIO_SID")
	authToken := os.Getenv("TWILIO_AUTH_TOKEN")

	if accountSid == "" {
		return twilio.ClientParams{}, errors.New("environment 'TWILIO_SID' variable not set")
	}

	if authToken == "" {
		return twilio.ClientParams{}, errors.New("environment 'TWILIO_AUTH_TOKEN' variable not set")
	}

	return twilio.ClientParams{
		AccountSid: accountSid,
		Password:   authToken,
	}, nil
}
