#!/bin/bash

# ---------------------------
# UPDATE UBUNTU
# ---------------------------
apt-get update -y
apt-get upgrade -y

# ---------------------------
# INSTALL NODE 20
# ---------------------------
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt-get install -y nodejs build-essential

# ---------------------------
# INSTALL POSTGRES CLIENT
# ---------------------------
apt-get install -y postgresql-client

# ---------------------------
# INSTALL PM2
# ---------------------------
npm install -g pm2

# ---------------------------
# CREATE STRAPI DIRECTORY
# ---------------------------
mkdir -p /opt/strapi
cd /opt/strapi

# ---------------------------
# CREATE STRAPI PROJECT
# ---------------------------
npx create-strapi-app@latest my-project --skip-run

cd my-project

# ---------------------------
# INSTALL DEPENDENCIES
# ---------------------------
npm install

# ---------------------------
# CREATE ENV FILE
# ---------------------------
cat <<EOF > .env
HOST=0.0.0.0
PORT=1337

# --- SECURITY KEYS (GENERATE RANDOM) ---
APP_KEYS=$(openssl rand -base64 32)
API_TOKEN_SALT=$(openssl rand -base64 32)
ADMIN_JWT_SECRET=$(openssl rand -base64 32)
JWT_SECRET=$(openssl rand -base64 32)

# --- AWS POSTGRES DATABASE ---
DATABASE_CLIENT=postgres
DATABASE_HOST=${db_host}
DATABASE_PORT=5432
DATABASE_USERNAME=${db_user}
DATABASE_PASSWORD=${db_password}
DATABASE_NAME=${db_name}

AWS_REGION=us-east-1
EOF

# ---------------------------
# BUILD STRAPI ADMIN PANEL
# ---------------------------
npm run build

# ---------------------------
# START STRAPI USING PM2
# ---------------------------
pm2 start npm --name strapi -- run start
pm2 save
pm2 startup systemd
