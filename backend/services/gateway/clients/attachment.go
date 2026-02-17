package clients

import (
	"github.com/Dev-Siri/sero/backend/proto/attachmentpb"
	"github.com/Dev-Siri/sero/backend/services/gateway/env"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
)

func CreateAttachmentClient() (attachmentpb.AttachmentServiceClient, error) {
	attachmentServiceURL, err := env.GetAttachmentServiceURL()
	if err != nil {
		return nil, err
	}

	connection, err := grpc.NewClient(attachmentServiceURL, grpc.WithTransportCredentials(insecure.NewCredentials()))
	if err != nil {
		return nil, err
	}

	client := attachmentpb.NewAttachmentServiceClient(connection)
	return client, nil
}
