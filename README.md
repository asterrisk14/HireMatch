# HireMatch

Platforma agencije za posredovanje u zaposljavanju.

- **Backend (REST API):** ASP.NET Core (.NET 10) + SQL Server + RabbitMQ
- **Admin (web):** Angular
- **Mobilna aplikacija:** Flutter (kandidati)
- **Worker servis:** zaseban mikroservis za slanje emailova (RabbitMQ consumer)

## Tehnologije
ASP.NET Core Web API, Entity Framework Core, SQL Server, RabbitMQ, MailKit, Stripe (sandbox), Angular, Flutter, Docker.

## Preduslovi
- .NET 10 SDK
- Docker Desktop
- Node.js + Angular CLI
- Flutter SDK

## Konfiguracija (.env)
Raspakuj .env-tajne.zip (sifra: fit) u HireMatch/ folder (pored solution fajla).
Sadrzi: connection string, JWT key, Stripe key, RabbitMQ podatke.

## Pokretanje

### 1. Infrastruktura (SQL Server + RabbitMQ)
Iz HireMatch/ foldera:
    docker compose up -d sqlserver rabbitmq

### 2. Backend (API)
    cd HireMatch
    dotnet ef database update --project HireMatch.Services --startup-project HireMatch.WebAPI
    dotnet run --project HireMatch.WebAPI --urls=http://0.0.0.0:5086

API: http://localhost:5086 | Dokumentacija: http://localhost:5086/scalar

### 3. Worker (email mikroservis)
    cd HireMatch
    dotnet run --project HireMatch.Worker

### 4. Admin (Angular)
    cd HireMatch-frontend/hirematch-app
    npm install
    ng serve

Admin: http://localhost:4200

### 5. Mobilna aplikacija (Flutter, Android emulator)
    cd hirematch_mobile
    flutter pub get
    flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5086

## Pristupni podaci

| Kontekst | Korisnicko ime | Lozinka |
|----------|----------------|---------|
| Admin (web) | admin@hirematch.com | Admin123! |
| Mobilna (kandidat) | mobile@hirematch.com | Test123! |

## Funkcionalnosti
- JWT autentifikacija i autorizacija (role-based)
- CRUD za glavne i referentne entitete + pretraga/filteri + paginacija
- Sistem preporuke poslova (content-based, explainable)
- In-app placanje (Stripe sandbox) + refund, premium profil
- Sistemske notifikacije (in-app, polling auto-refresh) + email obavijesti
- Mikroservisna arhitektura (API + Worker preko RabbitMQ)
- PDF izvjestaji (admin)
