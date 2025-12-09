package env

import (
	"os"

	"github.com/Dev-Siri/sero/services/gateway/constants"
)

func GetGoEnv() constants.GoEnv {
	goEnv := os.Getenv("GO_ENV")

	if goEnv == "prod" {
		return constants.GoEnvProduction
	}

	return constants.GoEnvDev
}
