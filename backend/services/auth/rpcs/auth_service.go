package auth_rpcs

import "github.com/Dev-Siri/sero/backend/proto/authpb"

type AuthService struct {
	authpb.UnimplementedAuthServiceServer
}

func NewAuthService() *AuthService {
	return &AuthService{}
}
