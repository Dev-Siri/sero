package auth_rpcs

import (
	"context"

	"github.com/Dev-Siri/sero/backend/proto/authpb"
	"github.com/Dev-Siri/sero/backend/shared/db"
	"github.com/Dev-Siri/sero/backend/shared/logging"
	"go.uber.org/zap"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
	"google.golang.org/protobuf/types/known/emptypb"
)

func (s *AuthService) RevokePublicKey(
	ctx context.Context,
	request *authpb.RevokePublicKeyRequest,
) (*emptypb.Empty, error) {
	_, err := db.Database.Exec(`
		UPDATE Keys
		SET revoked_at = CURRENT_TIMESTAMP
		WHERE "user_id" = $1;
	`, request.UserId)
	if err != nil {
		logging.Logger.Error("Failed to update revoke field for userId.", zap.Error(err), zap.String("userId", request.UserId))
		return nil, status.Error(codes.Internal, "Failed to update revoke field for userId.")
	}

	return &emptypb.Empty{}, nil
}
