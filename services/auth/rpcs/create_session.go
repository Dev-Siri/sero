package rpcs

import (
	"context"

	authpb "github.com/Dev-Siri/sero/proto/authpb"
	"github.com/Dev-Siri/sero/services/auth/constants"
	"github.com/Dev-Siri/sero/services/auth/db"
	"github.com/Dev-Siri/sero/services/auth/sms"
	"github.com/Dev-Siri/sero/services/auth/utils"
	"github.com/Dev-Siri/sero/shared/logging"
	"github.com/google/uuid"
	"github.com/redis/go-redis/v9"
	"go.uber.org/zap"
)

func (s *AuthService) CreateSession(ctx context.Context, request *authpb.SessionRequest) (*authpb.SessionResponse, error) {
	existingSession, err := db.Redis.Get(ctx, request.Phone).Result()

	if err != nil && err != redis.Nil {
		logging.Logger.Error("Failed to get sessionId from Redis.", zap.Error(err))
		return nil, err
	}

	if err != redis.Nil {
		return &authpb.SessionResponse{
			SessionId: existingSession,
		}, nil
	}

	generatedSessionId := uuid.NewString()
	sessionOtp, err := utils.GenerateOTP(constants.ApplicationOtpLength)

	if err != nil {
		logging.Logger.Error("Failed to generate sessionOtp.", zap.Error(err))
		return nil, err
	}

	otpIsVerifiedKey := utils.GetOtpIsVerifiedKey(sessionOtp)

	if err := db.Redis.Set(ctx, request.Phone, generatedSessionId, constants.ApplicationOtpTimeout).Err(); err != nil {
		logging.Logger.Error("Failed to create the session (phone) in the database.", zap.Error(err))
		return nil, err
	}

	if err := db.Redis.Set(ctx, generatedSessionId, sessionOtp, constants.ApplicationOtpTimeout).Err(); err != nil {
		logging.Logger.Error("Failed to create the session (sessionId) in the database.", zap.Error(err))
		return nil, err
	}

	if err := db.Redis.Set(ctx, otpIsVerifiedKey, false, constants.ApplicationOtpTimeout).Err(); err != nil {
		logging.Logger.Error("Failed to create the OTP in the database.", zap.Error(err))
		return nil, err
	}

	if err := sms.SendOTPMessage(request.Phone, sessionOtp); err != nil {
		return nil, err
	}

	return &authpb.SessionResponse{
		SessionId: generatedSessionId,
	}, nil
}
