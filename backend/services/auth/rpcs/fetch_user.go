package auth_rpcs

import (
	"context"

	"github.com/Dev-Siri/sero/backend/proto/authpb"
	"github.com/Dev-Siri/sero/backend/shared/db"
	"github.com/Dev-Siri/sero/backend/shared/logging"
	"go.uber.org/zap"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

func (s *AuthService) FetchUser(
	ctx context.Context,
	request *authpb.FetchUserRequest,
) (*authpb.User, error) {
	row := db.Database.QueryRow(`
		SELECT
			u.user_id,
			u.phone,
			u.display_name,
			u.created_at,
			u.status_text,
			COALESCE(a.processed_url, a.source_url) AS picture_url
		FROM Users AS u
		LEFT JOIN Attachments AS a
		ON u.picture_url_attachment = a.attachment_id
		WHERE u.user_id = $1
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
