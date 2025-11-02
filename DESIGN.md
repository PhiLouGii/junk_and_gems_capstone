# Design Documentation

This document outlines the UI/UX design philosophy, visual identity, and design resources for the Junk & Gems platform.

---

## Table of Contents

- [Design Philosophy](#design-philosophy)
- [Style Guide](#style-guide)
- [Figma Resources](#figma-resources)
- [User Interface Screens](#user-interface-screens)
- [Responsive Design](#responsive-design)

---

## Design Philosophy

### Core Principles

**1. Sustainability First**
- Visual elements reflect environmental consciousness
- Green color palette emphasizing eco-friendliness
- Natural imagery and earth tones

**2. User-Centric Design**
- Simple, intuitive navigation
- Clear call-to-action buttons
- Minimal cognitive load
- Consistent user experience across platforms

**3. Community Focus**
- Social features prominently displayed
- Profile-based interactions
- Visual feedback for contributions

**4. Accessibility**
- High contrast ratios for readability
- Clear typography
- Icon + text labels for clarity
- Support for different screen sizes

### Design Goals

- ✅ Make waste donation feel rewarding and easy
- ✅ Showcase artisan creativity and craftsmanship
- ✅ Create trust in the marketplace
- ✅ Gamify environmental responsibility
- ✅ Build a sense of community

---

## Style Guide

<p align="center">
  <img src="designs_screenshots/junk_and_gems_style_guide.png" alt="Junk & Gems Style Guide" width="600"/>
</p>

### Color Palette

#### Primary Colors
```css
/* Brand Cream - Primary light background */
--primary-cream: #F7F2E4;
--primary-cream-dark: #EDE5D0;

/* Sage Green - Primary brand color */
--primary-sage: #E4E5C2;
--primary-sage-medium: #BEC092;
--primary-sage-dark: #8B8A4D;

```

#### Accent Colors
```css
/* Natural earth tones for emphasis */
--accent-olive: #8B8A4D;
--accent-green: #6B7A3E;
--accent-warm: #D4C5A0;
```

#### Neutral Colors
```css
/* Text and backgrounds */
--text-primary: #212121;
--text-secondary: #5D5D5D;
--background-white: #FFFFFF;
--background-cream: #F7F2E4;
--background-light-sage: #E4E5C2;
--border-sage: #BEC092;
```

#### Semantic Colors
```css
/* Status indicators */
--success: #6B7A3E;
--warning: #D4A843;
--error: #C84B4B;
--info: #7B92A8;
```

### Typography

#### Font Families
```css
/* Primary font - Sans-serif for readability */
--font-primary: 'Inter', 'Roboto', -apple-system, sans-serif;

/* Display font - For headings */
--font-display: 'Poppins', 'Montserrat', sans-serif;

/* Monospace - For code/numbers */
--font-mono: 'Roboto Mono', 'Courier New', monospace;
```

#### Font Sizes
```css
/* Mobile-first sizing */
--text-xs: 12px;    /* Small labels */
--text-sm: 14px;    /* Body text, captions */
--text-base: 16px;  /* Default body text */
--text-lg: 18px;    /* Large body text */
--text-xl: 20px;    /* Small headings */
--text-2xl: 24px;   /* Section headings */
--text-3xl: 30px;   /* Page titles */
--text-4xl: 36px;   /* Hero text */
```

#### Font Weights
```css
--font-light: 300;
--font-regular: 400;
--font-medium: 500;
--font-semibold: 600;
--font-bold: 700;
```

### Spacing System

```css
/* Consistent spacing scale (8px base) */
--space-xs: 4px;
--space-sm: 8px;
--space-md: 16px;
--space-lg: 24px;
--space-xl: 32px;
--space-2xl: 48px;
--space-3xl: 64px;
```

### Border Radius

```css
--radius-sm: 4px;   /* Small elements */
--radius-md: 8px;   /* Cards, buttons */
--radius-lg: 12px;  /* Large cards */
--radius-xl: 16px;  /* Modal dialogs */
--radius-full: 50%; /* Circular elements */
```

### Shadows

```css
/* Elevation system */
--shadow-sm: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
--shadow-md: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
--shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
--shadow-xl: 0 20px 25px -5px rgba(0, 0, 0, 0.1);
```

### Icons

- **Icon Library**: Material Icons / Feather Icons
- **Icon Size**: 20px, 24px, 32px (standard sizes)
- **Style**: Rounded, consistent stroke width
- **Color**: Inherits from parent or uses semantic colors

---

## Figma Resources

### Design Files

#### 📐 Figma Design File
**Full design system with all screens and components**

🔗 [View in Figma Dev Mode](https://www.figma.com/design/AqZ8CWOhF8oJXGAHxK5sFE/Junk-and-Gems-Prototype?node-id=0-1&m=dev&t=dp3YKVdOms4HANn4-1)

**Includes:**
- All mobile app screens (50+ screens)
- Component library
- Design tokens
- Spacing and layout guides
- Color palette
- Typography system

#### 🎨 Interactive Prototype
**Clickable prototype to experience user flows**

🔗 [View Interactive Prototype](https://www.figma.com/proto/AqZ8CWOhF8oJXGAHxK5sFE/Junk-and-Gems-Prototype?node-id=0-1&t=R11EvJN283hIJr0l-1)

**Features:**
- Full user journey simulation
- Realistic interactions
- Transition animations
- Mobile viewport preview

### Figma File Structure

```
Junk & Gems Design
├── 📱 Mobile App
│   ├── Authentication
│   │   ├── Splash Screen
│   │   ├── Onboarding (3 screens)
│   │   ├── Login
│   │   └── Signup
│   │
Figma File Structure
Junk & Gems Design
├── 📱 Mobile App
│   ├── Authentication
│   │   ├── Splash Screen
│   │   ├── Onboarding (3 screens)
│   │   ├── Login
│   │   └── Signup
│   │
│   ├── Dashboard (Shared by all users)
│   │   ├── Home
│   │   ├── Browse Materials 
│   │   ├── Marketplace 
│   │   ├── Upcycled Products
│   │   ├── Product Details
│   │   ├── Cart 
│   │   ├── Checkout 
│   │   ├── Upload Material 
│   │   ├── Upload Product 
│   │
│   ├── Shared Screens
│   │   ├── Profile
│   │   ├── Edit Profile
│   │   ├── Messages
│   │   ├── Chat
│   │   ├── Notifications
│   │   └── Achievements
│   │
│   └── Components
│       ├── Buttons
│       ├── Cards
│       ├── Forms
│       ├── Navigation
│   │
│   └── Components
│       ├── Buttons
│       ├── Cards
│       ├── Forms
│       ├── Navigation
│
├── 🌐 Web App
│   ├── Landing Page
│   ├── About
│   └── Gallery
│
└── ⚙️ Design System
    ├── Colors
    ├── Typography
    ├── Spacing
    ├── Icons
    └── Illustrations
```

---

#### Product Details
- Image carousel
- Product title and price
- Artisan name and rating
- Description
- Materials used
- [Add to Cart] button
- [Message Artisan] button

#### Cart & Checkout
- Cart items list
- Quantity adjusters
- Gems Discount
- Subtotal calculation
- Delivery address form
- Payment method selection
- [Place Order] button

---

### Shared Screens

#### Profile
- Profile picture (editable)
- Name
- Location
- Statistics (materials donated, products sold, etc.)
- [Edit Profile] button
- [Settings] button

#### Messages
- Conversation list
- Unread indicators
- Last message preview
- Timestamp

#### Chat
- Message thread
- Text input
- Send button
- Image attachment option
---

---

## Responsive Design

### Breakpoints

```css
/* Mobile First Approach */
--mobile: 320px - 767px;     /* Base styles */
--tablet: 768px - 1023px;    /* Tablet adjustments */
--desktop: 1024px+;          /* Desktop layouts */
```

### Mobile (Default)
- Single column layout
- Bottom navigation
- Full-width cards
- Stacked forms

### Tablet
- Two-column grid for cards
- Side navigation drawer
- Larger touch targets
- More whitespace

### Desktop (Web App)
- Multi-column layouts
- Top navigation bar
- Hover states
- Wider content area (max-width: 1200px)

---

---

## Illustrations & Graphics

### Illustration Style
- Flat design with simple shapes
- Limited color palette from brand colors
- Friendly, inclusive characters
- Environmental themes

### Photography
- High-quality, authentic images
- Show real people and materials
- Natural lighting preferred
- Consistent editing style

### Icons
- Consistent stroke width: 2px
- Rounded corners
- 24x24px standard size
- Single color (adaptable)

---

## Design Assets

### File Formats
- **Vector**: SVG, PDF (for scalability)
- **Raster**: PNG (with transparency)
- **Web**: WebP (optimized for web)

---

## Future Design Improvements

### Planned Enhancements
- 3D product models
- Video support for tutorials
- Personalised dashboard layouts

---

<p align="center">
  <strong>Design Questions?</strong><br>
  📧 p.giibwa@alustudent.com<br>
  🎨 <a href="https://www.figma.com/design/AqZ8CWOhF8oJXGAHxK5sFE/Junk-and-Gems-Prototype">View Full Design in Figma</a>
</p>

<p align="center">
  <em>Designed with 💚 for sustainable communities</em>
</p>
