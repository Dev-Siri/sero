package rpcs

import (
	"context"

	authpb "github.com/Dev-Siri/sero/proto/authpb"
	"github.com/Dev-Siri/sero/services/auth/constants"
	"github.com/Dev-Siri/sero/services/auth/db"
	"github.com/Dev-Siri/sero/services/auth/utils"
	"github.com/google/uuid"
)

func (s *AuthService) CreateSession(ctx context.Context, request *authpb.SessionRequest) (*authpb.SessionResponse, error) {
	existingSession, err := db.Redis.Get(context.Background(), request.Phone).Result()

	if err != nil {
		return nil, err
	}

	if existingSession != "" {
		return &authpb.SessionResponse{
			SessionId: existingSession,
		}, nil
	}

	generatedSessionId := uuid.NewString()
	sessionOtp, err := utils.GenerateOTP(constants.ApplicationOtpLength)

	otpIsVerifiedKey := utils.GetOtpIsVerifiedKey(sessionOtp)

	if err != nil {
		return nil, err
	}

	if err := db.Redis.Set(context.Background(), request.Phone, generatedSessionId, 0).Err(); err != nil {
		return nil, err
	}

	if err := db.Redis.Set(context.Background(), generatedSessionId, sessionOtp, constants.ApplicationOtpTimeout).Err(); err != nil {
		return nil, err
	}

	if err := db.Redis.Set(context.Background(), otpIsVerifiedKey, false, constants.ApplicationOtpTimeout).Err(); err != nil {
		return nil, err
	}

	return &authpb.SessionResponse{
		SessionId: generatedSessionId,
	}, nil
}
