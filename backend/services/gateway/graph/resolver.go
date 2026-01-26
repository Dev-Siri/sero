package graph

import (
	"github.com/Dev-Siri/sero/backend/proto/attachmentpb"
	"github.com/Dev-Siri/sero/backend/proto/authpb"
)

type Resolver struct {
	AuthService       authpb.AuthServiceClient
	AttachmentService attachmentpb.AttachmentServiceClient
}
