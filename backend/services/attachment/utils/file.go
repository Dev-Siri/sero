package utils

import (
	"github.com/Dev-Siri/sero/backend/proto/attachmentpb"
	"github.com/Dev-Siri/sero/backend/services/attachment/constants"
)

func GetUploadThingFileURI(fileKey string) string {
	return "https://utfs.io/f/" + fileKey
}

func IsFileSizeAllowed(fileSize uint64, kind attachmentpb.AttachmentKind) bool {
	limit := constants.LimitToKindMap[kind]
	return fileSize <= limit
}
