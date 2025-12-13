package clients

import (
	"github.com/Dev-Siri/sero/proto/authpb"
	"github.com/Dev-Siri/sero/services/gateway/env"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
)

func CreateAuthClient() (authpb.AuthServiceClient, error) {
	authServiceUrl, err := env.GetAuthServiceURL()

	if err != nil {
		return nil, err
	}

	connection, err := grpc.NewClient(authServiceUrl, grpc.WithTransportCredentials(insecure.NewCredentials()))

	if err != nil {
		return nil, err
	}

	client := authpb.NewAuthServiceClient(connection)
	return client, nil
}
