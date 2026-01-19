package rpcs

import (
	"context"

	authpb "github.com/Dev-Siri/sero/backend/proto/authpb"
	"github.com/Dev-Siri/sero/backend/services/auth/constants"
	"github.com/Dev-Siri/sero/backend/services/auth/db"
	"github.com/Dev-Siri/sero/backend/services/auth/utils"
	"github.com/Dev-Siri/sero/backend/shared/logging"
	"github.com/redis/go-redis/v9"
	"go.uber.org/zap"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

func (s *AuthService) VerifyOtp(ctx context.Context, request *authpb.OtpRequest) (*authpb.OtpResponse, error) {
	otp, err := db.Redis.Get(ctx, request.SessionId).Result()

	if err != nil && err != redis.Nil {
		logging.Logger.Error("Failed to get OTP from Redis.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Failed to get OTP from Redis.")
	}

	if err == redis.Nil {
		// Does not exist, so it's likely expired.
		return &authpb.OtpResponse{
			OtpValidityStatus: authpb.OtpResponse_EXPIRED_OTP,
		}, nil
	}

	if otp != request.Otp {
		return &authpb.OtpResponse{
			OtpValidityStatus: authpb.OtpResponse_INVALID_OTP,
		}, nil
	}

	if err := db.Redis.Set(ctx, utils.GetOtpIsVerifiedKey(otp), true, constants.ApplicationOtpTimeout).Err(); err != nil {
		logging.Logger.Error("Failed to get otpIsVerifiedKey.", zap.String("otp", otp), zap.Error(err))
		return nil, status.Error(codes.Internal, "Failed to get otpIsVerifiedKey.")
	}

	return &authpb.OtpResponse{
		OtpValidityStatus: authpb.OtpResponse_VALID_OTP,
	}, nil
}
