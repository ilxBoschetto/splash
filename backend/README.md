# Comandi utili

Creare un deploy.sh

```
#!/bin/bash
set -e

cd /home/ubuntu/splash
git pull

cd /home/ubuntu/splash/backend
docker compose -f docker-compose.prod.yml up -d --build

echo "Deploy completed"
```

Per accedere ai log
```
docker logs splash-backend
```