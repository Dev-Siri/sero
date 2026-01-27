package attachment_rpcs

import (
	"context"

	"github.com/Dev-Siri/sero/backend/proto/attachmentpb"
	"github.com/Dev-Siri/sero/backend/services/attachment/bg"
	"github.com/Dev-Siri/sero/backend/services/attachment/utils"
	shared_db "github.com/Dev-Siri/sero/backend/shared/db"
	"github.com/Dev-Siri/sero/backend/shared/logging"
	"github.com/google/uuid"
	"go.uber.org/zap"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

func (a *AttachmentService) UploadFile(
	ctx context.Context,
	request *attachmentpb.UploadFileRequest,
) (*attachmentpb.UploadFileResponse, error) {
	attachmentId := uuid.NewString()
	fileUrl := utils.GetUploadThingFileURI(request.FileKey)

	_, err := shared_db.Database.Exec(`
		INSERT INTO Attachments(
			attachment_id,
			file_name,
			mime_type,
			source_url
		) VALUES ( $1, $2, $3, $4 );
	`, attachmentId, request.Name, request.MimeType, fileUrl)
	if err != nil {
		logging.Logger.Error("Failed to upload attachment with fileKey.", zap.Error(err), zap.String("fileKey", request.FileKey))
		return nil, status.Error(codes.Internal, "Failed to upload attachment with fileKey.")
	}

	if request.Kind == attachmentpb.AttachmentKind_ATTACHMENT_KIND_IMAGE {
		go bg.ProcessFile(request.Name, fileUrl, attachmentId)
	}

	return &attachmentpb.UploadFileResponse{
		AttachmentId: attachmentId,
	}, nil
}
