# Junk & Gems 🌍♻️

<p align="center">
  <img src="designs_screenshots/junk_and_gems_logo.jpg" alt="Junk and Gems Logo" width="180" style="border-radius: 12px;"/>
</p>

<p align="center">
  <em>Transforming Waste into Economic Opportunity in Lesotho</em>
</p>

<p align="center">
  <a href="#about">About</a> •
  <a href="#features">Features</a> •
  <a href="#installation">Installation</a> •
  <a href="#demo">Demo</a> •
  <a href="#tech-stack">Tech Stack</a> •
  <a href="#contact">Contact</a>
</p>

---

## 📱 Quick Links

- **[Download APK](https://drive.google.com/file/d/1YLFANhQvok0WlsGNiQl5cJCVVlEml0qM/view?usp=sharing)** - Install on Android
- **[Watch Final Demo Video](https://drive.google.com/file/d/1w-E5iKfpDcFJwErR5WTJbrLfCDQaspxc/view?usp=sharing)** - 5-minute walkthrough
- **[Web App](https://junk-and-gems-web.vercel.app/)** - View in browser
- **[Admin Dashboard](https://junkandgems-admin-dashboard-evyz8kb09-philougiis-projects.vercel.app/)** - Manage platform
- **[Backend API](https://junk-and-gems-api.onrender.com)** - Live API endpoint
- **[Initial Prototype Demo Video](https://drive.google.com/file/d/1r-Ot0Vp1mtyxKzj-KHjuED-4P8NNOdtz/view?usp=sharing)** - Initial Project setup demo video

---

## About

Junk & Gems is a mobile marketplace connecting waste donors, artisans, and eco-entrepreneurs across Lesotho. The platform transforms waste materials into valuable, marketable products through upcycling, promoting sustainable entrepreneurship and environmental conservation.

### The Problem
Lesotho faces significant waste management challenges, with limited recycling infrastructure and growing pollution. Meanwhile, talented artisans lack access to affordable raw materials for their crafts.

### Solution
Junk & Gems bridges this gap by:
- Connecting waste donors with artisans who can transform materials
- Providing a marketplace for upcycled products
- Gamifying environmental responsibility through rewards and achievements
- Fostering a circular economy within local communities

---

## Features
- List unwanted materials for free collection
- Earn eco-points (gems) for contributions
- Access free/low-cost raw materials
- Sell upcycled products on the marketplace
- Connect directly with other users
- Purchase unique, eco-friendly products
- Support local artisans and sustainability

### Platform Features
- Secure authentication with JWT
- Real-time messaging between users
- Gamification system with earning gems
- Image upload via Cloudinary
- Cross-platform (Android & iOS)

---

## Installation

### Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK** (v3.0 or higher) - [Download here](https://flutter.dev/docs/get-started/install)
- **Node.js** (v18 or higher) - [Download here](https://nodejs.org/) *(Optional - only if running backend locally)*
- **PostgreSQL** (v14 or higher) - [Download here](https://www.postgresql.org/download/) *(Optional - only if running backend locally)*
- **Git** - [Download here](https://git-scm.com/)
- **Android Studio** (for Android development) or **Xcode** (for iOS development) or **VS Code**

---

### Step 1: Clone the Repository

```bash
git clone https://github.com/PhiLouGii/junk_and_gems_capstone.git
cd junk_and_gems_capstone
```

---

### Step 2: Mobile App Setup

**Two options to get started:**

#### Option A: Use the Hosted Backend (Quickest - Recommended for Testing)
The backend is already live at **https://junk-and-gems-api.onrender.com**. You can use it directly without any backend setup!

#### Option B: Set Up Your Own Backend (For Development)
If you want your own instance with your own database and users, skip to [Step 3: Local Backend Setup](#step-3-local-backend-setup-optional).

#### 2.1 Install Flutter Dependencies

```bash
flutter pub get
```

#### 2.2 Configure API Connection

The app is pre-configured to use the hosted backend at `https://junk-and-gems-api.onrender.com`.

**If you need to change the API URL**, open `lib/services/api_service.dart` and update:

```dart
const String BASE_URL = "https://junk-and-gems-api.onrender.com";
```

#### 2.3 Run the App

**On Android Emulator:**
```bash
flutter run
```

**On iOS Simulator:**
```bash
flutter run
```
#### 2.4 Build APK (Optional)

To create an installable APK file:

```bash
flutter build apk --release
```

The APK will be generated at: `build/app/outputs/flutter-apk/app-release.apk`

---

### Step 3: Local Backend Setup (Optional)

**Note:** This step is only necessary if you want to run the backend locally for development purposes. The app works out of the box with the hosted backend.

#### 3.1 Navigate to Backend Directory
```bash
cd backend
```

#### 3.2 Install Dependencies
```bash
npm install
```

#### 3.3 Configure Environment Variables

Create a `.env` file in the `backend` directory:

```env
PORT=3003
DATABASE_URL=postgresql://username:password@localhost:5432/junk_and_gems
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret
JWT_SECRET=your_secret_key_here
GOOGLE_CLIENT_ID=your_google_client_id
```

**Where to get credentials:**
- **Cloudinary**: Sign up at [cloudinary.com](https://cloudinary.com/) and get your credentials from the dashboard
- **JWT_SECRET**: Generate a secure random string (e.g., use [randomkeygen.com](https://randomkeygen.com/))
- **Google Client ID**: Get from [Google Cloud Console](https://console.cloud.google.com/) → APIs & Services → Credentials

#### 3.4 Set Up Database

1. Create a PostgreSQL database:
```bash
psql -U postgres
CREATE DATABASE junk_and_gems;
\q
```

2. The database tables will be created automatically when you start the server.

#### 3.5 Start the Backend Server
```bash
node server.js
```

You should see: `Server running on port 3003`

#### 3.6 Update Flutter App to Use Local Backend

In `lib/services/api_service.dart`, change:

```dart
// For Android Emulator
const String BASE_URL = "http://10.0.2.2:3003";

// For iOS Simulator
const String BASE_URL = "http://localhost:3003";

// For Physical Device (replace with your computer's IP)
const String BASE_URL = "http://192.168.1.x:3003";
```

---

### Step 4: Web App Setup (Optional)

The web app is already deployed at **https://junk-and-gems-web.vercel.app/**

To run it locally:

#### 4.1 Navigate to Web Directory
```bash
cd web
```

#### 4.2 Install Dependencies
```bash
npm install
```

#### 4.3 Start Development Server
```bash
npm run dev
```

The web app will run on `http://localhost:5173`

---

## Demo

**[Watch the 5-Minute Demo Video](https://drive.google.com/file/d/1w-E5iKfpDcFJwErR5WTJbrLfCDQaspxc/view?usp=sharing)**

The demo showcases:
- Browsing available waste materials
- Listing and creating materials
- Claiming materials
- Marketplace for upcycled products
- Listing and creating upcycled
- Real-time messaging and notifications
- Basic profile settings
- Gamification features

---

## Tech Stack

### Frontend
![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![React](https://img.shields.io/badge/React-20232A?style=for-the-badge&logo=react&logoColor=61DAFB)
![TypeScript](https://img.shields.io/badge/TypeScript-007ACC?style=for-the-badge&logo=typescript&logoColor=white)

### Backend
![Node.js](https://img.shields.io/badge/Node.js-339933?style=for-the-badge&logo=node.js&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-336791?style=for-the-badge&logo=postgresql&logoColor=white)
![Cloudinary](https://img.shields.io/badge/Cloudinary-3448C5?style=for-the-badge&logo=cloudinary&logoColor=white)

### Deployment
- **Mobile App**: [APK](https://drive.google.com/file/d/1YLFANhQvok0WlsGNiQl5cJCVVlEml0qM/view?usp=sharing)
- **Backend API**: [Render](https://junk-and-gems-api.onrender.com)
- **Web App**: [Vercel](https://junk-and-gems-web.vercel.app/)
- **Admin Dashboard**: [Vercel](https://junkandgems-admin-dashboard-evyz8kb09-philougiis-projects.vercel.app/)
- **Database**: Render PostgreSQL
- **Media Storage**: Cloudinary

---

## Screenshots

<p align="center">
<img src="designs_screenshots/dashboard_screen.jpeg" alt="Dashboard Screen" width="150">
<img src="designs_screenshots/browse2.jpeg" alt="Browse Screen" width="150">
<img src="designs_screenshots/daily_reward.jpeg" alt="Daily Reward Popup" width="150">
<img src="designs_screenshots/noitification2.jpeg" alt="Notification Screen" width="150">
<img src="designs_screenshots/marketplace.jpeg" alt="Marketplace Screen" width="150">
<img src="designs_screenshots/profile2.jpeg" alt="Profile Screen" width="150">
</p>

---

## Project Structure

```
junk_and_gems/
├── lib/                    # Flutter mobile app
│   ├── main.dart
│   ├── screens/           # UI screens
│   ├── services/          # API services
│   ├── providers/         # State management
│   └── utils/             # Helper functions
│
├── backend/               # Node.js API
│   ├── server.js
│   ├── routes/
│   ├── controllers/
│   └── config/
│
├── web/                   # React web app
│   ├── src/
│   ├── public/
│   └── package.json
│
├── admin_dashboard/       # React admin panel
│   ├── src/
│   └── package.json
│
└── designs_screenshots/   # UI designs & mockups
```

---

## Testing

Comprehensive testing documentation can be found in [TESTING_RESULTS.md](TESTING_RESULTS.md)

Tests include:
- Unit tests for API endpoints
- Widget tests for Flutter UI
- Integration tests for user flows
- Performance testing

---

## Troubleshooting

### Common Issues

**Flutter app can't connect to backend:**
- Ensure you have internet connection (backend is hosted online)
- Check if https://junk-and-gems-api.onrender.com is accessible in your browser
- If the server is sleeping (Render free tier), it may take 30-60 seconds to wake up

**Build errors:**
- Run `flutter clean` then `flutter pub get`
- Check Flutter SDK version: `flutter --version`
- Update dependencies: `flutter pub upgrade`

**APK installation issues:**
- Enable "Install from Unknown Sources" on your Android device
- Ensure you're installing the correct APK for your device architecture

---

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## License

This project is part of an academic capstone project at African Leadership University.

---

## Contact

**Philippa Louise Giibwa**  
BSc Software Engineering, ALU (2025)

- 📧 Email: p.giibwa@alustudent.com
- 💼 GitHub: [@PhiLouGii](https://github.com/PhiLouGii)

**Supervisor:** Pelin Mutanguha

---

## Acknowledgments

- African Leadership University for project support
- The communities of Lesotho for inspiration
- All contributors and testers

---

<p align="center">
  <strong>💚 Turning trash into treasure, together 💚</strong>
</p>
