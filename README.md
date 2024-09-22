# fileshare-website

a simple web interface to share notes and files between devices with a few clicks


# hosting

- configure environment variables
  - inject into the docker container
  - .env file
  - Kubernetes pod
  - etc.
```
REDIS_URL
POSTGRES_HOST
POSTGRES_PORT
POSTGRES_USER
POSTGRES_PASSWORD
COOKIE_DOMAIN
CLOUDFLARE_ACCOUNT_ID
S3_ACCESS_KEY_ID
S3_SECRET_ACCESS_KEY
S3_BUCKET_NAME
```
- run the docker container
  - default port is 4567
