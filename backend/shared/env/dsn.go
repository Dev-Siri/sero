package env

import (
	"errors"
	"os"
)

func GetDSN() (string, error) {
	dsn := os.Getenv("DSN")

	if dsn == "" {
		return "", errors.New("no 'DSN' environment variable found")
	}

	return dsn, nil
}
