# Guida per firmare e buildare il ".aab"

---

## 1. Genera la keystore

- Apri il terminale e vai su `application\android\app`
- Installa java (https://adoptium.net/en-GB/temurin/releases)
- Lancia questo comando (salvare le credenziali su password manager)

```bash
keytool -genkeypair \
  -v \
  -keystore release-keystore.jks \
  -alias upload \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias release \
  -storepass password_keystore \
  -keypass password_chiave \
  -dname "CN=Matteo Boschetti, OU=Sviluppo, O=La Mia Azienda, L=Milano, ST=MI, C=IT"
```

## 2. Crea `key.properties`

- Crea un file chiamato `key.properties` all'interno di `application\android`
- Inserisci questo contenuto, usando la password che hai usato per generare la keystore

```bash
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEYSTORE_PASSWORD
keyAlias=release
storeFile=release-keystore.jks
```

## 3. Builda e firma il file

- Lancia questo comando

```bash
flutter build appbundle --release
```

## Notes

Non togliere `release-keystore.jks` e `key.properties` dal gitignore
