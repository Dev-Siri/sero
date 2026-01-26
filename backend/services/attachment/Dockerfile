FROM golang:1.25.2-alpine AS builder

WORKDIR /app
RUN apk update && apk add --no-cache \
    vips \
    vips-dev \
    libheif-dev \
    libexif-dev \
    gcc \
    musl-dev

COPY go.mod go.sum ./
RUN go mod download

COPY . .

ENV CGO_ENABLED=1
RUN go build -v -trimpath -ldflags=-s -ldflags=-w -buildvcs=false -o /app/bin/attachment ./services/attachment

FROM alpine:latest

WORKDIR /app

RUN apk update && apk add --no-cache \
    vips \
    libheif \
    ca-certificates

COPY --from=builder /app/bin/attachment .

EXPOSE 8000

ENTRYPOINT [ "./attachment" ]
