package bg

import (
	"io"
	"net/http"

	"github.com/Dev-Siri/sero/backend/services/attachment/api"
	"github.com/Dev-Siri/sero/backend/services/attachment/models"
	"github.com/Dev-Siri/sero/backend/services/attachment/utils"
	"github.com/Dev-Siri/sero/backend/shared/db"
	"github.com/Dev-Siri/sero/backend/shared/logging"
	"github.com/h2non/bimg"
	"go.uber.org/zap"
)

// Take file metadata, and process it in steps:
// 1. Fetch the file in bytes.
// 2. Use bimg (libvips) to compress the file.
// 3. Get UploadThing presigned URL.
// 4. Prepare and send a multipart request to upload the compressed file.
// 5. Update the database to reflect the processed_url.
func ProcessFile(fileName, fileUrl, attachmentId string) {
	fileBytes, err := fetchFileBytes(fileUrl)
	if err != nil {
		logging.Logger.Error("Failed to fetch source URL of attachment.", zap.Error(err), zap.String("attachmentId", attachmentId))
		return
	}

	compressedImage, err := compressImage(fileBytes)
	if err != nil {
		logging.Logger.Error("Failed to compress source URL file of attachment.", zap.Error(err), zap.String("attachmentId", attachmentId))
		return
	}

	const mimeType = "image/webp"
	compressedFileName := fileName + "-compressed.webp"
	fileSize := uint64(len(compressedImage))

	fileKey, err := api.UploadFileToUploadThing(models.UploadThingRequestFile{
		FileSize: fileSize,
		FileName: compressedFileName,
		FileType: mimeType,
	}, compressedImage)
	if err != nil {
		logging.Logger.Error("Failed to upload compressed file to UploadThing.", zap.Error(err))
		return
	}

	if err = notifyProcessedFileCompletionToDatabase(attachmentId, fileKey); err != nil {
		logging.Logger.Error("Compressed file field update in database field.", zap.Error(err))
		return
	}

	logging.Logger.Info("File compression for attachmentId succeeded.", zap.String("attachmentId", attachmentId))
}

func fetchFileBytes(fileUrl string) ([]byte, error) {
	file, err := http.DefaultClient.Get(fileUrl)
	if err != nil {
		return nil, err
	}

	defer file.Body.Close()

	return io.ReadAll(file.Body)
}

func compressImage(fileBytes []byte) ([]byte, error) {
	bImage := bimg.NewImage(fileBytes)
	compressedImg, err := bImage.Convert(bimg.WEBP)
	if err != nil {
		return nil, err
	}

	return compressedImg, nil
}

func notifyProcessedFileCompletionToDatabase(attachmentId, fileKey string) error {
	uploadedFileUrl := utils.GetUploadThingFileURI(fileKey)
	_, err := db.Database.Exec(`
		UPDATE Attachments
		SET processed_url = $1
		WHERE attachment_id = $2;
	`, uploadedFileUrl, attachmentId)

	return err
}
