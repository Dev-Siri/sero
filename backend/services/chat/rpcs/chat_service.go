package chat_rpcs

import "github.com/Dev-Siri/sero/backend/proto/chatpb"

type ChatService struct {
	chatpb.UnimplementedChatServiceServer
}

func NewChatService() *ChatService {
	return &ChatService{}
}
