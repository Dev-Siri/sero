package env

import (
	"os"
)

func GetCorsOrigin() string {
	authServiceUrl := os.Getenv("CORS_ORIGIN")

	if authServiceUrl == "" {
		return ""
	}

	return authServiceUrl
}
