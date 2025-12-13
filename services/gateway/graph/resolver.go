package graph

import "github.com/Dev-Siri/sero/proto/authpb"

type Resolver struct {
	AuthService authpb.AuthServiceClient
}
