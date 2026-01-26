package bg

import (
	"bytes"
	"io"
	"mime/multipart"
	"net/http"

	"github.com/Dev-Siri/sero/backend/services/attachment/api"
	"github.com/Dev-Siri/sero/backend/services/attachment/models"
	"github.com/Dev-Siri/sero/backend/services/attachment/utils"
	"github.com/Dev-Siri/sero/backend/shared/db"
	"github.com/Dev-Siri/sero/backend/shared/logging"
	"github.com/h2non/bimg"
	"go.uber.org/zap"
)

func CompressFile(attachmentId string) {
	attachment := db.Database.QueryRow(`
		SELECT
			source_url,
			file_name
		FROM Attachments
		WHERE attachment_id = $1
		AND file_name IS NOT NULL;
	`, attachmentId)

	var attachmentName string
	var sourceUrl string
	if err := attachment.Scan(&sourceUrl, &attachmentName); err != nil {
		logging.Logger.Error("Failed to get source of attachment.", zap.Error(err), zap.String("attachmentId", attachmentId))
		return
	}

	file, err := http.DefaultClient.Get(sourceUrl)
	if err != nil {
		logging.Logger.Error("Failed to fetch source URL of attachment.", zap.Error(err), zap.String("attachmentId", attachmentId))
		return
	}

	defer file.Body.Close()

	bodyBytes, err := io.ReadAll(file.Body)
	if err != nil {
		logging.Logger.Error("Failed to read source URL file of attachment.", zap.Error(err), zap.String("attachmentId", attachmentId))
		return
	}

	bImage := bimg.NewImage(bodyBytes)
	compressedImg, err := bImage.Convert(bimg.WEBP)
	if err != nil {
		logging.Logger.Error("Failed to compress source URL file of attachment.", zap.Error(err), zap.String("attachmentId", attachmentId))
		return
	}

	const mimeType = "image/webp"
	fileName := attachmentName + "-compressed"
	fileSize := len(compressedImg)

	response, err := api.GetPresignedURL(models.UploadThingRequestFile{
		FileSize: uint64(fileSize),
		FileName: fileName,
		FileType: mimeType,
	})
	if err != nil {
		logging.Logger.Error("Failed to get signed URI.", zap.Error(err))
		return
	}

	var formBuffer bytes.Buffer
	writer := multipart.NewWriter(&formBuffer)

	fileWriter, err := writer.CreateFormFile("file", fileName)

	if err != nil {
		logging.Logger.Error("Compress file upload failed.", zap.Error(err))
		return
	}

	if _, err = fileWriter.Write(compressedImg); err != nil {
		logging.Logger.Error("Compress file upload failed.", zap.Error(err))
		return
	}

	if err = writer.Close(); err != nil {
		logging.Logger.Error("Compress file upload failed.", zap.Error(err))
		return
	}

	fileRequest, err := http.NewRequest(http.MethodPut, response.Url, nil)
	if err != nil {
		logging.Logger.Error("Compressed file upload request formation failed.", zap.Error(err))
		return
	}

	uploadResponse, err := http.DefaultClient.Do(fileRequest)
	if err != nil {
		logging.Logger.Error("Compressed file upload response is unsuccessful.", zap.Error(err))
		return
	}

	if uploadResponse.StatusCode < 200 || uploadResponse.StatusCode >= 300 {
		logging.Logger.Error("Compressed file upload response status is unsuccessful.", zap.Error(err))
		return
	}

	uploadedFileUrl := utils.GetUploadThingFileURI(response.Key)

	_, err = db.Database.Exec(`
		UPDATE Attachments
		SET processed_url = $1
		WHERE attachment_id = $2;
	`, uploadedFileUrl, attachmentId)
	if err != nil {
		logging.Logger.Error("Compressed file field update in database field.", zap.Error(err))
		return
	}

	logging.Logger.Info("File compression for attachmentId succeeded.", zap.String("attachmentId", attachmentId))
}
