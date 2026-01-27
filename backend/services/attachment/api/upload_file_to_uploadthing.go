package api

import (
	"bytes"
	"mime/multipart"
	"net/http"

	"github.com/Dev-Siri/sero/backend/services/attachment/models"
)

// Returns the fileKey after upload.
func UploadFileToUploadThing(file models.UploadThingRequestFile, fileContent []byte) (string, error) {
	response, err := GetPresignedURL(file)
	if err != nil {
		return "", err
	}

	var formBuffer bytes.Buffer
	writer := multipart.NewWriter(&formBuffer)

	fileWriter, err := writer.CreateFormFile("file", file.FileName)
	if err != nil {
		return "", err
	}

	if _, err = fileWriter.Write(fileContent); err != nil {
		return "", err
	}

	if err = writer.Close(); err != nil {
		return "", err
	}

	fileRequest, err := http.NewRequest(http.MethodPut, response.Url, &formBuffer)
	if err != nil {
		return "", err
	}

	fileRequest.Header.Set("Content-Type", writer.FormDataContentType())

	uploadResponse, err := http.DefaultClient.Do(fileRequest)
	if err != nil {
		return "", err
	}

	if uploadResponse.StatusCode < 200 || uploadResponse.StatusCode >= 300 {
		return "", err
	}

	return response.Key, nil
}
