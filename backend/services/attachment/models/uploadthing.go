package models

type UploadThingRequestFile struct {
	FileName string `json:"fileName"`
	FileSize uint64 `json:"fileSize"`
	FileType string `json:"fileType"`
}

type UploadThingResponse struct {
	Key string `json:"key"`
	Url string `json:"url"`
}
