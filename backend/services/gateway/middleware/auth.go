package middleware

import (
	"context"
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
		go logging.Logger.Error("Invalid `Authorization` header.")
		return fiber.NewError(fiber.StatusUnauthorized, "Invalid `Authorization` header.")
	}

	authToken := authHeaderParts[1]

	token, err := jwt.Parse(authToken, func(t *jwt.Token) (any, error) {
		jwtKey, err := env.GetJwtSecret()

		if err != nil {
			go logging.Logger.Error("Failed to get jwtKey.", zap.Error(err))
			return nil, fiber.NewError(fiber.StatusUnauthorized, "Failed to get jwtKey.")
		}

		if _, ok := t.Method.(*jwt.SigningMethodHMAC); !ok {
			go logging.Logger.Error("Failed to get jwtKey.")
			return nil, fiber.NewError(fiber.StatusUnauthorized, "Unexpected signing method.")
		}

		return jwtKey, nil
	})

	if err != nil || !token.Valid {
		go logging.Logger.Error("This route is protected. Login to Sero to access it's contents.", zap.Error(err))
		return fiber.NewError(fiber.StatusUnauthorized, "This route is protected. Login to Sero to access it's contents.")
	}

	claims, ok := token.Claims.(jwt.MapClaims)

	if !ok || !token.Valid {
		return fiber.NewError(fiber.StatusUnauthorized, "Invalid token claims.")
	}

	user, err := model.ClaimsToAuthenticatedUsers(claims)

	if err != nil {
		go logging.Logger.Error("Failed to parse claims to AuthenticatedUser.", zap.Error(err))
		return fiber.NewError(fiber.StatusUnauthorized, "Failed to parse claims to AuthenticatedUser.")
	}

	ctx.Locals(constants.UserLocalKey, &user)
	return ctx.Next()
}

func AuthFromContext(ctx context.Context) *model.AuthenticatedUser {
	user := ctx.Value(constants.UserLocalKey).(*model.AuthenticatedUser)
	return user
}
