package rpcs

import (
	"context"

	authpb "github.com/Dev-Siri/sero/backend/proto/authpb"
	"github.com/Dev-Siri/sero/backend/services/auth/constants"
	"github.com/Dev-Siri/sero/backend/services/auth/db"
	"github.com/Dev-Siri/sero/backend/services/auth/sms"
	"github.com/Dev-Siri/sero/backend/services/auth/utils"
	"github.com/Dev-Siri/sero/backend/shared/logging"
	"github.com/google/uuid"
	"github.com/redis/go-redis/v9"
	"go.uber.org/zap"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

func (s *AuthService) CreateSession(ctx context.Context, request *authpb.SessionRequest) (*authpb.Session, error) {
	existingSession, err := db.Redis.Get(ctx, request.Phone).Result()

	if err != nil && err != redis.Nil {
		logging.Logger.Error("Failed to get sessionId from Redis.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Failed to get sessionId from Redis.")
	}

	if err != redis.Nil {
		return &authpb.Session{
			SessionId: existingSession,
		}, nil
	}

	generatedSessionId := uuid.NewString()
	sessionOtp, err := utils.GenerateOTP(constants.ApplicationOtpLength)

	if err != nil {
		logging.Logger.Error("Failed to generate sessionOtp.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Failed to generate sessionOtp.")
	}

	otpIsVerifiedKey := utils.GetOtpIsVerifiedKey(sessionOtp)

	if err := db.Redis.Set(ctx, request.Phone, generatedSessionId, constants.ApplicationOtpTimeout).Err(); err != nil {
		logging.Logger.Error("Failed to create the session (phone) in the database.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Failed to create the session (phone) in the database.")
	}

	if err := db.Redis.Set(ctx, generatedSessionId, sessionOtp, constants.ApplicationOtpTimeout).Err(); err != nil {
		logging.Logger.Error("Failed to create the session (sessionId) in the database.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Failed to create the session (sessionId) in the database.")
	}

	if err := db.Redis.Set(ctx, otpIsVerifiedKey, false, constants.ApplicationOtpTimeout).Err(); err != nil {
		logging.Logger.Error("Failed to create the OTP in the database.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Failed to create the OTP in the database.")
	}

	if err := sms.SendOTPMessage(request.Phone, sessionOtp); err != nil {
		logging.Logger.Error("Failed to send OTP message to phone.", zap.String("phone", request.Phone), zap.Error(err))
		return nil, status.Error(codes.Internal, "Failed to send OTP message to phone.")
	}

	return &authpb.Session{
		SessionId: generatedSessionId,
	}, nil
}
