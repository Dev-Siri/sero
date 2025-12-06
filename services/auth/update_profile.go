package main

import (
	"context"

	authpb "github.com/Dev-Siri/sero/proto/authpb"
	"google.golang.org/protobuf/types/known/emptypb"
)

func (s *AuthService) UpdateProfile(ctx context.Context, req *authpb.UpdateProfileRequest) (*emptypb.Empty, error) {
	return &emptypb.Empty{}, nil
}
