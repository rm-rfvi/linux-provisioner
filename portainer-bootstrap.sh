#!/bin/bash


echo "Disabling IPv6"
echo "net.ipv6.conf.all.disable_ipv6 = 1" | sudo tee /etc/sysctl.d/99-disable-ipv6.conf
echo "net.ipv6.conf.default.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.d/99-disable-ipv6.conf
echo "net.ipv6.conf.lo.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.d/99-disable-ipv6.conf
sudo sysctl -p
echo "IPv6 disabled successfully"


sudo apt update
sudo apt install \
  ca-certificates \
  curl \
  gnupg \


TIMEZONE="Australia/Adelaide"

sudo mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin nfs-common -y


# Create necessary directories
mkdir -p /opt/docker/build
mkdir -p /opt/docker/run
mkdir -p /opt/docker/tmp


mkdir -p /opt/docker/run/portainer


# Set correct permissions for the directories and configuration file

chmod 755 /opt/docker/run
chmod 755 /opt/docker/tmp
chmod 755 /opt/docker/build

mkdir -p /opt/docker/run/portainer
mkdir -p /opt/docker/run/nginx



# Set the timezone as a variable (change this as needed)
TIMEZONE="Australia/Adelaide"

# Create nginx portainer config file
sudo tee /opt/docker/run/nginx/portainer.conf > /dev/null <<EOF


server {
  listen        80;
  server_name   portainer.axfr.cc;

  location / {
    proxy_pass  http://portainer:9000;
  }
}

EOF


# Create the docker-compose.yml file
cat > /opt/docker/build/docker-compose.yml <<EOF
version: "3"
networks:
  net_portainer:
volumes:
  vol_portainer:
    driver: local
    driver_opts:
      type: none
      device: /opt/docker/run/portainer
      o: bind
  vol_nginx:
    driver: local
    driver_opts:
      type: none
      device: /opt/docker/run/nginx
      o: bind
services:
 nginx-base:
    image: nginx:latest
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=$TIMEZONE
      - UMASK_SET=022
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - /etc/timezone:/etc/timezone:ro
      - vol_nginx:/etc/nginx/conf.d/:ro
    ports:
      - 80:80
      - 443:443
    networks:
      net_portainer:
    labels:
      - com.centurylinklabs.watchtower.enable=true
 portainer:
    image: portainer/portainer-ce:latest
    container_name: portainer
    restart: always
    security_opt:
      - no-new-privileges:true
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - vol_portainer:/data
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=$TIMEZONE
      - UMASK_SET=022 #optional
    networks:
      net_portainer:
    labels:
      - "com.centurylinklabs.watchtower.enable=true"
 watchtower:
    image: containrrr/watchtower
    restart: always
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - /etc/timezone:/etc/timezone:ro
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=$TIMEZONE
      - UMASK_SET=022 #optional
      - WATCHTOWER_CLEANUP=true
      - WATCHTOWER_LABEL_ENABLE=true
      - WATCHTOWER_INCLUDE_RESTARTING=true
    labels:
      - "com.centurylinklabs.watchtower.enable=true"

EOF

# Run docker-compose up against the docker-compose.yml file
cd /opt/docker/build
docker compose up -d
