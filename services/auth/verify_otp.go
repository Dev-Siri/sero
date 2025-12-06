package main

import (
	"context"

	authpb "github.com/Dev-Siri/sero/proto/authpb"
)

func (s *AuthService) VerifyOtp(ctx context.Context, request *authpb.OtpRequest) (*authpb.OtpResponse, error) {
	return &authpb.OtpResponse{
		IsOtpValid: false,
	}, nil
}
