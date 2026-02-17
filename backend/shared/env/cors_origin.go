package env

import "os"

func GetCorsOrigin() string {
	corsOrigin := os.Getenv("CORS_ORIGIN")
	return corsOrigin
}
