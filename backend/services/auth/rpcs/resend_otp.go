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
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
	"google.golang.org/protobuf/types/known/emptypb"
)

func (s *AuthService) ResendOtp(ctx context.Context, request *authpb.ResendOtpRequest) (*emptypb.Empty, error) {
	generatedOtp, err := utils.GenerateOTP(constants.ApplicationOtpLength)

	if err != nil {
		logging.Logger.Error("Failed to regenerate OTP.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Failed to regenerate OTP.")
	}

	otpIsVerifiedKey := utils.GetOtpIsVerifiedKey(generatedOtp)
	if err := db.Redis.Set(ctx, request.SessionId, generatedOtp, constants.ApplicationOtpTimeout).Err(); err != nil {
		logging.Logger.Error("Failed to create the session (sessionId) in the database.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Failed to create the session (sessionId) in the database.")
	}

	if err := db.Redis.Set(ctx, otpIsVerifiedKey, false, constants.ApplicationOtpTimeout).Err(); err != nil {
		logging.Logger.Error("Failed to create the OTP in the database.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Failed to create the OTP in the database.")
	}

	if err := sms.SendOTPMessage(request.Phone, generatedOtp); err != nil {
		logging.Logger.Error("Failed to resend OTP message to phone.", zap.String("phone", request.Phone), zap.Error(err))
		return nil, status.Error(codes.Internal, "Failed to resend OTP message to phone.")
	}

	return &emptypb.Empty{}, nil
}
