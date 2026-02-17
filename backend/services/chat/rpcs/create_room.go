package chat_rpcs

import (
	"context"

	"github.com/Dev-Siri/sero/backend/proto/chatpb"
	"github.com/Dev-Siri/sero/backend/shared/db"
	"github.com/Dev-Siri/sero/backend/shared/logging"
	"github.com/google/uuid"
	"go.uber.org/zap"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

func (c *ChatService) CreateRoom(
	ctx context.Context,
	request *chatpb.CreateRoomRequest,
) (*chatpb.CreateRoomResponse, error) {
	row := db.Database.QueryRow(`
		SELECT COUNT(*) FROM Rooms
		WHERE sender_id = $1 AND receiver_id = $2;
	`, request.SenderId, request.ReceiverId)

	var roomCount int
	if err := row.Scan(&roomCount); err != nil {
		logging.Logger.Error("Room count read failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Room count read failed.")
	}

	if roomCount > 0 {
		logging.Logger.Error("Room already exists for senderId and recieverId.",
			zap.String("senderId", request.SenderId),
			zap.String("receiverId", request.ReceiverId),
		)
		return nil, status.Error(codes.AlreadyExists, "Room already exists for senderId and recieverId.")
	}

	roomID := uuid.NewString()

	_, err := db.Database.Exec(`
		INSERT INTO Rooms(
			room_id,
			sender_id,
			receiver_id
		) VALUES ( $1, $2, $3 );
	`, roomID, request.SenderId, request.ReceiverId)
	if err != nil {
		logging.Logger.Error("Room creation failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Room creation failed.")
	}

	return &chatpb.CreateRoomResponse{
		RoomId: roomID,
	}, nil
}
