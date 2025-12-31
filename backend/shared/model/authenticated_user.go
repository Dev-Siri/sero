package model

import (
	"errors"

	"github.com/golang-jwt/jwt/v5"
)

type AuthenticatedUser struct {
	UserId string `json:"user_id"`
	Phone  string `json:"phone"`
}

func ClaimsToAuthenticatedUsers(claims jwt.MapClaims) (AuthenticatedUser, error) {
	userId := claims["user_id"].(string)
	phone := claims["phone"].(string)

	if userId == "" {
		return AuthenticatedUser{}, errors.New("`user_id` cannot be empty")
	}

	if phone == "" {
		return AuthenticatedUser{}, errors.New("`phone` cannot be empty")
	}

	return AuthenticatedUser{
		UserId: userId,
		Phone:  phone,
	}, nil
}
