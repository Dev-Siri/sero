package rpcs

import (
	"context"

	"github.com/Dev-Siri/sero/backend/proto/authpb"
	"github.com/Dev-Siri/sero/backend/services/auth/constants"
	"github.com/Dev-Siri/sero/backend/services/auth/db"
	"github.com/Dev-Siri/sero/backend/services/auth/sms"
	"github.com/Dev-Siri/sero/backend/services/auth/utils"
	"github.com/Dev-Siri/sero/backend/shared/logging"
	"go.uber.org/zap"
	"google.golang.org/protobuf/types/known/emptypb"
)

func (s *AuthService) ResendOtp(ctx context.Context, request *authpb.ResendOtpRequest) (*emptypb.Empty, error) {
	generatedOtp, err := utils.GenerateOTP(constants.ApplicationOtpLength)

	if err != nil {
		logging.Logger.Error("Failed to regenerate OTP.", zap.Error(err))
		return nil, err
	}

	otpIsVerifiedKey := utils.GetOtpIsVerifiedKey(generatedOtp)
	if err := db.Redis.Set(ctx, request.SessionId, generatedOtp, constants.ApplicationOtpTimeout).Err(); err != nil {
		logging.Logger.Error("Failed to create the session (sessionId) in the database.", zap.Error(err))
		return nil, err
	}

	if err := db.Redis.Set(ctx, otpIsVerifiedKey, false, constants.ApplicationOtpTimeout).Err(); err != nil {
		logging.Logger.Error("Failed to create the OTP in the database.", zap.Error(err))
		return nil, err
	}

	if err := sms.SendOTPMessage(request.Phone, generatedOtp); err != nil {
		return nil, err
	}

	return &emptypb.Empty{}, nil
}
