package main

import (
	"log"
	"net"

	"github.com/Dev-Siri/sero/backend/proto/attachmentpb"
	attachment_rpcs "github.com/Dev-Siri/sero/backend/services/attachment/rpcs"
	"github.com/Dev-Siri/sero/backend/services/auth/sms"
	"github.com/Dev-Siri/sero/backend/shared/db"
	"github.com/Dev-Siri/sero/backend/shared/env"
	"github.com/Dev-Siri/sero/backend/shared/logging"
	"go.uber.org/zap"

	"google.golang.org/grpc"
)

func main() {
	if err := logging.InitLogger(); err != nil {
		log.Fatalf("Failed to initialize logger: %s", err.Error())
	}

	if err := env.InitEnv(); err != nil {
		logging.Logger.Error("Failed to initialize environment variables.", zap.Error(err))
	}

	if err := db.Connect(); err != nil {
		logging.Logger.Error("Failed to initialize Postgres connection.", zap.Error(err))
	}

	sms.InitTwilio()

	port := env.GetPORT()
	addr := ":" + port

	listener, err := net.Listen("tcp", addr)
	if err != nil {
		logging.Logger.Error("TCP Listener failed to listen on provided address.", zap.String("addr", addr), zap.Error(err))
	}

	grpcServer := grpc.NewServer(
		grpc.UnaryInterceptor(logging.GrpcLoggingInterceptor),
	)
	attachmentService := attachment_rpcs.NewAttachmentService()
	attachmentpb.RegisterAttachmentServiceServer(grpcServer, attachmentService)

	logging.Logger.Info("AttachmentService listening on "+addr, zap.String("port", port))
	if err := grpcServer.Serve(listener); err != nil {
		logging.Logger.Error("AttachmentService launch failed.", zap.Error(err))
	}
}
