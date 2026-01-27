package constants

import "github.com/Dev-Siri/sero/backend/proto/attachmentpb"

const (
	_  = iota
	KB = 1 << (10 * iota)
	MB
)

const (
	AttachmentImageLimit    = MB * 10
	AttachmentVideoLimit    = MB * 100
	AttachmentDocumentLimit = MB * 100
)

var LimitToKindMap = map[attachmentpb.AttachmentKind]uint64{
	attachmentpb.AttachmentKind_ATTACHMENT_KIND_IMAGE:    AttachmentImageLimit,
	attachmentpb.AttachmentKind_ATTACHMENT_KIND_VIDEO:    AttachmentVideoLimit,
	attachmentpb.AttachmentKind_ATTACHMENT_KIND_DOCUMENT: AttachmentDocumentLimit,
}
