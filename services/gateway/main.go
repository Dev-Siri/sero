package main

import (
	"log"
	"net/http"

	"github.com/99designs/gqlgen/graphql/handler"
	"github.com/Dev-Siri/sero/services/gateway/clients"
	"github.com/Dev-Siri/sero/services/gateway/graph"
	"github.com/Dev-Siri/sero/shared/env"
	"github.com/Dev-Siri/sero/shared/logging"
	"go.uber.org/zap"
)

func main() {
	if err := logging.InitLogger(); err != nil {
		log.Fatalf("Failed to initialize logger: %v", err)
	}

	if err := env.InitEnv(); err != nil {
		logging.Logger.Error("Failed to initialize environment variables.", zap.Error(err))
	}

	authService, err := clients.CreateAuthClient()

	if err != nil {
		logging.Logger.Error("Failed to connect to Auth Service over gRPC.", zap.Error(err))
	}

	graphConfig := graph.Config{Resolvers: &graph.Resolver{
		AuthService: authService,
	}}

	server := handler.NewDefaultServer(graph.NewExecutableSchema(graphConfig))
	port := env.GetPort()
	addr := ":" + port

	http.Handle("/graphql", server)

	logging.Logger.Info("Server is listening on "+addr, zap.String("port", port), zap.Error(err))
	if err := http.ListenAndServe(addr, nil); err != nil {
		logging.Logger.Error("Failed to start API gateway.", zap.Error(err))
	}
}
