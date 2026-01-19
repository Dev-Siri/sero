package rpcs

import (
	"context"

	"github.com/Dev-Siri/sero/backend/proto/authpb"
	"github.com/Dev-Siri/sero/backend/shared/db"
	"github.com/Dev-Siri/sero/backend/shared/logging"
	"go.uber.org/zap"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

func (s *AuthService) FetchUser(ctx context.Context, request *authpb.FetchUserRequest) (*authpb.User, error) {
	row := db.Database.QueryRow(`
		SELECT
			user_id,
			phone,
			display_name,
			created_at,
			status_text,
			picture_url
		FROM Users
		WHERE user_id = $1
		LIMIT 1;
	`, request.UserId)

	var user authpb.User

	if err := row.Scan(
		&user.UserId,
		&user.Phone,
		&user.DisplayName,
		&user.CreatedAt,
		&user.StatusText,
		&user.PictureUrl,
	); err != nil {
		logging.Logger.Error("Failed to get user by userId.", zap.String("userId", request.UserId), zap.Error(err))
		return nil, status.Error(codes.Internal, "Failed to get user by userId.")
	}

	return &user, nil
}
