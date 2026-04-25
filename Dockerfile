FROM node:24-bookworm-slim AS webapp
WORKDIR /src/web/webapp3
COPY web/webapp3/package*.json ./
RUN npm ci
COPY web/webapp3/ ./
RUN npm run build

FROM golang:1.25-bookworm AS build
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o /out/moe-sticker-bot ./cmd/moe-sticker-bot
RUN CGO_ENABLED=0 GOOS=linux go build -o /out/msbimport ./cmd/msbimport

FROM debian:bookworm-slim
LABEL "language"="go"
WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    exiv2 \
    ffmpeg \
    gifsicle \
    imagemagick \
    libarchive-tools \
    nginx \
    python3 \
    python3-pip \
    gettext-base \
    && rm -rf /var/lib/apt/lists/*
RUN pip3 install --break-system-packages emoji rlottie-python
COPY --from=build /out/moe-sticker-bot /usr/local/bin/moe-sticker-bot
COPY --from=build /out/msbimport /usr/local/bin/msbimport
COPY --from=webapp /src/web/webapp3/dist /webapp
COPY web/nginx/assetlinks.json /webapp/assetlinks.json
COPY tools/msb_emoji.py tools/msb_kakao_decrypt.py tools/msb_rlottie.py /usr/local/bin/
COPY docker/nginx.conf.template /etc/nginx/templates/default.conf.template
COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh /usr/local/bin/msb_emoji.py /usr/local/bin/msb_kakao_decrypt.py /usr/local/bin/msb_rlottie.py \
    && mkdir -p /data /webapp/data /run/nginx
EXPOSE 8080
CMD ["/entrypoint.sh"]
