package models

import "time"

type User struct {
	UserId      string
	Phone       string
	DisplayName string
	CreatedAt   time.Time
	StatusText  string
	PictureUrl  string
}
