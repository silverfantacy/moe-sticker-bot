# Zeabur deployment

This project should be deployed with the included Dockerfile, not Zeabur's plain Go provider. The bot needs runtime tools such as ffmpeg, ImageMagick, bsdtar, gifsicle, nginx, and Python helper scripts.

## Target project

- Project ID: `69ecd7792c891a4cefac0f28`
- Environment ID: `69ecd779d34cd657ee34667d`
- Service ID: `69ecdb6d2c891a4cefac1001`
- Project name: `moe-sticker-bot`
- Public URL: `https://moe-sticker-bot-zero.zeabur.app`

## Required variables

Set these on the Zeabur service:

```env
BOT_TOKEN=123456:telegram-bot-token
LOG_LEVEL=info
DATA_DIR=/data
```

## Database variables

MariaDB is optional, but recommended for search, user sticker ownership records, and management flows:

```env
DB_ADDR=mysql-host:3306
DB_USER=root
DB_PASS=password
```

If MariaDB is deployed in the same Zeabur project, use Zeabur's internal connection hostname/port values from that service.

## WebApp variables

After the service has a public Zeabur domain, set:

```env
WEBAPP_URL=https://your-service.zeabur.app/webapp
WEBAPP_DATA_DIR=/webapp/data
WEBAPP_LISTEN_ADDR=127.0.0.1:3921
WEBAPP_PROXY_BASE=127.0.0.1:3921/webapp
```

The container listens on `PORT`, which Zeabur provides automatically. Nginx serves the React WebApp at `/webapp/edit` and `/webapp/export`, proxies `/webapp/api` to the Go API server, and exposes `/webapp/data`.

## Persistent storage

For production, mount persistent storage to:

```text
/data
/webapp/data
```

`/data` holds short-lived bot working data while a user is importing, downloading, or creating a sticker set. It can contain downloaded LINE/Kakao ZIP files, extracted PNG/APNG files, converted WebP/WebM files, and temporary export ZIP files. Successful automatic imports remove their session folder immediately; a daily cleanup job removes any stale folders older than one day.

`/webapp/data` holds temporary sticker files served to Telegram WebApp users when editing or exporting a Telegram sticker set. A daily cleanup job removes stale WebApp folders older than two days.

Runtime tools such as ffmpeg, ImageMagick, nginx, Python, and helper scripts are installed into the Docker image. They do not need persistent storage and should not be mounted as volumes.

MariaDB stores only metadata needed for search and management:

- `line`: LINE/Kakao sticker ID/link to Telegram sticker-set ID/title mapping, plus the auto-emoji flag.
- `stickers`: Telegram user ID to created/imported Telegram sticker-set ID/title mapping, plus timestamp.
- `properties`: internal database version and maintenance state.

The database does not store sticker image/video files.

## Deploy commands

Direct deploy from this working tree:

```bash
npx zeabur@latest deploy \
  --project-id 69ecd7792c891a4cefac0f28 \
  --environment-id 69ecd779d34cd657ee34667d \
  --service-id 69ecdb6d2c891a4cefac1001 \
  --name moe-sticker-bot \
  --json
```

Always include `--service-id` when redeploying this existing service. Omitting it can create a duplicate service.

This project is currently deployed directly from the local working tree. GitHub Actions are not required.

Git deploy from the `main` branch can also be used after this commit is pushed to GitHub:

```bash
npx zeabur@latest service deploy --json -i=false \
  --project-id 69ecd7792c891a4cefac0f28 \
  --template GIT \
  --repo-id <github-repo-id> \
  --branch-name main \
  --name moe-sticker-bot
```
