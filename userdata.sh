#!/bin/bash

# ---------------------------
# UPDATE UBUNTU
# ---------------------------
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Make swap permanent
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

sudo apt-get update -y

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
sudo chown -R ubuntu:ubuntu /opt/strapi
mkdir -p /opt/strapi
cd /opt/strapi

# ---------------------------
# CREATE STRAPI PROJECT
# ---------------------------
npx create-strapi-app@latest my-project --no-run

cd my-project

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
sudo chown ubuntu:ubuntu /opt/strapi/.env

# Install Strapi
sudo -u ubuntu npm install
sudo -u ubuntu npm install pg
npm run build

# ---------------------------
# START STRAPI USING PM2
# ---------------------------
sudo pm2 start npm --name "strapi" -- start
sudo pm2 save
sudo pm2 startup systemd -u ubuntu --hp /home/ubuntu
