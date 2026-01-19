package env

import (
	"os"

	"github.com/Dev-Siri/sero/backend/shared/logging"
)

func GetPORT() string {
	port := os.Getenv("PORT")

	if port == "" {
		go logging.Logger.Warn("PORT environment variable not set, defaulting to 8000. May lead to conflicts if multiple services run on unset ports.")
		return "8000"
	}

	return port
}
