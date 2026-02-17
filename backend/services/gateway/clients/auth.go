package clients

import (
	"github.com/Dev-Siri/sero/backend/proto/authpb"
	"github.com/Dev-Siri/sero/backend/services/gateway/env"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
)

func CreateAuthClient() (authpb.AuthServiceClient, error) {
	authServiceURL, err := env.GetAuthServiceURL()
	if err != nil {
		return nil, err
	}

	connection, err := grpc.NewClient(authServiceURL, grpc.WithTransportCredentials(insecure.NewCredentials()))
	if err != nil {
		return nil, err
	}

	client := authpb.NewAuthServiceClient(connection)
	return client, nil
}
