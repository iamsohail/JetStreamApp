# JetStream

iOS flight tracking app with real-time status, PNR lookup, and personal aviation analytics.

## Architecture

- **iOS**: SwiftUI + SwiftData + Firebase Auth (Email, Google, Apple)
- **Backend**: Node.js microservices + PostgreSQL + Redis + Nginx gateway
- **External APIs**: Amadeus (PNR/flight data), AviationStack (real-time status)

## Project Structure

```
JetStreamApp/
├── ios/                          # iOS app (SwiftUI, iOS 17+)
│   ├── project.yml               # XcodeGen config
│   ├── JetStream/                # Main app target
│   │   ├── App/                  # Entry point, ContentView, config
│   │   ├── Models/               # SwiftData models (Flight)
│   │   ├── Views/                # Auth, Dashboard, Flights, Analytics, Profile
│   │   ├── Services/             # Auth, Flight API services
│   │   ├── Core/Network/         # APIClient, Endpoints, Keychain
│   │   ├── Utilities/            # Theme, Constants, Extensions
│   │   └── Resources/            # Assets, LaunchScreen
│   ├── JetStreamTests/
│   └── JetStreamUITests/
├── backend/
│   ├── docker-compose.yml        # Postgres, Redis, Nginx, services
│   ├── gateway/nginx.conf        # API gateway routing
│   ├── shared/database/          # Connection pool, migrations
│   └── services/
│       ├── user-service/         # Auth, profiles (port 3001)
│       └── flight-service/       # Flights, PNR, analytics (port 3002)
└── .env.example
```

## Setup

### iOS
```bash
cd ios
xcodegen generate
open JetStream.xcodeproj
# Add GoogleService-Info.plist from Firebase Console
```

### Backend
```bash
cd backend
cp .env.example .env
# Fill in API keys (Amadeus, AviationStack)
docker-compose up -d
```

## API Endpoints

| Service | Port | Routes |
|---------|------|--------|
| Gateway | 3000 | Nginx reverse proxy |
| User | 3001 | `/api/v1/auth/*`, `/api/v1/users/*` |
| Flight | 3002 | `/api/v1/flights/*`, `/api/v1/analytics/*` |

## Current Status

- [x] Project scaffold (iOS + Backend)
- [x] SwiftData models
- [x] Backend microservices structure
- [x] Database migrations
- [x] Docker Compose setup
- [ ] Firebase Auth integration
- [ ] Amadeus API integration
- [ ] AviationStack integration
- [ ] Full UI implementation
- [ ] Analytics charts

## Bundle ID
`com.iamsohail.JetStream`

## Min iOS Version
17.0
