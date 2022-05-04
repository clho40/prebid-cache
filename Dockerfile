# syntax=docker/dockerfile:1
FROM golang:1.18.1-alpine3.15
RUN apk add git
WORKDIR /app
COPY go.mod ./
COPY go.sum ./
RUN go mod download
COPY . ./
RUN go build .
EXPOSE 8000
CMD ["./prebid-cache"]