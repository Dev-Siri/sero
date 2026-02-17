package graph

import (
	"github.com/Dev-Siri/sero/backend/proto/attachmentpb"
	"github.com/Dev-Siri/sero/backend/proto/authpb"
	"github.com/Dev-Siri/sero/backend/proto/chatpb"
)

type Resolver struct {
	AuthService       authpb.AuthServiceClient
	AttachmentService attachmentpb.AttachmentServiceClient
	ChatService       chatpb.ChatServiceClient
}
