package db

import (
	"database/sql"

	"github.com/Dev-Siri/sero/shared/env"
	_ "github.com/lib/pq"
)

var Database *sql.DB

func Connect() error {
	dsn, err := env.GetDSN()
	if err != nil {
		return err
	}

	db, err := sql.Open("postgres", dsn)

	if err != nil {
		return err
	}

	Database = db
	return nil
}
