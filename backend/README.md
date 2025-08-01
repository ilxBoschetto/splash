# Comandi utili

Far partire il container docker

```bash
docker run -d \
  --name mongodb \
  -p 27017:27017 \
  --mount source=mongo_data,target=/data/db \
  --restart unless-stopped \
  arm64v8/mongo:4.4.18
```

Riavviare / vedere lo stato del servizio splash-backend

```bash
sudo systemctl status splash-backend.service
```

Guardare i log in tempo reale del servizio

```bash
journalctl -fu splash-backend.service
```