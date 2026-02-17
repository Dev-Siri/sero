FROM golang:1.25.2-alpine AS builder

WORKDIR /app

COPY go.mod go.sum ./

RUN go mod download

COPY . .

ENV CGO_ENABLED=0
RUN go build -v -trimpath -ldflags=-s -ldflags=-w -buildvcs=false -o /app/bin/chat ./services/chat

FROM alpine:latest

WORKDIR /app

COPY --from=builder /app/bin/chat .

EXPOSE 8000

ENTRYPOINT [ "./chat" ]
