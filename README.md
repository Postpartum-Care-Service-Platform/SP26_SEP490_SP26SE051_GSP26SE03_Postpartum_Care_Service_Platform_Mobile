# The Joyful Nest - Postpartum Care Service

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.9.2-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.9.2-0175C2?logo=dart&logoColor=white)
![License](https://img.shields.io/badge/License-Private-red)
![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android%20%7C%20Web-lightgrey)
![BLoC](https://img.shields.io/badge/State%20Management-BLoC-8B5CF6?logo=flutter&logoColor=white)
![Architecture](https://img.shields.io/badge/Architecture-Clean%20Architecture-00D9FF?logo=flutter&logoColor=white)

**A comprehensive mobile application for postpartum care services and resort management**

[Features](#-features) • [Architecture](#-architecture) • [Getting Started](#-getting-started) • [Documentation](#-documentation) • [Tech Stack](#-tech-stack)

</div>

---

## 📱 Overview

**The Joyful Nest** is a modern Flutter application designed to provide comprehensive postpartum care services. The app enables families to manage their care plans, book services, track schedules, and access personalized care programs during their stay at the resort. The application also includes dedicated portals for employees to manage appointments, services, and customer interactions.

### Key Highlights

| Feature | Description |
|---------|-------------|
| 🏥 **Comprehensive Care Management** | Track daily care activities and schedules with real-time updates |
| 👨‍👩‍👧‍👦 **Family Profile Management** | Manage multiple family members and their profiles with medical records |
| 📦 **Service Packages** | Browse and select from various care packages with detailed care plans |
| 📅 **Schedule Management** | View and manage upcoming appointments with calendar integration |
| 🔔 **Real-time Notifications** | Stay updated with important updates via push notifications |
| 💬 **In-app Communication** | Direct real-time communication with care providers via SignalR |
| 💳 **Payment Integration** | Secure payment processing with PayOS integration |
| 👨‍💼 **Employee Portal** | Dedicated portal for staff to manage appointments and services |
| 🍽️ **Meal Planning** | Plan and manage daily meals for families |
| 📊 **Feedback System** | Submit and track feedback for services and care quality |

---

## ✨ Features

### 🔐 Authentication & Security

| Feature | Implementation |
|---------|----------------|
| **Email/Password Auth** | Secure authentication with email verification |
| **Google Sign-In** | One-tap Google authentication integration |
| **OTP Verification** | Email OTP verification for account security |
| **Password Management** | Forgot password, reset password, and change password flows |
| **Token Management** | Automatic token refresh with secure storage |
| **Secure Storage** | Encrypted local storage for sensitive data |

### 📦 Package & Booking Management

- **Package Browsing**: Interactive carousel with infinite scroll
- **Package Details**: Comprehensive information with pricing, duration, and care plans
- **Booking Creation**: Multi-step booking process with family member selection
- **Payment Processing**: PayOS integration for secure payment links
- **Booking History**: View past and upcoming bookings
- **Invoice Generation**: Digital invoices with PDF export
- **Contract Management**: View and export service contracts

### 🏥 Care Plan & Services

- **Day-by-Day Timeline**: Visual timeline of care activities
- **Activity Scheduling**: Schedule activities with time slots
- **Service Dashboard**: Interactive dashboard for service management
- **Service Booking**: Book amenity services and activities
- **Activity Details**: Detailed instructions for each activity
- **Schedule Views**: Day, week, and month views for schedules
- **Service Ratings**: Star rating system for service feedback

### 👨‍👩‍👧‍👦 Family Management

- **Family Profiles**: Add and manage multiple family members
- **Profile Customization**: Custom avatars and profile information
- **Member Relationships**: Define relationships (mother, baby, etc.)
- **Medical Records**: Track medical information and history
- **Family Portal**: Dedicated portal for family members
- **Baby Daily Reports**: Track daily baby care activities
- **Meal Selection**: Select and manage daily meals

### 📅 Appointment System

- **Appointment Booking**: Create appointments with type selection
- **Appointment Management**: View, update, and cancel appointments
- **Appointment Types**: Various appointment types (consultation, checkup, etc.)
- **Calendar Integration**: Visual calendar for appointment scheduling
- **Status Tracking**: Track appointment status (scheduled, confirmed, completed, cancelled)
- **Employee Assignment**: Automatic staff assignment for appointments

### 💬 Real-time Chat

- **Conversation Management**: List and manage conversations
- **Real-time Messaging**: SignalR-powered real-time chat
- **Support Requests**: Request support staff assistance
- **Read Receipts**: Message read status tracking
- **Staff Integration**: Direct communication with care staff
- **Message History**: Persistent message history

### 🔔 Notification System

- **Real-time Notifications**: Push notifications for important updates
- **Notification Drawer**: Centralized notification management
- **Unread Tracking**: Badge count for unread notifications
- **Mark as Read**: Individual and bulk mark as read
- **Notification Types**: Various notification categories

### 👨‍💼 Employee Portal

| Feature | Description |
|---------|-------------|
| **Appointment Management** | View assigned and all appointments |
| **Appointment Actions** | Confirm, complete, and cancel appointments |
| **Room Management** | View and manage resort rooms |
| **Service Booking** | Create service bookings for customers |
| **Amenity Services** | Manage amenity services and availability |
| **Meal Plan Management** | Manage customer meal plans |
| **Check-in/Check-out** | Handle customer check-in and check-out |
| **Schedule View** | View daily, weekly schedules |
| **Task Management** | Manage assigned tasks and requests |

### 🍽️ Meal Planning

- **Menu Selection**: Browse available menus by type
- **Daily Meal Planning**: Plan meals for specific dates
- **Meal Records**: Track meal selections and history
- **Menu Types**: Breakfast, lunch, dinner, and snacks
- **Family Meal Management**: Manage meals for all family members

### 📊 Feedback & Support

- **Feedback Submission**: Submit feedback for services
- **Feedback Types**: Various feedback categories
- **Feedback History**: View past feedback submissions
- **Support Center**: Help and support resources
- **Contact Information**: Direct contact with support team
- **Terms & Privacy**: Access to terms and privacy policies

### 🏠 Home Dashboard

- **Personalized Greeting**: Time-based greetings (Good morning, afternoon, evening)
- **Quick Actions**: Shortcuts to main features
- **Upcoming Schedule**: Preview of upcoming appointments
- **Promotional Packages**: Featured packages carousel
- **Notification Summary**: Quick access to notifications

---

## 🏗️ Architecture

This project follows **Clean Architecture** principles with clear separation of concerns:

```
┌─────────────────────────────────────────────────────────────┐
│              Presentation Layer (UI)                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │
│  │     BLoC     │  │   Screens    │  │   Widgets    │       │
│  │  (State Mgmt)│  │  (Full Pages)│  │ (Reusable)   │       │
│  └──────────────┘  └──────────────┘  └──────────────┘       │
└─────────────────────────────────────────────────────────────┘
                          ↕ Events/States
┌─────────────────────────────────────────────────────────────┐
│              Domain Layer (Business Logic)                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │
│  │   Entities   │  │  Use Cases   │  │ Repositories │       │
│  │  (Pure Dart) │  │ (Business)   │  │ (Interfaces) │       │
│  └──────────────┘  └──────────────┘  └──────────────┘       │
└─────────────────────────────────────────────────────────────┘
                          ↕ Data Flow
┌─────────────────────────────────────────────────────────────┐
│              Data Layer (Infrastructure)                    │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │
│  │    Models    │  │ Data Sources │  │ Repositories │       │
│  │  (DTO/JSON)  │  │ (API/Local)  │  │ (Impl)       │       │
│  └──────────────┘  └──────────────┘  └──────────────┘       │
└─────────────────────────────────────────────────────────────┘
```

### Architecture Layers

#### 1. **Domain Layer** (Business Logic)
- **Entities**: Pure Dart classes representing business objects
- **Repositories**: Abstract interfaces defining data contracts
- **Use Cases**: Business logic operations (single responsibility)

#### 2. **Data Layer** (Infrastructure)
- **Models**: Data transfer objects with JSON serialization
- **Data Sources**: API (remote) and local data access
- **Repository Implementations**: Concrete implementations of domain repositories

#### 3. **Presentation Layer** (UI)
- **BLoC**: State management using BLoC pattern
- **Screens**: Full-page UI components
- **Widgets**: Reusable UI components

### Data Flow

```
User Action
    ↓
Screen Widget
    ↓
BLoC Event
    ↓
Use Case
    ↓
Repository (Interface)
    ↓
Repository Implementation
    ↓
Data Source
    ↓
API / Local Storage
    ↓
Response flows back up
    ↓
BLoC State Update
    ↓
UI Rebuild
```

---

## 🛠️ Tech Stack

### Core Technologies

| Technology | Version | Purpose |
|------------|---------|---------|
| **Flutter** | 3.9.2 | Cross-platform framework |
| **Dart** | 3.9.2 | Programming language |
| **BLoC** | 8.1.6 | State management pattern |
| **Dio** | 5.4.0 | HTTP client for API calls |
| **SignalR** | 1.1.1 | Real-time communication |

### Key Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_bloc` | ^8.1.6 | State management |
| `equatable` | ^2.0.5 | Value equality for BLoC |
| `dio` | ^5.4.0 | HTTP client |
| `google_fonts` | ^6.1.0 | Custom typography (Tinos, Arimo) |
| `flutter_secure_storage` | ^9.0.0 | Secure token storage |
| `google_sign_in` | ^6.2.1 | Google authentication |
| `image_picker` | ^1.0.7 | Image selection |
| `permission_handler` | ^11.3.1 | Runtime permissions |
| `flutter_svg` | ^2.0.10 | SVG icon support |
| `signalr_netcore` | ^1.1.1 | Real-time chat (SignalR) |
| `flutter_map` | ^6.1.0 | Map integration |
| `qr_flutter` | ^4.1.0 | QR code generation |
| `intl` | ^0.20.2 | Internationalization |
| `flutter_dotenv` | ^5.1.0 | Environment variables |
| `path_provider` | ^2.1.2 | File system paths |
| `url_launcher` | ^6.3.0 | URL launching |

### Development Tools

| Tool | Purpose |
|------|---------|
| `flutter_lints` | Code linting |
| `flutter_launcher_icons` | App icon generation |

---

## 📁 Project Structure

```
lib/
├── core/                          # Core functionality
│   ├── apis/                      # API client & endpoints
│   │   ├── api_client.dart        # Dio client configuration
│   │   └── api_endpoints.dart     # All API endpoints
│   ├── config/                    # App configuration
│   │   └── app_config.dart        # Environment & config
│   ├── constants/                 # App constants
│   │   ├── app_colors.dart        # Color definitions
│   │   ├── app_strings.dart      # String constants
│   │   └── app_assets.dart        # Asset paths
│   ├── di/                        # Dependency injection
│   │   └── injection_container.dart
│   ├── errors/                    # Error handling
│   ├── routing/                   # Navigation
│   │   ├── app_router.dart        # Route generator
│   │   └── app_routes.dart        # Route constants
│   ├── services/                  # Core services
│   ├── storage/                   # Storage services
│   ├── utils/                     # Utilities
│   │   ├── app_responsive.dart    # Responsive scaling
│   │   └── app_text_styles.dart   # Text styles
│   └── widgets/                   # Reusable widgets
│
├── features/                      # Feature modules
│   ├── auth/                      # Authentication
│   │   ├── data/                  # Data layer
│   │   │   ├── datasources/       # API data sources
│   │   │   ├── models/            # Data models
│   │   │   └── repositories/      # Repository impl
│   │   ├── domain/                # Domain layer
│   │   │   ├── entities/          # Business entities
│   │   │   ├── repositories/      # Repository interfaces
│   │   │   └── usecases/          # Use cases
│   │   └── presentation/          # Presentation layer
│   │       ├── bloc/              # BLoC (events, states, bloc)
│   │       ├── screens/           # Screen widgets
│   │       └── widgets/           # Feature widgets
│   │
│   ├── package/                   # Package management
│   ├── care_plan/                 # Care plan details
│   ├── booking/                   # Booking management
│   ├── appointment/               # Appointment system
│   ├── chat/                      # Real-time chat
│   ├── notification/              # Notifications
│   ├── family_profile/            # Family profile management
│   ├── family/                    # Family portal
│   ├── employee/                  # Employee portal
│   ├── services/                  # Service management
│   ├── home/                      # Home dashboard
│   ├── profile/                   # User profile
│   ├── contract/                  # Contract management
│   ├── meal_plan/                 # Meal planning
│   ├── supportAndPolicy/         # Support & policies
│   └── ...
│
└── main.dart                      # Application entry point
```

### Feature Module Structure

Each feature follows a consistent Clean Architecture structure:

```
feature_name/
├── data/
│   ├── datasources/              # Remote/Local data sources
│   │   ├── {feature}_remote_datasource.dart
│   │   └── {feature}_local_datasource.dart (if needed)
│   ├── models/                   # Data models (DTO)
│   │   └── {feature}_model.dart
│   └── repositories/             # Repository implementations
│       └── {feature}_repository_impl.dart
│
├── domain/
│   ├── entities/                 # Business entities
│   │   └── {feature}_entity.dart
│   ├── repositories/             # Repository interfaces
│   │   └── {feature}_repository.dart
│   └── usecases/                 # Business logic
│       ├── get_{feature}_usecase.dart
│       └── create_{feature}_usecase.dart
│
└── presentation/
    ├── bloc/                     # BLoC pattern
    │   ├── {feature}_event.dart
    │   ├── {feature}_state.dart
    │   └── {feature}_bloc.dart
    ├── screens/                  # Screen widgets
    │   └── {feature}_screen.dart
    └── widgets/                  # Feature-specific widgets
        └── {feature}_widget.dart
```

---

## 🚀 Getting Started

### Prerequisites

| Requirement | Version | Notes |
|------------|---------|-------|
| **Flutter SDK** | 3.9.2+ | [Install Flutter](https://docs.flutter.dev/get-started/install) |
| **Dart SDK** | 3.9.2+ | Included with Flutter |
| **Android Studio** | Latest | For Android development |
| **VS Code** | Latest | Alternative IDE with Flutter extensions |
| **Xcode** | Latest | For iOS development (macOS only) |
| **Git** | Latest | Version control |

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd postpartum_service
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure environment variables**
   
   Create a `.env` file in the root directory:
   ```env
   API_URL=https://your-api-url.com
   SIGNALR_URL=https://your-signalr-url.com
   GOOGLE_CLIENT_ID=your-google-client-id
   ```

4. **Run the application**
   ```bash
   # For development
   flutter run
   
   # For specific platform
   flutter run -d android
   flutter run -d ios
   flutter run -d chrome
   ```

### Build for Production

```bash
# Android
flutter build apk --release              # APK file
flutter build appbundle --release        # App Bundle for Play Store

# iOS
flutter build ios --release              # iOS build
flutter build ipa --release              # IPA for App Store

# Web
flutter build web --release              # Web deployment
```

---

## 📖 Development Guidelines

### Code Standards

This project follows strict coding standards. Please refer to [`SKILL.md`](SKILL.md) for detailed guidelines.

#### Key Principles

1. ✅ **Clean Architecture**: Strict separation of layers
2. ✅ **BLoC Pattern**: All state management via BLoC
3. ✅ **Constants First**: No hard-coded strings or colors
4. ✅ **Responsive Design**: All dimensions scaled with `AppResponsive`
5. ✅ **Null Safety**: Full null-safety compliance
6. ✅ **Error Handling**: Comprehensive error handling with user-friendly messages

### Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| **Files** | `snake_case.dart` | `auth_screen.dart` |
| **Classes** | `PascalCase` | `AuthBloc` |
| **Variables/Methods** | `camelCase` | `getUserData()` |
| **Constants** | `camelCase` in classes | `AppColors.primary` |
| **Private Members** | `_camelCase` | `_userRepository` |

### Adding a New Feature

1. **Create feature directory structure**
   ```
   lib/features/new_feature/
   ├── data/
   ├── domain/
   └── presentation/
   ```

2. **Implement layers in order**
   - Domain (entities, repository interface, use case)
   - Data (model, data source, repository implementation)
   - Presentation (BLoC, screens, widgets)

3. **Register dependencies** in `injection_container.dart`

4. **Add API endpoints** in `api_endpoints.dart`

5. **Add constants** in `app_strings.dart` and `app_colors.dart`

6. **Add routes** in `app_routes.dart` and `app_router.dart`

---

## 🔌 API Integration

### Base Configuration

The app uses Dio for HTTP requests with automatic token management:

- **Base URL**: Configured via `AppConfig.apiUrl`
- **Authentication**: Bearer token with auto-refresh
- **Error Handling**: Centralized error handling with user-friendly messages
- **Interceptors**: Request/response interceptors for logging and error handling

### API Endpoints

All endpoints are centralized in `lib/core/apis/api_endpoints.dart`:

| Category | Endpoints |
|----------|-----------|
| **Auth** | Login, Register, OTP, Password Reset, Google Sign-In |
| **Account** | Get Current Account, Get Account by ID |
| **Packages** | Get Packages |
| **Care Plans** | Get Care Plan Details by Package |
| **Bookings** | Create, Get, Payment Links, Payment Status |
| **Appointments** | CRUD operations, Types, Cancel |
| **Chat** | Conversations, Messages, Support Requests |
| **Notifications** | Get, Mark as Read, Get by ID |
| **Family Profiles** | CRUD operations, Member Types |
| **Services** | Get Services, Categories |
| **Contracts** | Get by Booking, Export PDF |
| **Employee** | Appointments, Rooms, Amenity Services, Tickets |
| **Menu** | Menus, Menu Records, Menu Types |
| **Feedback** | Create, Get My Feedbacks, Feedback Types |

### Request/Response Flow

```
┌─────────┐
│   UI    │
└────┬────┘
     │ User Action
     ↓
┌─────────┐
│  BLoC   │ ← Event
└────┬────┘
     │
     ↓
┌─────────┐
│Use Case │
└────┬────┘
     │
     ↓
┌──────────┐
│Repository│
└────┬─────┘
     │
     ↓
┌─────────┐
│Data Src │
└────┬────┘
     │
     ↓
┌─────────┐
│   API   │
└─────────┘
```

### Real-time Communication

The app uses **SignalR** for real-time features:

- **Chat Messages**: Real-time message delivery
- **Read Receipts**: Instant read status updates
- **Support Requests**: Real-time support request notifications
- **Staff Notifications**: Real-time staff assignment notifications

---

## 🎨 Design System

### Colors

| Color | Hex | Usage |
|-------|-----|-------|
| **Primary** | `#FF8C00` | Orange - Main brand color |
| **Secondary** | `#000000` | Black - Text and borders |
| **Background** | `#FFFBF5` | Light beige - App background |
| **Text Primary** | `#000000` | Black - Main text |
| **Text Secondary** | `#99A1AF` | Gray - Secondary text |
| **Border** | `#000000` | Black - Borders |
| **Border Light** | `rgba(0,0,0,0.2)` | Light borders |

### Typography

| Style | Font Family | Usage |
|-------|-------------|-------|
| **Titles** | Tinos (Google Fonts) | Headings, titles |
| **Body** | Arimo (Google Fonts) | Body text, descriptions |

### Components

| Component | Specifications |
|-----------|----------------|
| **Border Radius** | 12-16px (scaled) |
| **Padding** | 16-20px (scaled) |
| **Shadows** | Subtle with alpha 0.03-0.05 |
| **Buttons** | Height 52px, border radius 16px |
| **Text Inputs** | Height 52px, border radius 16px |
| **Cards** | Border radius 12-16px, subtle shadow |

---

## 📱 Supported Platforms

| Platform | Version | Status |
|----------|----------|--------|
| **Android** | API 21+ (Android 5.0+) | ✅ Fully Supported |
| **iOS** | iOS 12.0+ | ✅ Fully Supported |
| **Web** | Chrome, Firefox, Safari, Edge | ✅ Fully Supported |
| **Windows** | Windows 10+ | 🚧 Partial Support |
| **macOS** | macOS 10.14+ | 🚧 Partial Support |
| **Linux** | Ubuntu 18.04+ | 🚧 Partial Support |

---

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/features/auth/presentation/bloc/auth_bloc_test.dart

# Run tests in watch mode
flutter test --watch
```

### Test Coverage

- Unit tests for use cases
- Widget tests for UI components
- BLoC tests for state management
- Integration tests for critical flows

---

## 📝 Documentation

| Document | Location | Description |
|----------|----------|-------------|
| **Architecture Guidelines** | [`SKILL.md`](SKILL.md) | Detailed coding standards and architecture rules |
| **API Documentation** | `lib/core/apis/api_endpoints.dart` | All API endpoints |
| **Widget Documentation** | `lib/core/widgets/` | Reusable widget documentation |
| **Feature Documentation** | `lib/features/{feature}/` | Feature-specific documentation |

---

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Follow the coding standards in [`SKILL.md`](SKILL.md)
4. Commit your changes (`git commit -m 'feat: Add some AmazingFeature'`)
5. Push to the branch (`git push origin feature/AmazingFeature`)
6. Open a Pull Request

### Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types**: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

**Examples**:
- `feat(auth): Add Google Sign-In integration`
- `fix(booking): Fix payment link generation`
- `docs(readme): Update installation instructions`

---

## 📊 Project Statistics

| Metric | Count |
|--------|-------|
| **Features** | 15+ |
| **Screens** | 50+ |
| **API Endpoints** | 80+ |
| **Use Cases** | 60+ |
| **BLoC Components** | 20+ |
| **Widgets** | 100+ |

---

## 🔒 Security

- ✅ Secure token storage with `flutter_secure_storage`
- ✅ Automatic token refresh mechanism
- ✅ HTTPS-only API communication
- ✅ Input validation and sanitization
- ✅ Secure password handling
- ✅ OTP verification for sensitive operations

---

## 🌐 Internationalization

The app supports multiple languages:

- 🇺🇸 **English** (en_US)
- 🇻🇳 **Vietnamese** (vi_VN)

All user-facing strings are defined in `app_strings.dart` and can be easily extended for additional languages.

---

## 📄 License

This project is proprietary and confidential. All rights reserved.

---

## 👥 Team

**The Joyful Nest Development Team**

For questions or support, please contact the development team.

---

## 🔗 Related Resources

| Resource | Link |
|----------|------|
| **Flutter Documentation** | [docs.flutter.dev](https://docs.flutter.dev/) |
| **BLoC Pattern** | [bloclibrary.dev](https://bloclibrary.dev/) |
| **Clean Architecture** | [blog.cleancoder.com](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html) |
| **Dio HTTP Client** | [pub.dev/packages/dio](https://pub.dev/packages/dio) |
| **SignalR** | [signalr.net](https://dotnet.microsoft.com/apps/aspnet/signalr) |

---

<div align="center">

**Made with ❤️ by Postpartum Service Team**

⭐ Star this repo if you find it helpful!

</div>
