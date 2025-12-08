package rpcs

import "github.com/Dev-Siri/sero/proto/authpb"

type AuthService struct {
	authpb.UnimplementedAuthServiceServer
}
