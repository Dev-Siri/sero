package logging

import "go.uber.org/zap"

var Logger *zap.Logger

func InitLogger() error {
	zap, err := zap.NewProduction()

	if err != nil {
		return err
	}

	Logger = zap
	return nil
}

func DestoryLogger() error {
	if Logger != nil {
		return Logger.Sync()
	}

	return nil
}
