package auth_rpcs

import (
	"context"

	authpb "github.com/Dev-Siri/sero/backend/proto/authpb"
	"github.com/Dev-Siri/sero/backend/shared/db"
	"github.com/Dev-Siri/sero/backend/shared/logging"
	"go.uber.org/zap"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
	"google.golang.org/protobuf/types/known/emptypb"
)

func (s *AuthService) UpdateStatus(
	ctx context.Context,
	request *authpb.UpdateStatusRequest,
) (*emptypb.Empty, error) {
	row := db.Database.QueryRow(`
		SELECT COUNT(*) FROM Users
		WHERE user_id = $1;
	`, request.UserId)

	var userCount int

	if err := row.Scan(&userCount); err != nil {
		logging.Logger.Error("Failed to read userId count from database.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Failed to read userId count from database.")
	}

	if userCount < 1 {
		logging.Logger.Error("User does not exist.")
		return nil, status.Error(codes.NotFound, "User does not exist.")
	}

	_, err := db.Database.Exec(`
		UPDATE Users
		SET "status_text" = $1
		WHERE user_id = $2;
	`, request.Status, request.UserId)

	if err != nil {
		logging.Logger.Error("Failed to update the status of user.", zap.String("userId", request.UserId), zap.Error(err))
		return nil, status.Error(codes.Internal, "Failed to update the status of user.")
	}

	return &emptypb.Empty{}, nil
}
