package main

import (
	"log"
	"net"

	authpb "github.com/Dev-Siri/sero/backend/proto/authpb"
	"github.com/Dev-Siri/sero/backend/services/auth/db"
	"github.com/Dev-Siri/sero/backend/services/auth/rpcs"
	"github.com/Dev-Siri/sero/backend/services/auth/sms"
	shared_db "github.com/Dev-Siri/sero/backend/shared/db"
	"github.com/Dev-Siri/sero/backend/shared/env"
	"github.com/Dev-Siri/sero/backend/shared/logging"
	"go.uber.org/zap"

	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection"
)

func main() {
	if err := logging.InitLogger(); err != nil {
		log.Fatalf("Failed to initialize logger: %s", err.Error())
	}

	if err := env.InitEnv(); err != nil {
		logging.Logger.Error("Failed to initialize environment variables.", zap.Error(err))
	}

	if err := db.InitRedis(); err != nil {
		logging.Logger.Error("Failed to initialize Redis connection.", zap.Error(err))
	}

	defer func() {
		if err := db.DestroyRedis(); err != nil {
			logging.Logger.Error("Failed to close Redis connection.", zap.Error(err))
		}
	}()

	if err := shared_db.Connect(); err != nil {
		logging.Logger.Error("Failed to initialize Postgres connection.", zap.Error(err))
	}

	sms.InitTwilio()

	port := env.GetPort()
	addr := ":" + port

	listener, err := net.Listen("tcp", addr)
	if err != nil {
		logging.Logger.Error("TCP Listener failed to listen on provided address.", zap.String("addr", addr), zap.Error(err))
	}

	grpcServer := grpc.NewServer(
		grpc.UnaryInterceptor(logging.GrpcLoggingInterceptor),
	)
	authpb.RegisterAuthServiceServer(grpcServer, &rpcs.AuthService{})
	reflection.Register(grpcServer)

	logging.Logger.Info("AuthService listening on "+addr, zap.String("port", port))
	if err := grpcServer.Serve(listener); err != nil {
		logging.Logger.Error("AuthService launch failed.", zap.Error(err))
	}
}
