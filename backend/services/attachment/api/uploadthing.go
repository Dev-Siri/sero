package api

import (
	"bytes"
	"encoding/json"
	"io"
	"net/http"

	"github.com/Dev-Siri/sero/backend/services/attachment/constants"
	"github.com/Dev-Siri/sero/backend/services/attachment/env"
	"github.com/Dev-Siri/sero/backend/services/attachment/models"
	"github.com/Dev-Siri/sero/backend/shared/logging"
	"go.uber.org/zap"
)

func GetPresignedURL(fileInfo models.UploadThingRequestFile) (*models.UploadThingResponse, error) {
	uploadThingSecret, err := env.GetUploadThingSecret()
	if err != nil {
		logging.Logger.Error("Failed to get UploadThing secret secret.", zap.Error(err))
		return nil, err
	}

	jsonPayload, err := json.Marshal(fileInfo)
	if err != nil {
		logging.Logger.Error("An error occured while uploading the image.", zap.Error(err))
		return nil, err
	}

	jsonPayloadBuffer := bytes.NewBuffer(jsonPayload)
	uploadFilesRequest, err := http.NewRequest(http.MethodPost, constants.UploadThingApiUrl+"/v7/prepareUpload", jsonPayloadBuffer)

	uploadFilesRequest.Header.Set("Content-Type", "application/json")
	uploadFilesRequest.Header.Add("X-Uploadthing-Api-Key", uploadThingSecret)

	if err != nil {
		logging.Logger.Error("An error occured while uploading the image.", zap.Error(err))
		return nil, err
	}

	uploadFilesResponse, err := http.DefaultClient.Do(uploadFilesRequest)
	if err != nil {
		logging.Logger.Error("An error occured while retrieving the image URL.", zap.Error(err))
		return nil, err
	}

	defer uploadFilesResponse.Body.Close()

	var uploadThingResponse models.UploadThingResponse

	bodyBytes, err := io.ReadAll(uploadFilesResponse.Body)

	if err != nil {
		logging.Logger.Error("Upload response read failed.", zap.Error(err))
		return nil, err
	}

	if err = json.Unmarshal(bodyBytes, &uploadThingResponse); err != nil {
		logging.Logger.Error("Upload response parse failed.", zap.Error(err))
		return nil, err
	}

	return &uploadThingResponse, nil
}
