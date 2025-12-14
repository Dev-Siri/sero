package rpcs

import (
	"context"

	"github.com/Dev-Siri/sero/proto/authpb"
	"github.com/Dev-Siri/sero/shared/db"
)

func (s *AuthService) FetchUser(ctx context.Context, request *authpb.FetchUserRequest) (*authpb.User, error) {
	row, err := db.Database.Query(`
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

	if err != nil {
		return nil, err
	}

	defer row.Close()

	var user authpb.User

	if row.Next() {
		if err := row.Scan(
			&user.UserId,
			&user.Phone,
			&user.DisplayName,
			&user.CreatedAt,
			&user.StatusText,
			&user.PictureUrl,
		); err != nil {
			return nil, err
		}
	}

	return &user, nil
}
