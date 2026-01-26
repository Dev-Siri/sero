package auth_rpcs

import (
	"context"

	"github.com/Dev-Siri/sero/backend/proto/authpb"
	"github.com/Dev-Siri/sero/backend/shared/db"
	"github.com/Dev-Siri/sero/backend/shared/logging"
	"github.com/google/uuid"
	"go.uber.org/zap"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
	"google.golang.org/protobuf/types/known/emptypb"
)

func (s *AuthService) UploadPublicKey(
	ctx context.Context,
	request *authpb.UploadPublicKeyRequest,
) (*emptypb.Empty, error) {
	row := db.Database.QueryRow(`
		SELECT COUNT(*) FROM Keys
		WHERE "user_id" = $1
		AND "revoked_at" IS NULL;
	`, request.UserId)

	var keyCount int
	if err := row.Scan(&keyCount); err != nil {
		logging.Logger.Error("Failed to read number of keys for userId.", zap.Error(err), zap.String("userId", request.UserId))
		return nil, status.Error(codes.Internal, "Failed to read number of keys for userId.")
	}

	if keyCount > 0 {
		logging.Logger.Error("Key already exists for userId.", zap.String("userId", request.UserId))
		return nil, status.Error(codes.AlreadyExists, "Key already exists for userId.")
	}

	keyId := uuid.NewString()
	_, err := db.Database.Exec(`
		INSERT INTO Keys(
			key_id,
			user_id,
			public_key,
			algorithm
		) VALUES ( $1, $2, $3, $4 );
	`, keyId, request.UserId, request.PublicKey, request.Algorithm)
	if err != nil {
		logging.Logger.Error("Failed to store public key of userId.", zap.Error(err), zap.String("userId", request.UserId))
		return nil, status.Error(codes.Internal, "Failed to store public key of userId.")
	}

	return &emptypb.Empty{}, nil
}
