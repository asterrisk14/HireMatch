# HireMatch

Platforma agencije za posredovanje u zaposljavanju.

- **Backend (REST API):** ASP.NET Core (.NET 10) + SQL Server + RabbitMQ
- **Admin (desktop):** Flutter Windows desktop
- **Mobilna aplikacija:** Flutter (kandidati)
- **Worker servis:** zaseban mikroservis za slanje emailova (RabbitMQ consumer)

## Tehnologije
ASP.NET Core Web API, Entity Framework Core, SQL Server, RabbitMQ, MailKit, Stripe (sandbox), Flutter, Docker.

## Preduslovi
- .NET 10 SDK
- Docker Desktop
- Flutter SDK (sa Windows desktop podrskom)
- Visual Studio 2022 Build Tools (Desktop development with C++ workload)

## Konfiguracija (.env)
Raspakuj .env-tajne.zip (sifra: fit) u HireMatch/ folder (pored solution fajla).
Sadrzi: connection string, JWT key, Stripe key, RabbitMQ podatke.

## Pokretanje

### 1. Infrastruktura + API + Worker (Docker)
Iz root foldera (gdje se nalazi docker-compose.yml):

    docker compose up --build -d

API: http://localhost:5086 | Dokumentacija: http://localhost:5086/scalar

### 2. Admin (Flutter Windows desktop)

    cd hirematch_admin
    flutter pub get
    flutter run -d windows --dart-define=API_BASE_URL=http://localhost:5086

### 3. Mobilna aplikacija (Flutter, Android emulator)

    cd hirematch_mobile
    flutter pub get
    flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5086

## Pristupni podaci

| Kontekst           | Korisnicko ime        | Lozinka   |
|--------------------|-----------------------|-----------|
| Desktop (admin)    | admin@hirematch.com   | Admin123! |
| Mobilna (kandidat) | mobile@hirematch.com  | Test123!  |

## Funkcionalnosti

### Desktop (admin)
- JWT autentifikacija sa auto-loginom
- Dashboard (statistike + oglasi koji isticu)
- Analytics + 2 PDF izvjestaja
- CRUD: Job Posts, Companies, Industries, Employment Types, Application Statuses, Skills, Countries, Cities, Career Tips
- Applications pregled + promjena statusa
- Talent Pool (pregled kandidata, master-detail profil, kontakt via email)

### Mobilna (kandidati)
- JWT autentifikacija
- Pregled i pretraga oglasa za posao
- Sistem preporuke poslova (content-based, explainable)
- Prijava na oglas (upload CV)
- In-app placanje (Stripe sandbox) + refund, premium profil
- Sistemske notifikacije (in-app, polling auto-refresh) + email obavijesti
- Pregled i izmjena profila

### Backend
- JWT autentifikacija i autorizacija (role-based)
- CRUD za glavne i referentne entitete + pretraga/filteri + paginacija
- Mikroservisna arhitektura (API + Worker via RabbitMQ)