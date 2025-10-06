# Junk & Gems 
A Mobile Marketplace for Transforming Waste into Economic Opportunity in Lesotho

## Description
Junk & Gems is a cross-platform mobile application that connects waste donors, artisans, and eco-entrepreneurs in Lesotho. The platform promotes upcycling and sustainable entrepreneurship by turning waste into valuable, marketable products. 

The system includes: 
- **Flutter Mobile App** (for Android & iOS): Used by donors, artisans, and buyers.
- **Node.js Backend**: Provides REST APIs, handles authentication, media management, and gamification logic. 
- **PostgreSQL Database**: Stores user data, waste listings, transactions, and analytics. 
- **Cloudinary**: Manages image uploads and media storage efficiently. 
- **React Web App (Minimal version)**: To give the users a glimpse of what the app does. 

The goal is to empower communities, reduce waste pollution, and foster a circular economy within Lesotho. 

## GitHub Repository
https://github.com/PhiLouGii/junk_and_gems_capstone 

## Setup and Installation
### Prerequisites
- Flutter SDK (v3.0+)
- Node.js (v18+)
- PostgreSQL (v14+)
- Cloudinary account
- Git

### Backend Setup (Node.js + PostgreSQL)
1. Clone the repository
```bash
git clone https://github.com/PhiLouGii/junk_and_gems_capstone.git
cd junk_and_gems/backend
```

2. Intall dependencies:
```bash
npm install
```

3. Create a ```.env``` file:
```bash
PORT=3000
DATABASE_URL=postgresql://user:password@localhost:5433/junk_and_gems
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret
JWT_SECRET=your_jwt_secret
```

4. Start the server: 
```bash
node server.js
```
The backend should now run on ```http://localhost:3003```

### Mobile App Setup (Flutter)
1. Navigate to where the Flutter app is:
```bash
cd ..
```

2. Install dependencies:
```bash
flutter pub get
```

3. Create a ```.env``` or ```config.dart``` file and add your backend base URL and Cloudinary preset: 

```dart
const String BASE_URL = "http://10.0.2.2:5000"; // for Android emulator
const String CLOUDINARY_UPLOAD_PRESET = "your_preset";
```

4. Run the app on the Android Emulator: 
```bash
flutter run
```

## Design and Architecture
### System Architecture
- **Frontend**: Flutter (Mobile), React (Minimal web version and Admin)
- **Backend**: Node.js
- **Database**: PostgreSQL
- **Media Storage**: Cloudinary 
- **Authentication**: JWT & bcrypt

### UI/UX Designs
Figma was used to design the screens and the prototype as well as a style guide to envision what colours and theme will be utilised/ 

Figma design includes: 
- Onboarding screens
- Dashboard for Artisan, Donor and Buyer
- Waste browsing and listing screens
- Upcycled artwork and listing screens
- Chat, Notifications and Messages screens
- Cart and Checkout screens

## Deployment Plan
```markdown
| **Component**      | **Platform**       | **Hosting Service**       | **Status**     |
|--------------------|--------------------|---------------------------|----------------|
| Mobile App         | Android & iOS      | Google Play & App Store   | 🟡 In Progress |
| Backend API        | Node.js            | Render                    | 🟡 In Progress |
| Database           | PostgreSQL         | Render                    | ✅             |
| Image Storage      | Cloudinary         | Cloudinary                | ✅             | 
| Web Dashboard      | React + TypeScript | Vercel                    | 🟡 In Progress |
```
