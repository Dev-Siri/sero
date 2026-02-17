package chat_rpcs

import (
	"context"

	"github.com/Dev-Siri/sero/backend/proto/chatpb"
	"github.com/Dev-Siri/sero/backend/proto/commonpb"
	"github.com/Dev-Siri/sero/backend/shared/db"
	"github.com/Dev-Siri/sero/backend/shared/logging"
	"go.uber.org/zap"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

func (c *ChatService) GetUserChatRooms(
	ctx context.Context,
	request *chatpb.GetUserChatRoomsRequest,
) (*chatpb.GetUserChatRoomsResponse, error) {
	rows, err := db.Database.Query(`
		SELECT
			r.room_id,
			r.created_at,

			su.user_id AS sender_user_id,
			su.phone AS sender_phone,
			su.created_at AS sender_created_at,
			su.display_name AS sender_display_name,
			su.status_text AS sender_status_text,
			su.picture_url AS sender_picture_url,

			ru.user_id AS receiver_user_id,
			ru.phone AS receiver_phone,
			ru.created_at AS receiver_created_at,
			ru.display_name AS receiver_display_name,
			ru.status_text AS receiver_status_text,
			ru.picture_url AS receiver_picture_url
		FROM Rooms r
		INNER JOIN Users su
		ON r.sender_id = su.user_id
		INNER JOIN Users ru
		ON r.receiver_id = ru.user_id
		WHERE r.sender_id = $1
		OR r.receiver_id = $1;
	`, request.UserId)
	if err != nil {
		logging.Logger.Error("User's rooms fetch failed.", zap.Error(err), zap.String("userId", request.UserId))
		return nil, status.Error(codes.Internal, "User's rooms fetch failed.")
	}

	defer rows.Close()

	rooms := make([]*chatpb.ChatRoom, 0)
	for rows.Next() {
		var room chatpb.ChatRoom
		receiver := &commonpb.User{}
		sender := &commonpb.User{}

		if err := rows.Scan(
			&room.RoomId,
			&room.CreatedAt,

			&sender.UserId,
			&sender.Phone,
			&sender.CreatedAt,
			&sender.DisplayName,
			&sender.StatusText,
			&sender.PictureUrl,

			&receiver.UserId,
			&receiver.Phone,
			&receiver.CreatedAt,
			&receiver.DisplayName,
			&receiver.StatusText,
			&receiver.PictureUrl,
		); err != nil {
			logging.Logger.Error("Parsing one of the rooms failed.", zap.Error(err))
			return nil, status.Error(codes.Internal, "Parsing one of the rooms failed.")
		}

		room.Sender = sender
		room.Receiver = receiver
		room.IsUserSender = sender.UserId == request.UserId

		rooms = append(rooms, &room)
	}

	return &chatpb.GetUserChatRoomsResponse{
		ChatRooms: rooms,
	}, nil
}
