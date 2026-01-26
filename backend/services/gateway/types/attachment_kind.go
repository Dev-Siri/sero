package types

import (
	"github.com/Dev-Siri/sero/backend/proto/attachmentpb"
	"github.com/Dev-Siri/sero/backend/services/gateway/graph/model"
)

var AttachmentKindGqlToGrpcEnumMap = map[model.AttachmentKind]attachmentpb.AttachmentKind{
	model.AttachmentKindImage:    attachmentpb.AttachmentKind_ATTACHMENT_KIND_IMAGE,
	model.AttachmentKindVideo:    attachmentpb.AttachmentKind_ATTACHMENT_KIND_VIDEO,
	model.AttachmentKindDocument: attachmentpb.AttachmentKind_ATTACHMENT_KIND_DOCUMENT,
}
