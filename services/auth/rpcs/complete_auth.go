package rpcs

import (
	"context"
	"fmt"

	authpb "github.com/Dev-Siri/sero/proto/authpb"
	"github.com/Dev-Siri/sero/services/auth/db"
	"github.com/Dev-Siri/sero/services/auth/env"
	"github.com/Dev-Siri/sero/services/auth/utils"
	shared_db "github.com/Dev-Siri/sero/shared/db"
	"github.com/Dev-Siri/sero/shared/logging"
	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
	"github.com/redis/go-redis/v9"
	"go.uber.org/zap"
)

func (s *AuthService) CompleteAuth(ctx context.Context, request *authpb.CompleteAuthRequest) (*authpb.AuthResponse, error) {
	otp, err := db.Redis.Get(ctx, request.SessionId).Result()

	if err != nil && err != redis.Nil {
		logging.Logger.Error("Failed to get otp from Redis.", zap.Error(err))
		return nil, err
	}

	if err == redis.Nil {
		logging.Logger.Error("No OTP found for sessionId.", zap.String("sessionId", request.SessionId))
		return nil, fmt.Errorf("no OTP found for sessionId: %s", request.SessionId)
	}

	isOtpVerifiedKey := utils.GetOtpIsVerifiedKey(otp)
	isOtpVerified, err := db.Redis.Get(ctx, isOtpVerifiedKey).Bool()

	if err != nil {
		logging.Logger.Error("Failed to get isOtpVerified value from ", zap.String("sessionId", request.SessionId))
		return nil, err
	}

	if !isOtpVerified {
		logging.Logger.Error("OTP not verified for sessionId.", zap.String("sessionId", request.SessionId))
		return nil, fmt.Errorf("OTP not verified for session ID: %s", request.SessionId)
	}

	row, err := shared_db.Database.Query(`
		SELECT user_id FROM Users
		WHERE phone = $1
		LIMIT 1;
	`, request.Phone)

	if err != nil {
		logging.Logger.Error("Failed to get userId from database.", zap.Error(err))
		return nil, err
	}

	defer row.Close()

	var userId string

	if row.Next() {
		if err := row.Scan(&userId); err != nil {
			logging.Logger.Error("Failed to decode userId from database row.", zap.Error(err))
			return nil, err
		}
	}

	var authType authpb.AuthResponse_AuthType

	if userId == "" {
		authType = authpb.AuthResponse_NEW
		userId = uuid.NewString()
	} else {
		authType = authpb.AuthResponse_EXISTING
	}

	jwtToken := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"user_id": userId,
		"phone":   request.Phone,
	})

	jwtSecret, err := env.GetJwtSecret()
	if err != nil {
		logging.Logger.Error("Failed to create JWT secret.", zap.Error(err))
		return nil, err
	}

	signedToken, err := jwtToken.SignedString(jwtSecret)

	if err != nil {
		logging.Logger.Error("Failed to generate signed token for user.", zap.Error(err))
		return nil, err
	}

	return &authpb.AuthResponse{
		AuthType: authType,
		UserId:   userId,
		Token:    signedToken,
	}, nil
}
