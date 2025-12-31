package rpcs

import (
	"context"
	"errors"

	authpb "github.com/Dev-Siri/sero/backend/proto/authpb"
	"github.com/Dev-Siri/sero/backend/shared/db"
	"github.com/Dev-Siri/sero/backend/shared/logging"
	"go.uber.org/zap"
	"google.golang.org/protobuf/types/known/emptypb"
)

func (s *AuthService) UpdatePicture(ctx context.Context, request *authpb.UpdatePictureRequest) (*emptypb.Empty, error) {
	row := db.Database.QueryRow(`
		SELECT COUNT(*) FROM Users
		WHERE user_id = $1;
	`, request.UserId)

	var userCount int

	if err := row.Scan(&userCount); err != nil {
		go logging.Logger.Error("Failed to read userId count from database.", zap.Error(err))
		return nil, err
	}

	if userCount < 1 {
		go logging.Logger.Error("User does not exist.")
		return nil, errors.New("user does not exist")
	}

	_, err := db.Database.Exec(`
		UPDATE Users
		SET "picture_url" = $1
		WHERE user_id = $2;
	`, request.PictureUrl, request.UserId)

	if err != nil {
		go logging.Logger.Error("Failed to update the picture URL of user.", zap.String("userId", request.UserId), zap.Error(err))
		return nil, err
	}

	return &emptypb.Empty{}, nil
}
