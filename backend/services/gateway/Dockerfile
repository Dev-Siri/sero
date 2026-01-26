FROM golang:1.25.2-alpine AS builder

WORKDIR /app

COPY go.mod go.sum ./

RUN go mod download

COPY . .

RUN go build -v -trimpath -ldflags=-s -ldflags=-w -buildvcs=false -o /app/bin/gateway ./services/gateway

FROM alpine:latest

WORKDIR /app

COPY --from=builder /app/bin/gateway .

EXPOSE 8000

ENTRYPOINT [ "./gateway" ]
