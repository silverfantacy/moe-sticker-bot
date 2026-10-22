# Moe Sticker Bot operations

## Hecate / Openship production

Production is deployed from silverfantacy/moe-sticker-bot, branch main, via .openship/compose.yaml. Pushes to main trigger Openship builds and deployment. Keep Dockerfile and Compose changes committed; do not replace production with an untracked local image.

- Openship project: proj_jMHlx4M_TrnVx5PZ
- Bot service: svc_LBNnOGNWDOiUtY9G
- MariaDB service: svc_Qbjp6K9nzwT0zfyD
- Public URL: https://moe-sticker-bot-zero.laplusda.com

Preserve the existing MariaDB volume, service environment variables, and both bot data bind mounts. Secrets stay in Openship and must not be committed. The Dockerfile builds the Go bot and WebApp and provides its required runtime tools. Do not deploy with a plain Go buildpack.

GitHub Actions are not used for deployment; Openship receives the GitHub push webhook.

## Historical Zeabur deployment

The following notes describe the previous Zeabur deployment, not the current production target.

## Zeabur deployment

- Project ID: `69ecd7792c891a4cefac0f28`
- Environment ID: `69ecd779d34cd657ee34667d`
- Service ID: `69ecdb6d2c891a4cefac1001`
- Service name: `moe-sticker-bot`
- Public URL: `https://moe-sticker-bot-zero.zeabur.app`

Deploy the existing service from this working tree:

```bash
npx zeabur@latest deploy \
  --project-id 69ecd7792c891a4cefac0f28 \
  --environment-id 69ecd779d34cd657ee34667d \
  --service-id 69ecdb6d2c891a4cefac1001 \
  --name moe-sticker-bot \
  --json
```

Always include `--service-id` when redeploying. Omitting it can create a duplicate service.

This project uses the included Dockerfile on Zeabur. Do not use Zeabur's plain Go provider because the bot needs ffmpeg, ImageMagick, bsdtar, gifsicle, nginx, Python, and helper scripts in the runtime image.

GitHub Actions are not used for deployment.

## Runtime configuration

Required service variables:

```env
BOT_TOKEN=<Telegram bot token>
LOG_LEVEL=info
DATA_DIR=/data
```

MariaDB variables:

```env
DB_ADDR=mariadb.zeabur.internal:3306
DB_USER=root
DB_PASS=<MariaDB root password>
```

WebApp variables:

```env
WEBAPP_URL=https://moe-sticker-bot-zero.zeabur.app/webapp
WEBAPP_DATA_DIR=/webapp/data
WEBAPP_LISTEN_ADDR=127.0.0.1:3921
WEBAPP_PROXY_BASE=127.0.0.1:3921/webapp
```

## Storage

- `/data`: short-lived bot working files during import, download, and sticker creation.
- `/webapp/data`: short-lived files served to the Telegram WebApp for editing/export.
- MariaDB: metadata only; it does not store sticker image/video files.

See `docs/ZEABUR.md` for the full deployment and storage notes.
