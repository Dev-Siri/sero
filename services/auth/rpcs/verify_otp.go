package rpcs

import (
	"context"

	authpb "github.com/Dev-Siri/sero/proto/authpb"
	"github.com/Dev-Siri/sero/services/auth/constants"
	"github.com/Dev-Siri/sero/services/auth/db"
	"github.com/Dev-Siri/sero/services/auth/utils"
)

func (s *AuthService) VerifyOtp(ctx context.Context, request *authpb.OtpRequest) (*authpb.OtpResponse, error) {
	otp, err := db.Redis.Get(ctx, request.SessionId).Result()

	if err != nil {
		return nil, err
	}

	if otp == "" {
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
		return nil, err
	}

	return &authpb.OtpResponse{
		OtpValidityStatus: authpb.OtpResponse_VALID_OTP,
	}, nil
}
