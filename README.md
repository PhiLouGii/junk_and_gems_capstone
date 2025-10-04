# Junk & Gems 

## Description
Junk & Gems is a mobile application that transforms waste into opportunity by connecting businesses with excess materials to artisans and creators who can repurpose them. This platform facilitates the circular economy by making material exchange simple, sustainable, and community-drive. 

## Key Features
- Material Listing: Households, businesses, individuals post unwanted materials with photos and descriptions.
- Artisan Discovery: Creators browse and search for free raw materials.
- In-App Messaging: Secure communication between providers and seekers.

## GitHub Repository
https://github.com/PhiLouGii/junk_and_gems_capstone 

## Environmental Setup & Installation
### Prerequisities
- Flutter SDK (3.13.0 or higher)
- Dart SDK (3.1.0 or higher)
- Node.js (18x or higher)
- PostgreSQL (14 or higher)
- VS Code/Android Studio/Xcode (for mobile development)

## Backend Setup
1. Clone the repository
```git clone https://github.com/your-username/junk-and-gems.git```
```cd junk-and-gems/backend ```

2. Install dependencies
```npm install```

3. Database setup
``` CREATE DATABASE junk_and_gems;```

4. Environmental configuration
``` cp .env.example .env```

5. Start the server
```node server.js```

## Frontend Setup

1. Navigate back to where the frontend code is
``` cd ..```

2. Get Flutter dependencies
```flutter pub get```

3. Configure API endpoints
```const String baseUrl = 'http://your-local-ip:3003';```

4. Run the application
``` flutter run```