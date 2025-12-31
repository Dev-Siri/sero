FROM golang:1.25.2-alpine AS builder

WORKDIR /app

COPY go.mod go.sum ./

RUN go mod download

COPY . .

RUN go build -v -trimpath -ldflags=-s -ldflags=-w -buildvcs=false -o /app/bin/auth-service ./services/auth

FROM alpine:latest

WORKDIR /app

COPY --from=builder /app/bin/auth-service .

EXPOSE 8000

CMD ["./auth-service"]
