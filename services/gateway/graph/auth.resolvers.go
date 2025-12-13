package graph

import (
	"context"

	"github.com/Dev-Siri/sero/proto/authpb"
	"github.com/Dev-Siri/sero/services/gateway/graph/model"
	"github.com/Dev-Siri/sero/shared/logging"
	"go.uber.org/zap"
)

func (r *mutationResolver) CreateSession(ctx context.Context, phone string) (*model.Session, error) {
	session, err := r.AuthService.CreateSession(ctx, &authpb.SessionRequest{
		Phone: phone,
	})

	if err != nil {
		logging.Logger.Error("resolver 'CreateSession' errored.", zap.Error(err))
		return nil, err
	}

	return &model.Session{SessionID: session.SessionId}, nil
}

func (r *mutationResolver) VerifyOtp(ctx context.Context, otp model.OtpInput) (model.OtpValidityStatus, error) {
	session, err := r.AuthService.VerifyOtp(ctx, &authpb.OtpRequest{
		SessionId: otp.SessionID,
		Otp:       otp.Otp,
	})

	if err != nil {
		logging.Logger.Error("resolver 'VerifyOtp' errored.", zap.Error(err))
		return "", err
	}

	var otpValidityStatus model.OtpValidityStatus

	switch session.OtpValidityStatus {
	case authpb.OtpResponse_EXPIRED_OTP:
		otpValidityStatus = model.OtpValidityStatusExpired
	case authpb.OtpResponse_VALID_OTP:
		otpValidityStatus = model.OtpValidityStatusValid
	default:
		otpValidityStatus = model.OtpValidityStatusInvalid
	}

	return otpValidityStatus, nil
}

func (r *mutationResolver) CompleteAuth(ctx context.Context, authInfo model.CompleteAuthInput) (*model.AuthenticatedUser, error) {
	authedUser, err := r.AuthService.CompleteAuth(ctx, &authpb.CompleteAuthRequest{
		SessionId: authInfo.SessionID,
		Phone:     authInfo.Phone,
	})

	if err != nil {
		logging.Logger.Error("resolver 'CompleteAuth' errored.", zap.Error(err))
		return nil, err
	}

	return &model.AuthenticatedUser{
		UserID:   authedUser.UserId,
		Token:    authedUser.Token,
		AuthType: model.AuthType(authedUser.AuthType),
	}, nil
}

func (r *Resolver) Mutation() MutationResolver { return &mutationResolver{r} }

type mutationResolver struct{ *Resolver }
