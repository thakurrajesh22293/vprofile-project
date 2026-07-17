# Update package list and install Nginx
apt update
apt install nginx -y

# Create Nginx configuration
cat <<EOT > vproapp
upstream vproapp {
    server 127.0.0.1:8080;
}

server {
    listen 80;

    location / {
        proxy_pass http://vproapp;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOT

# Move configuration
mv vproapp /etc/nginx/sites-available/vproapp

# Remove default site and enable new site
rm -f /etc/nginx/sites-enabled/default
ln -sf /etc/nginx/sites-available/vproapp /etc/nginx/sites-enabled/vproapp

# Test configuration
nginx -t

# Start and enable Nginx
systemctl enable nginx
systemctl restart nginx
