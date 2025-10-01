# ClassInTown Server Setup Guide

## 📋 Prerequisites

- **Linux user:** `ubuntu`
- **Node.js:** Using nvm (safe even if not installed; script checks)
- **PM2:** Includes pm2-runtime

### Directory Structure

```
/var/www/html/classintown/
├── dev/backend/          # Development environment
└── prod/backend/         # Production environment
```

### PM2 Ecosystem Files

- `pm2/ecosystem.development.json`
- `pm2/ecosystem.production.json`

> **Note:** Nginx already proxies to your Node ports.

---

## 🚀 Part 0: One-time Setup

### 1. Connect to Server

```bash
ssh -i /path/to/key.pem ubuntu@13.201.27.137
```

### 2. Verify PM2 Installation

```bash
node -v
npm -v
pm2 -v || npm i -g pm2
```

---

## 🔧 Part 1: Development Environment Setup

### 1. Create Systemd Service

```bash
sudo nano /etc/systemd/system/classintown-dev.service
```

**Paste the following configuration:**

```ini
[Unit]
Description=ClassInTown DEV via PM2 Runtime
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/var/www/html/classintown/dev/backend

# Load nvm environment (safe if nvm absent)
Environment=NVM_DIR=/home/ubuntu/.nvm
ExecStartPre=/bin/bash -lc 'if [ -s "$NVM_DIR/nvm.sh" ]; then . "$NVM_DIR/nvm.sh"; fi; node -v && npm -v'

# Start PM2 in foreground so systemd can supervise it
ExecStart=/bin/bash -lc 'if [ -s "$NVM_DIR/nvm.sh" ]; then . "$NVM_DIR/nvm.sh"; fi; pm2-runtime start pm2/ecosystem.development.json'

# Optional lifecycle hooks
ExecReload=/bin/bash -lc 'pm2 reload all'
ExecStop=/bin/bash -lc 'pm2 kill'

Restart=always
RestartSec=5
Environment=NODE_ENV=development

[Install]
WantedBy=multi-user.target
```

### 2. Enable and Start Service

```bash
sudo systemctl daemon-reload
sudo systemctl enable classintown-dev
sudo systemctl start classintown-dev
sudo systemctl status classintown-dev
```

### 3. Verify Application

```bash
# Check PM2 processes
pm2 list

# Check listening ports
sudo ss -lntp | grep node || true

# Health check (replace 3000 if needed)
curl -i http://127.0.0.1:3000/api/v1/health || true
```

### 4. Monitor Logs

```bash
journalctl -u classintown-dev -f
```

---

## 🏭 Part 2: Production Environment Setup

### 1. Create Systemd Service

```bash
sudo nano /etc/systemd/system/classintown-prod.service
```

**Paste the following configuration:**

```ini
[Unit]
Description=ClassInTown PROD via PM2 Runtime
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/var/www/html/classintown/prod/backend

Environment=NVM_DIR=/home/ubuntu/.nvm
ExecStartPre=/bin/bash -lc 'if [ -s "$NVM_DIR/nvm.sh" ]; then . "$NVM_DIR/nvm.sh"; fi; node -v && npm -v'
ExecStart=/bin/bash -lc 'if [ -s "$NVM_DIR/nvm.sh" ]; then . "$NVM_DIR/nvm.sh"; fi; pm2-runtime start pm2/ecosystem.production.json'
ExecReload=/bin/bash -lc 'pm2 reload all'
ExecStop=/bin/bash -lc 'pm2 kill'

Restart=always
RestartSec=5
Environment=NODE_ENV=production

[Install]
WantedBy=multi-user.target
```

### 2. Enable and Start Service

```bash
sudo systemctl daemon-reload
sudo systemctl enable classintown-prod
sudo systemctl start classintown-prod
sudo systemctl status classintown-prod
```

### 3. Verify Application

```bash
# Check PM2 processes
pm2 list

# Check listening ports
sudo ss -lntp | grep node || true

# Health check (replace 4000 if prod uses different port)
curl -i http://127.0.0.1:4000/api/v1/health || true
```

### 4. Monitor Logs

```bash
journalctl -u classintown-prod -f
```

---

## 🌐 Part 3: Nginx Configuration Check

### Verify Server Blocks

```bash
# Check development server block
sudo nginx -T | sed -n '/server_name dev.classintown.com/,/}/p'

# Check production server block
sudo nginx -T | sed -n '/server_name classintown.com/,/}/p'
```

### Apply Changes (if needed)

```bash
sudo nginx -t && sudo systemctl reload nginx
```

---

## 🔄 Part 4: Reboot Testing

### Manual Reboot Test

```bash
# Reboot the server
sudo reboot

# Re-login after reboot
ssh -i /path/to/key.pem ubuntu@13.201.27.137

# Verify services are running
pm2 list
sudo systemctl status classintown-dev
sudo systemctl status classintown-prod
```

**Expected Result:** Both services should show `Active: running` and PM2 apps should be listed automatically.

---

## ⚙️ Part 5: Daily Operations

### Restart Services (after code updates)

```bash
# Development
sudo systemctl restart classintown-dev

# Production
sudo systemctl restart classintown-prod
```

### Graceful Reload

```bash
sudo systemctl reload classintown-dev
sudo systemctl reload classintown-prod
```

### Monitor Logs

```bash
# Development logs
journalctl -u classintown-dev -f

# Production logs
journalctl -u classintown-prod -f
```

### Disable Services (if needed)

```bash
sudo systemctl disable --now classintown-dev
sudo systemctl disable --now classintown-prod
```

---

## ☁️ Part 6: CloudWatch Alarm Configuration

### Console Setup

1. Go to **CloudWatch** → **Alarms**
2. Open your `StatusCheckFailed` alarm
3. **Actions** → **Create action** (or **Edit**)
4. **When:** In alarm → **EC2 action:** Reboot instance → pick instance
5. **Save**

### How It Works

- **Alarm fires** → **EC2 reboots** → **systemd starts pm2-runtime** → **apps come up**

---

## 🔍 Troubleshooting

### Key Difference: pm2 vs pm2-runtime

- **`pm2 start`** → daemonizes and exits → systemd thinks service finished ❌
- **`pm2-runtime start`** → stays in foreground → systemd supervises properly ✅

### Debug Commands

If anything isn't working, run these commands and share the output:

```bash
# Development service status
sudo systemctl status classintown-dev --no-pager
journalctl -u classintown-dev -n 200 --no-pager

# Production service status
sudo systemctl status classintown-prod --no-pager
journalctl -u classintown-prod -n 200 --no-pager

# PM2 processes
pm2 list

# Listening ports
sudo ss -lntp | grep node || true
```

---

## ✅ Summary

This setup ensures that:
- Both development and production environments start automatically on boot
- Services are properly supervised by systemd
- PM2 processes are managed correctly
- CloudWatch alarms can trigger reboots that restore services
- Easy daily operations for updates and monitoring
