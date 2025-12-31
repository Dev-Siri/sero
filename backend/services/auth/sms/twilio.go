package sms

import (
	"github.com/Dev-Siri/sero/backend/services/auth/constants"
	"github.com/twilio/twilio-go"
	twilioApi "github.com/twilio/twilio-go/rest/api/v2010"
)

var client *twilio.RestClient

func InitTwilio() {
	client = twilio.NewRestClientWithParams(twilio.ClientParams{})
}

func SendOTPMessage(to, otp string) error {
	params := &twilioApi.CreateMessageParams{}
	params.SetTo(to)
	params.SetFrom(constants.TwilioSenderPhone)
	params.SetBody("Your one-time password for logging into Sero: " + otp)

	_, err := client.Api.CreateMessage(params)

	return err
}
