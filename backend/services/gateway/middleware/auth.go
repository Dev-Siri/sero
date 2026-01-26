package middleware

import (
	"context"
	"errors"
	"strings"

	"github.com/Dev-Siri/sero/backend/services/auth/env"
	"github.com/Dev-Siri/sero/backend/services/gateway/constants"
	"github.com/Dev-Siri/sero/backend/shared/logging"
	"github.com/Dev-Siri/sero/backend/shared/model"
	"github.com/gofiber/fiber/v2"
	"github.com/golang-jwt/jwt/v5"
	"go.uber.org/zap"
)

func AuthMiddleware(ctx *fiber.Ctx) error {
	authHeader := ctx.Get("Authorization")

	if authHeader == "" {
		return ctx.Next()
	}

	authHeaderParts := strings.SplitN(authHeader, " ", 2)

	if len(authHeaderParts) != 2 || authHeaderParts[0] != "Bearer" {
		logging.Logger.Error("Invalid `Authorization` header.")
		return fiber.NewError(fiber.StatusUnauthorized, "Invalid `Authorization` header.")
	}

	authToken := authHeaderParts[1]

	user, err := ParseAuthToken(authToken)
	if err != nil {
		logging.Logger.Error("Failed to parse provided authToken.", zap.Error(err))
		return fiber.NewError(fiber.StatusUnauthorized, "Failed to parse provided authToken.")
	}

	ctx.Locals(constants.UserLocalKey, user)
	return ctx.Next()
}

func ParseAuthToken(authToken string) (*model.AuthenticatedUser, error) {
	token, err := jwt.Parse(authToken, func(t *jwt.Token) (any, error) {
		jwtKey, err := env.GetJwtSecret()

		if err != nil {
			logging.Logger.Error("Failed to get jwtKey.", zap.Error(err))
			return nil, errors.New("Failed to get jwtKey.")
		}

		if _, ok := t.Method.(*jwt.SigningMethodHMAC); !ok {
			logging.Logger.Error("Failed to get jwtKey.")
			return nil, errors.New("Unexpected signing method.")
		}

		return jwtKey, nil
	})
	if err != nil || !token.Valid {
		return nil, errors.New("This route is protected. Login to Sero to access it's contents.")
	}

	claims, ok := token.Claims.(jwt.MapClaims)
	if !ok || !token.Valid {
		return nil, errors.New("Invalid token claims.")
	}

	user, err := model.ClaimsToAuthenticatedUsers(claims)
	return &user, err
}

func AuthFromContext(ctx context.Context) *model.AuthenticatedUser {
	user, ok := ctx.Value(constants.UserLocalKey).(*model.AuthenticatedUser)
	if !ok {
		return nil
	}

	return user
}
