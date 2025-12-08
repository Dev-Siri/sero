package rpcs

import (
	"context"
	"fmt"

	authpb "github.com/Dev-Siri/sero/proto/authpb"
	"github.com/Dev-Siri/sero/services/auth/db"
	"github.com/Dev-Siri/sero/services/auth/env"
	"github.com/Dev-Siri/sero/services/auth/utils"
	shared_db "github.com/Dev-Siri/sero/shared/db"
	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
)

func (s *AuthService) CompleteAuth(ctx context.Context, request *authpb.CompleteAuthRequest) (*authpb.AuthResponse, error) {
	otp, err := db.Redis.Get(context.Background(), request.SessionId).Result()

	if err != nil {
		return nil, err
	}

	if otp == "" {
		return nil, fmt.Errorf("no OTP found for session ID: %s", request.SessionId)
	}

	isOtpVerifiedKey := utils.GetOtpIsVerifiedKey(otp)
	isOtpVerified, err := db.Redis.Get(context.Background(), isOtpVerifiedKey).Bool()

	if err != nil {
		return nil, err
	}

	if !isOtpVerified {
		return nil, fmt.Errorf("OTP not verified for session ID: %s", request.SessionId)
	}

	row, err := shared_db.Database.Query(`
		SELECT
			user_id,
		FROM User
		WHERE phone = $1
		LIMIT 1;
	`, request.Phone)

	if err != nil {
		return nil, err
	}

	var userId string

	if err := row.Scan(&userId); err != nil {
		return nil, err
	}

	var authType authpb.AuthResponse_AuthType

	if userId == "" {
		authType = authpb.AuthResponse_NEW_USER
		userId = uuid.NewString()
	} else {
		authType = authpb.AuthResponse_EXISTING_USER
	}

	jwtToken := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"user_id": userId,
		"phone":   request.Phone,
	})

	jwtSecret, err := env.GetJwtSecret()
	if err != nil {
		return nil, err
	}

	signedToken, err := jwtToken.SignedString(jwtSecret)

	if err != nil {
		return nil, err
	}

	return &authpb.AuthResponse{
		AuthType: authType,
		UserId:   userId,
		Token:    signedToken,
	}, nil
}
