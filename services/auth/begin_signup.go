package main

import (
	"context"

	authpb "github.com/Dev-Siri/sero/proto/authpb"
)

func (s *AuthService) BeginSignup(ctx context.Context, request *authpb.AuthRequest) (*authpb.SignupSession, error) {
	return &authpb.SignupSession{
		SessionId: "",
	}, nil
}
