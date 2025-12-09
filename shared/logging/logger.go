package logging

import (
	"github.com/Dev-Siri/sero/services/gateway/constants"
	"github.com/Dev-Siri/sero/services/gateway/env"
	"go.uber.org/zap"
)

var Logger *zap.Logger

func InitLogger() error {
	goEnv := env.GetGoEnv()
	var initZap *zap.Logger
	var err error

	if goEnv == constants.GoEnvProduction {
		initZap, err = zap.NewProduction()
	} else {
		initZap, err = zap.NewDevelopment()
	}

	if err != nil {
		return err
	}

	Logger = initZap
	return nil
}

func DestoryLogger() error {
	if Logger != nil {
		return Logger.Sync()
	}

	return nil
}
