# HireMatch

Aplikacija za TA agenciju kako bi olakšali proces zapošljavanja i pružili priliku kandidatima za prijavu. Sastoji se od REST API-ja, Flutter Windows desktop admin panela i Flutter Android mobilne aplikacije za kandidate.

## Pokretanje

### Preduslovi
- .NET 10 SDK
- Flutter SDK
- SQL Server
- Docker (za RabbitMQ)

### 1. Baza podataka i API

```bash
cd HireMatch.API
cp .env-tajne.zip .env  # raspakuj sa šifrom
dotnet ef database update
dotnet run
```

API se pokreće na `http://localhost:5086`.

### 2. RabbitMQ (worker servis)

```bash
docker-compose up -d
```

### 3. Desktop admin (Windows)

```bash
cd hirematch_admin
flutter pub get
flutter run -d windows --dart-define=API_BASE_URL=http://localhost:5086
```

### 4. Mobilna aplikacija (Android emulator)

```bash
cd hirematch_mobile
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5086
```

Za build APK-a:
```bash
flutter build apk --release
```

## Kredencijali

| Kontekst | Email / korisničko ime | Lozinka |
|---|---|---|
| Desktop admin | admin@hirematch.com | Admin123! |
| Mobilna app | test@test.com | Test123! |

## Tehnologije

- **Backend:** ASP.NET Core (.NET 10), Entity Framework, JWT, RabbitMQ, Stripe
- **Desktop:** Flutter Windows
- **Mobilna:** Flutter Android
- **Baza:** SQL Server
