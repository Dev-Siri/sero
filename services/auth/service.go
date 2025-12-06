package main

import (
	"log"
	"net"

	authpb "github.com/Dev-Siri/sero/proto/authpb"
	"github.com/Dev-Siri/sero/shared/env"
	"github.com/Dev-Siri/sero/shared/logging"
	"go.uber.org/zap"

	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection"
)

type AuthService struct {
	authpb.UnimplementedAuthServiceServer
}

func main() {
	if err := logging.InitLogger(); err != nil {
		log.Fatalf("Failed to initialize logger: %s", err.Error())
	}

	port := env.GetPort()
	addr := ":" + port

	listener, err := net.Listen("tcp", addr)
	if err != nil {
		logging.Logger.Info("TCP Listener failed to listen on provided address.", zap.String("addr", addr), zap.Error(err))
	}

	grpcServer := grpc.NewServer()
	authpb.RegisterAuthServiceServer(grpcServer, &AuthService{})
	reflection.Register(grpcServer)

	logging.Logger.Info("AuthService listening on "+addr, zap.String("port", port))
	if err := grpcServer.Serve(listener); err != nil {
		logging.Logger.Info("AuthService launch failed.", zap.Error(err))
	}
}
