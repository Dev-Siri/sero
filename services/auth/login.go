package main

import (
	"context"

	authpb "github.com/Dev-Siri/sero/proto/authpb"
)

func (s *AuthService) Login(ctx context.Context, request *authpb.AuthRequest) (*authpb.TokenResponse, error) {
	return &authpb.TokenResponse{
		AuthToken: "dummy_refresh_token",
	}, nil
}
