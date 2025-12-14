package main

import (
	"log"
	"net/http"

	"github.com/99designs/gqlgen/graphql/handler"
	"github.com/Dev-Siri/sero/services/gateway/clients"
	"github.com/Dev-Siri/sero/services/gateway/constants"
	"github.com/Dev-Siri/sero/services/gateway/env"
	"github.com/Dev-Siri/sero/services/gateway/graph"
	"github.com/Dev-Siri/sero/services/gateway/middleware"
	shared_env "github.com/Dev-Siri/sero/shared/env"
	"github.com/valyala/fasthttp/fasthttpadaptor"

	"github.com/Dev-Siri/sero/shared/logging"
	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/cors"
	"go.uber.org/zap"
)

func main() {
	if err := logging.InitLogger(); err != nil {
		log.Fatalf("Failed to initialize logger: %v", err)
	}

	if err := shared_env.InitEnv(); err != nil {
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
	port := shared_env.GetPort()
	addr := ":" + port
	app := fiber.New(fiber.Config{
		ServerHeader:            constants.ServerName,
		AppName:                 constants.AppName,
		EnableTrustedProxyCheck: true,
		TrustedProxies:          []string{"0.0.0.0/0"},
		ProxyHeader:             "CF-Connecting-IP",
	})

	corsConfig := cors.New(cors.Config{
		AllowOrigins: env.GetCorsOrigin(),
		AllowMethods: constants.AllowedMethods,
	})
	app.Use(corsConfig)
	app.Use(middleware.LogMiddleware)
	app.All("/graphql", func(ctx *fiber.Ctx) error {
		fasthttpadaptor.NewFastHTTPHandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			server.ServeHTTP(w, r)
		})(ctx.Context())
		return nil
	})

	if err := app.Listen(addr); err != nil {
		logging.Logger.Error("Failed to start API gateway.", zap.Error(err))
	}
}
