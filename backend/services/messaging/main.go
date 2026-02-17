package main

import (
	"log"

	"github.com/Dev-Siri/sero/backend/services/gateway/middleware"
	"github.com/Dev-Siri/sero/backend/shared/db"
	"github.com/Dev-Siri/sero/backend/shared/env"
	"github.com/Dev-Siri/sero/backend/shared/logging"
	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/cors"
	"go.uber.org/zap"
)

const (
	serverName     = "go-fiber"
	appName        = "sero/messaging"
	allowedMethods = "GET,POST"
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

	port := env.GetPORT()
	addr := ":" + port

	app := fiber.New(fiber.Config{
		ServerHeader:            serverName,
		AppName:                 appName,
		EnableTrustedProxyCheck: true,
		TrustedProxies:          []string{"0.0.0.0/0"},
		ProxyHeader:             "CF-Connecting-IP",
	})

	corsConfig := cors.New(cors.Config{
		AllowOrigins: env.GetCorsOrigin(),
		AllowMethods: allowedMethods,
	})
	app.Use(corsConfig)
	app.Use(middleware.LogMiddleware)
	app.Use(middleware.AuthMiddleware)

	registerRoutes(app)

	if err := app.Listen(addr); err != nil {
		logging.Logger.Error("Failed to start Chat gateway.", zap.Error(err))
	}
}
