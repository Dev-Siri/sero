package clients

import (
	"github.com/Dev-Siri/sero/backend/proto/chatpb"
	"github.com/Dev-Siri/sero/backend/services/gateway/env"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
)

func CreateChatClient() (chatpb.ChatServiceClient, error) {
	chatServiceURL, err := env.GetChatServiceURL()
	if err != nil {
		return nil, err
	}

	connection, err := grpc.NewClient(chatServiceURL, grpc.WithTransportCredentials(insecure.NewCredentials()))
	if err != nil {
		return nil, err
	}

	client := chatpb.NewChatServiceClient(connection)
	return client, nil
}
