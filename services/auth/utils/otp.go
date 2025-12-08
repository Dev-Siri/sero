package utils

import (
	"crypto/rand"
)

func GenerateOTP(length int) (string, error) {
	const digits = "0123456789"
	otp := make([]byte, length)

	for i := range length {
		b := make([]byte, 1)

		if _, err := rand.Read(b); err != nil {
			return "", err
		}

		otp[i] = digits[int(b[0])%len(digits)]
	}

	return string(otp), nil
}

func GetOtpIsVerifiedKey(otp string) string {
	return "otp:verified:" + otp
}
