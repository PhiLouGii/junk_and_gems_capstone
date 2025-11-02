# System Architecture

This document outlines the technical architecture, system design, and implementation details of the Junk & Gems platform.

---

## Table of Contents

- [Overview](#overview)
- [System Architecture](#system-architecture)
- [Technology Stack](#technology-stack)
- [Database Design](#database-design)
- [API Architecture](#api-architecture)
- [Authentication & Security](#authentication--security)
- [Use Case Diagrams](#use-case-diagrams)
- [Data Flow](#data-flow)

---

## Overview

Junk & Gems is built using a **client-server architecture** with the following components:

- **Mobile Client**: Flutter-based cross-platform application (Android & iOS)
- **Web Client**: React-based web application with TypeScript
- **Admin Dashboard**: React-based admin panel for platform management
- **Backend API**: Node.js REST API with Express framework
- **Database**: PostgreSQL relational database
- **Media Storage**: Cloudinary for image and file uploads
- **Hosting**: 
  - Backend: Render
  - Web & Admin: Vercel
  - Database: Render PostgreSQL

---

## System Architecture

### High-Level Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     Client Applications                      │
├──────────────────┬──────────────────┬──────────────────────┤
│  Flutter Mobile  │   React Web App  │  Admin Dashboard     │
│  (Android/iOS)   │   (TypeScript)   │  (React + TS)        │
└────────┬─────────┴────────┬─────────┴──────────┬───────────┘
         │                  │                     │
         │                  │                     │
         └──────────────────┼─────────────────────┘
                            │
                   HTTPS/REST API
                            │
         ┌──────────────────▼─────────────────────┐
         │       Node.js Backend API               │
         │         (Express.js)                    │
         │                                         │
         │  ┌─────────────────────────────────┐   │
         │  │   Authentication (JWT)          │   │
         │  │   - User Management             │   │
         │  │   - Role-Based Access Control   │   │
         │  └─────────────────────────────────┘   │
         │                                         │
         │  ┌─────────────────────────────────┐   │
         │  │   Business Logic                │   │
         │  │   - Materials Management        │   │
         │  │   - Marketplace Logic           │   │
         │  │   - Messaging System            │   │
         │  │   - Gamification Engine         │   │
         │  └─────────────────────────────────┘   │
         └───────────┬──────────────┬──────────────┘
                     │              │
         ┌───────────▼────────┐    │
         │  PostgreSQL        │    │
         │  Database          │    │
         │  (Render)          │    │
         └────────────────────┘    │
                                   │
                          ┌────────▼─────────┐
                          │   Cloudinary     │
                          │   Media Storage  │
                          └──────────────────┘
```

<p align="center">
  <img src="designs_screenshots/system_architecture.png" alt="System Architecture Diagram" width="600"/>
</p>

---

## Technology Stack

### Frontend Technologies

#### Flutter Mobile App
- **Framework**: Flutter 3.0+
- **Language**: Dart
- **State Management**: Provider
- **Local Storage**: Shared Preferences
- **Image Handling**: Cached Network Image
- **Navigation**: Flutter Navigator 2.0

#### React Web Applications
- **Framework**: React 18
- **Language**: TypeScript
- **Build Tool**: Vite
- **Styling**: CSS Modules
- **HTTP Client**: Axios
- **Routing**: React Router v6
- **State Management**: React Context API

### Backend Technologies

- **Runtime**: Node.js v18+
- **Framework**: Express.js
- **Database ORM**: Raw SQL queries with pg library
- **Authentication**: JSON Web Tokens (JWT)
- **Password Hashing**: bcrypt
- **File Upload**: Multer
- **Environment Variables**: dotenv
- **CORS**: cors middleware

### Database

- **DBMS**: PostgreSQL 14+
- **Hosting**: Render PostgreSQL
- **Connection Pooling**: pg Pool

### Third-Party Services

- **Media Storage**: Cloudinary
- **Deployment**:
  - Backend: Render
  - Frontend: Vercel
- **Version Control**: GitHub

---

## Database Design

### Entity Relationship Diagram

```
┌──────────────┐         ┌──────────────┐         ┌──────────────┐
│    Users     │         │  Materials   │         │   Products   │
├──────────────┤         ├──────────────┤         ├──────────────┤
│ id (PK)      │────┐    │ id (PK)      │         │ id (PK)      │
│ email        │    │    │ user_id (FK) │         │ artisan_id   │
│ password     │    │    │ title        │         │ title        │
│ name         │    │    │ description  │         │ description  │
│ role         │    │    │ category     │         │ price        │
│ phone        │    │    │ quantity     │         │ images       │
│ location     │    │    │ images       │         │ status       │
│ eco_points   │    │    │ status       │         │ created_at   │
│ created_at   │    │    │ created_at   │         └──────────────┘
└──────────────┘    │    └──────────────┘
                    │
                    │    ┌──────────────┐
                    └───▶│   Claims     │
                         ├──────────────┤
                         │ id (PK)      │
                         │ material_id  │
                         │ artisan_id   │
                         │ status       │
                         │ created_at   │
                         └──────────────┘
```

### Core Tables

#### Users Table
```sql
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    location VARCHAR(255),
    eco_points INTEGER DEFAULT 0,
    badges JSONB DEFAULT '[]',
    profile_image TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### Materials Table
```sql
CREATE TABLE materials (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(100),
    quantity VARCHAR(50),
    condition VARCHAR(50),
    images JSONB DEFAULT '[]',
    location VARCHAR(255),
    status VARCHAR(50) DEFAULT 'available', -- 'available', 'claimed', 'collected'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### Products Table
```sql
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    artisan_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    category VARCHAR(100),
    images JSONB DEFAULT '[]',
    stock INTEGER DEFAULT 1,
    status VARCHAR(50) DEFAULT 'available', -- 'available', 'sold'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### Orders Table
```sql
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    buyer_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES products(id) ON DELETE CASCADE,
    quantity INTEGER NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    delivery_address TEXT,
    status VARCHAR(50) DEFAULT 'pending', -- 'pending', 'confirmed', 'delivered'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### Messages Table
```sql
CREATE TABLE messages (
    id SERIAL PRIMARY KEY,
    sender_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    receiver_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    message TEXT NOT NULL,
    read BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### Claims Table
```sql
CREATE TABLE claims (
    id SERIAL PRIMARY KEY,
    material_id INTEGER REFERENCES materials(id) ON DELETE CASCADE,
    artisan_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    status VARCHAR(50) DEFAULT 'pending', -- 'pending', 'approved', 'rejected'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## API Architecture

### RESTful API Endpoints

#### Authentication
```
POST   /api/signup          - Register new user
POST   /api/login           - User login
POST   /api/logout          - User logout
GET    /api/profile         - Get user profile (requires JWT)
PUT    /api/profile         - Update user profile (requires JWT)
```

#### Materials
```
GET    /api/materials       - Get all available materials
GET    /api/materials/:id   - Get material details
POST   /api/materials       - Create new material listing (donor)
PUT    /api/materials/:id   - Update material
DELETE /api/materials/:id   - Delete material
GET    /api/my-materials    - Get user's materials
```

#### Products
```
GET    /api/products        - Get all products
GET    /api/products/:id    - Get product details
POST   /api/products        - Create new product (artisan)
PUT    /api/products/:id    - Update product
DELETE /api/products/:id    - Delete product
GET    /api/my-products     - Get artisan's products
```

#### Orders
```
POST   /api/orders          - Create new order
GET    /api/orders          - Get user's orders
GET    /api/orders/:id      - Get order details
PUT    /api/orders/:id      - Update order status
```

#### Messages
```
GET    /api/messages        - Get user's messages
POST   /api/messages        - Send message
PUT    /api/messages/:id    - Mark message as read
GET    /api/conversations   - Get user's conversations
```

#### Claims
```
POST   /api/claims          - Claim material (artisan)
GET    /api/claims          - Get user's claims
PUT    /api/claims/:id      - Update claim status
```

#### Gamification
```
GET    /api/leaderboard     - Get eco-points leaderboard
GET    /api/badges          - Get user's badges
POST   /api/award-points    - Award eco-points (system)
```

### API Response Format

**Success Response:**
```json
{
  "success": true,
  "data": {
    // Response data
  },
  "message": "Operation successful"
}
```

**Error Response:**
```json
{
  "success": false,
  "error": "Error message",
  "details": {
    // Additional error details
  }
}
```

---

## Authentication & Security

### JWT-Based Authentication

1. **User Registration/Login**:
   - User submits credentials
   - Server validates and hashes password with bcrypt
   - Server generates JWT token with user info
   - Token sent to client

2. **Authenticated Requests**:
   - Client includes JWT in Authorization header: `Bearer <token>`
   - Server validates token
   - Server extracts user info from token
   - Request processed with user context

### Security Measures

- **Password Hashing**: bcrypt with salt rounds
- **JWT Expiration**: Tokens expire after 7 days
- **CORS**: Configured to allow specific origins
- **SQL Injection Prevention**: Parameterized queries
- **Role-Based Access Control**: User roles (donor, artisan, buyer, admin)
- **HTTPS**: All production traffic encrypted
- **Environment Variables**: Sensitive data stored in .env

---

## Use Case Diagrams

### System Actors

- **Donor**: Lists waste materials for collection
- **Artisan**: Claims materials and sells upcycled products
- **Buyer**: Purchases upcycled products
- **Admin**: Manages platform and users

<p align="center">
  <img src="designs_screenshots/use_case_diagram.png" alt="Use Case Diagram" width="300"/>
</p>

### Primary Use Cases

#### Donor Use Cases
1. Register/Login
2. List waste materials
3. View material status
4. Manage listings
5. Earn eco-points
6. View badges and achievements

#### Artisan Use Cases
1. Register/Login
2. Browse available materials
3. Claim materials
4. Upload upcycled products
5. Manage product inventory
6. Communicate with donors/buyers
7. Process orders

#### Buyer Use Cases
1. Register/Login
2. Browse marketplace
3. Add products to cart
4. Checkout and pay
5. Track orders
6. Rate products
7. Message artisans

#### Admin Use Cases
1. Login to admin dashboard
2. View platform statistics
3. Manage users
4. Moderate listings
5. Handle disputes
6. Generate reports

---

## Data Flow

### Material Listing Flow

```
┌────────┐     ┌─────────┐     ┌──────────┐     ┌────────────┐
│ Donor  │────▶│ Flutter │────▶│ Backend  │────▶│ PostgreSQL │
│        │     │   App   │     │   API    │     │  Database  │
└────────┘     └─────────┘     └──────────┘     └────────────┘
                    │                │
                    │                ▼
                    │           ┌──────────┐
                    └──────────▶│Cloudinary│
                                │  (Images)│
                                └──────────┘
```

1. Donor fills material listing form
2. Images uploaded to Cloudinary
3. Material data with image URLs sent to backend
4. Backend validates and stores in PostgreSQL
5. Eco-points awarded to donor
6. Material appears in browse feed

### Product Purchase Flow

```
┌────────┐     ┌─────────┐     ┌──────────┐     ┌──────────┐
│ Buyer  │────▶│ Flutter │────▶│ Backend  │────▶│ Database │
│        │     │   App   │     │   API    │     │          │
└────────┘     └─────────┘     └────────┘      └──────────┘
                                     │
                                     ▼
                              ┌────────────┐
                              │ Notification│
                              │  to Artisan │
                              └────────────┘
```

1. Buyer browses marketplace
2. Adds product to cart
3. Proceeds to checkout
4. Order created in database
5. Artisan notified
6. Order status updated as processed

---

## Scalability Considerations

### Current Architecture
- Single server backend on Render
- PostgreSQL database with connection pooling
- Cloudinary for media CDN

### Future Improvements
- Load balancing for backend API
- Database read replicas
- Redis caching layer
- Message queue for notifications (RabbitMQ/Redis)
- Microservices architecture for specific features
- WebSocket for real-time chat
- Mobile push notifications via Firebase

---

## Deployment Architecture

### Production Environment

```
┌─────────────────────────────────────────────────┐
│               Vercel CDN                         │
│  ┌────────────────┐    ┌────────────────┐      │
│  │   Web App      │    │ Admin Dashboard│      │
│  └────────────────┘    └────────────────┘      │
└─────────────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────┐
│            Render Platform                       │
│  ┌────────────────┐    ┌────────────────┐      │
│  │  Node.js API   │───▶│  PostgreSQL    │      │
│  └────────────────┘    └────────────────┘      │
└─────────────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────┐
│               Cloudinary CDN                     │
│           (Image Storage & Delivery)             │
└─────────────────────────────────────────────────┘
```

### CI/CD Pipeline

- **Version Control**: GitHub
- **Backend Deployment**: Auto-deploy from main branch to Render
- **Frontend Deployment**: Auto-deploy from main branch to Vercel
- **Database Migrations**: Manual SQL scripts
- **Environment Variables**: Managed in Render/Vercel dashboards

---

## Monitoring & Logging

### Current Implementation
- Server-side console logging
- Error tracking in backend
- Render platform logs
- Vercel deployment logs

### Planned Improvements
- Application Performance Monitoring (APM)
- Error tracking (Sentry)
- Analytics (Google Analytics/Mixpanel)
- Database query optimization
- API response time monitoring

---

## Performance Optimization

### Implemented
- Image optimization via Cloudinary
- Database indexing on frequently queried fields
- Connection pooling for database
- Lazy loading in Flutter app
- Code splitting in React apps

### Future Optimizations
- API response caching
- Database query optimization
- CDN for static assets
- Image lazy loading
- Pagination for large datasets
- GraphQL for flexible queries

---

<p align="center">
  <strong>For questions about the architecture, contact:</strong><br>
  📧 p.giibwa@alustudent.com
</p>
