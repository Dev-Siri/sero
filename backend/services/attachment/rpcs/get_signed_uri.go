package attachment_rpcs

import (
	"context"

	"github.com/Dev-Siri/sero/backend/proto/attachmentpb"
	"github.com/Dev-Siri/sero/backend/services/attachment/api"
	"github.com/Dev-Siri/sero/backend/services/attachment/models"
	"github.com/Dev-Siri/sero/backend/shared/logging"
	"go.uber.org/zap"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

func (a *AttachmentService) GetSignedURI(
	ctx context.Context,
	request *attachmentpb.GetSignedURIRequest,
) (*attachmentpb.GetSignedURIResponse, error) {
	response, err := api.GetPresignedURL(models.UploadThingRequestFile{
		FileName: request.Name,
		FileSize: request.Size,
		FileType: request.MimeType,
	})
	if err != nil {
		logging.Logger.Error("Failed to get signed URI.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Failed to get signed URI.")
	}

	return &attachmentpb.GetSignedURIResponse{
		UploadUri: response.Url,
		FileKey:   response.Key,
	}, nil
}
