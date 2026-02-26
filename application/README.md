# Flutter Frontend - Splash Project

Questo progetto rappresenta la parte **frontend** sviluppata in **Flutter**, connessa a un backend Next.js + MongoDB.

## 📦 Requisiti

- Flutter SDK installato
- Dart SDK (incluso in Flutter)
- Un emulatore Android/iOS o un dispositivo fisico collegato
- Backend attivo (es. su `http://localhost:3000`)

## ▶️ Avvio rapido

### 1. Naviga nella cartella del progetto Flutter

```bash
cd frontend
```

### 2. Recupera le dipendenze

```bash
flutter pub get
```

### 3. Avvia l'app (in debug)

```bash
flutter run
```
## Configurazione ambiente

Questo progetto usa due file distinti:
- application/.env.development
- application/.env.production

Sviluppo locale (default):
- Esegui `flutter run` senza parametri. Il codice usa ENV=development come default.

Produzione:
- Usa `flutter run --dart-define=ENV=production` oppure `flutter build <target> --dart-define=ENV=production`.

