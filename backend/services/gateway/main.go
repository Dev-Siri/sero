package main

import (
	"context"
	"log"
	"net/http"

	"github.com/99designs/gqlgen/graphql"
	"github.com/99designs/gqlgen/graphql/handler"
	"github.com/Dev-Siri/sero/backend/services/gateway/clients"
	"github.com/Dev-Siri/sero/backend/services/gateway/constants"
	"github.com/Dev-Siri/sero/backend/services/gateway/env"
	"github.com/Dev-Siri/sero/backend/services/gateway/graph"
	"github.com/Dev-Siri/sero/backend/services/gateway/middleware"
	shared_env "github.com/Dev-Siri/sero/backend/shared/env"
	"github.com/valyala/fasthttp/fasthttpadaptor"

	"github.com/Dev-Siri/sero/backend/shared/logging"
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

	attachmentService, err := clients.CreateAttachmentClient()
	if err != nil {
		logging.Logger.Error("Failed to connect to Attachment Service over gRPC.", zap.Error(err))
	}

	graphConfig := graph.Config{Resolvers: &graph.Resolver{
		AuthService:       authService,
		AttachmentService: attachmentService,
	}}

	server := handler.NewDefaultServer(graph.NewExecutableSchema(graphConfig))

	server.AroundOperations(func(ctx context.Context, next graphql.OperationHandler) graphql.ResponseHandler {
		user := ctx.Value(constants.UserLocalKey)

		ctx = context.WithValue(ctx, constants.UserLocalKey, user)
		return next(ctx)
	})

	port := shared_env.GetPORT()
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
	app.Use(middleware.AuthMiddleware)

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
