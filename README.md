# The Joyful Nest - Postpartum Care Service

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.9.2-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.9.2-0175C2?logo=dart&logoColor=white)
![License](https://img.shields.io/badge/License-Private-red)
![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android%20%7C%20Web-lightgrey)

**A comprehensive mobile application for postpartum care services and resort management**

[Features](#-features) • [Architecture](#-architecture) • [Getting Started](#-getting-started) • [Documentation](#-documentation)

</div>

---

## 📱 Overview

**The Joyful Nest** is a modern Flutter application designed to provide comprehensive postpartum care services. The app enables families to manage their care plans, book services, track schedules, and access personalized care programs during their stay at the resort.

### Key Highlights

- 🏥 **Comprehensive Care Management**: Track daily care activities and schedules
- 👨‍👩‍👧‍👦 **Family Profile Management**: Manage multiple family members and their profiles
- 📦 **Service Packages**: Browse and select from various care packages
- 📅 **Schedule Management**: View and manage upcoming appointments
- 🔔 **Real-time Notifications**: Stay updated with important updates
- 💬 **In-app Communication**: Direct communication with care providers

---

## ✨ Features

### Core Features

- **Authentication & Authorization**
  - Email/Password authentication
  - Google Sign-In integration
  - OTP verification
  - Secure token management with auto-refresh

- **Package Management**
  - Browse available service packages
  - View detailed care plans for each package
  - Interactive carousel with infinite scroll
  - Package details with pricing and duration

- **Care Plan Details**
  - Day-by-day activity timeline
  - Activity scheduling with time slots
  - Detailed instructions for each activity
  - Beautiful bottom sheet presentation

- **Family Profile**
  - Add and manage family members
  - Profile customization with avatars
  - Member relationship management
  - Medical records tracking

- **Home Dashboard**
  - Personalized greeting based on time
  - Quick action shortcuts
  - Upcoming schedule preview
  - Promotional packages carousel

- **Notifications**
  - Real-time notification system
  - Notification drawer
  - Unread count tracking
  - Mark as read functionality

---

## 🏗️ Architecture

This project follows **Clean Architecture** principles with clear separation of concerns:

```
┌─────────────────────────────────────┐
│     Presentation Layer (UI)        │
│  ┌──────────┐  ┌──────────┐        │
│  │  BLoC    │  │ Widgets  │        │
│  └──────────┘  └──────────┘        │
└─────────────────────────────────────┘
              ↕
┌─────────────────────────────────────┐
│        Domain Layer (Business)      │
│  ┌──────────┐  ┌──────────┐        │
│  │ Entities │  │ Use Cases │        │
│  └──────────┘  └──────────┘        │
└─────────────────────────────────────┘
              ↕
┌─────────────────────────────────────┐
│        Data Layer (Infrastructure)  │
│  ┌──────────┐  ┌──────────┐        │
│  │ Models   │  │ DataSrc  │        │
│  └──────────┘  └──────────┘        │
└─────────────────────────────────────┘
```

### Architecture Layers

1. **Domain Layer** (Business Logic)
   - Entities: Pure Dart classes representing business objects
   - Repositories: Abstract interfaces defining data contracts
   - Use Cases: Business logic operations

2. **Data Layer** (Infrastructure)
   - Models: Data transfer objects with JSON serialization
   - Data Sources: API and local data access
   - Repository Implementations: Concrete implementations of domain repositories

3. **Presentation Layer** (UI)
   - BLoC: State management using BLoC pattern
   - Screens: Full-page UI components
   - Widgets: Reusable UI components

---

## 🛠️ Tech Stack

### Core Technologies

- **Framework**: Flutter 3.9.2
- **Language**: Dart 3.9.2
- **State Management**: BLoC Pattern (flutter_bloc 8.1.6)
- **HTTP Client**: Dio 5.4.0
- **Local Storage**: flutter_secure_storage 9.0.0

### Key Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_bloc` | ^8.1.6 | State management |
| `equatable` | ^2.0.5 | Value equality |
| `dio` | ^5.4.0 | HTTP client |
| `google_fonts` | ^6.1.0 | Custom typography |
| `flutter_secure_storage` | ^9.0.0 | Secure token storage |
| `google_sign_in` | ^6.2.1 | Google authentication |
| `image_picker` | ^1.0.7 | Image selection |
| `permission_handler` | ^11.3.1 | Runtime permissions |
| `flutter_svg` | ^2.0.10 | SVG support |

---

## 📁 Project Structure

```
lib/
├── core/                          # Core functionality
│   ├── apis/                      # API client & endpoints
│   ├── config/                    # App configuration
│   ├── constants/                 # App constants (colors, strings, assets)
│   ├── di/                        # Dependency injection
│   ├── services/                  # Core services
│   ├── storage/                   # Storage services
│   ├── utils/                    # Utilities (responsive, text styles)
│   └── widgets/                   # Reusable widgets
│
├── features/                      # Feature modules
│   ├── auth/                      # Authentication
│   │   ├── data/                  # Data layer
│   │   ├── domain/                # Domain layer
│   │   └── presentation/          # Presentation layer
│   │
│   ├── package/                   # Package management
│   ├── care_plan/                 # Care plan details
│   ├── family_profile/            # Family profile management
│   ├── notification/              # Notifications
│   ├── home/                      # Home dashboard
│   └── ...
│
└── main.dart                      # Application entry point
```

### Feature Module Structure

Each feature follows a consistent structure:

```
feature_name/
├── data/
│   ├── datasources/              # Remote/Local data sources
│   ├── models/                   # Data models
│   └── repositories/             # Repository implementations
├── domain/
│   ├── entities/                 # Business entities
│   ├── repositories/              # Repository interfaces
│   └── usecases/                 # Business logic
└── presentation/
    ├── bloc/                     # BLoC (events, states, bloc)
    ├── screens/                  # Screen widgets
    └── widgets/                  # Feature widgets
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.9.2 or higher
- Dart SDK 3.9.2 or higher
- Android Studio / VS Code with Flutter extensions
- iOS development: Xcode (for macOS only)
- Git

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
   ```bash
   # Copy .env.example to .env (if exists)
   # Or create .env file with required variables
   # API_URL=https://your-api-url.com
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
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

---

## 📖 Development Guidelines

### Code Standards

This project follows strict coding standards. Please refer to [`.cursor/skills/project-rule/SKILL.md`](.cursor/skills/project-rule/SKILL.md) for detailed guidelines.

#### Key Principles

1. **Clean Architecture**: Strict separation of layers
2. **BLoC Pattern**: All state management via BLoC
3. **Constants First**: No hard-coded strings or colors
4. **Responsive Design**: All dimensions scaled with `AppResponsive`
5. **Null Safety**: Full null-safety compliance

### Naming Conventions

- **Files**: `snake_case.dart`
- **Classes**: `PascalCase`
- **Variables/Methods**: `camelCase`
- **Constants**: `camelCase` in classes (e.g., `AppColors.primary`)

### Adding a New Feature

1. Create feature directory structure:
   ```
   lib/features/new_feature/
   ├── data/
   ├── domain/
   └── presentation/
   ```

2. Implement layers in order:
   - Domain (entities, repository interface, use case)
   - Data (model, data source, repository implementation)
   - Presentation (BLoC, screens, widgets)

3. Register dependencies in `injection_container.dart`

4. Add API endpoints in `api_endpoints.dart`

5. Add constants in `app_strings.dart` and `app_colors.dart`

---

## 🔌 API Integration

### Base Configuration

The app uses Dio for HTTP requests with automatic token management:

- **Base URL**: Configured via `AppConfig.apiUrl`
- **Authentication**: Bearer token with auto-refresh
- **Error Handling**: Centralized error handling with user-friendly messages

### API Endpoints

All endpoints are centralized in `lib/core/apis/api_endpoints.dart`:

```dart
// Example
static const String packages = '/Packages';
static String getCarePlanDetailsByPackage(int packageId) => 
    '/care-plan-details/by-package/$packageId';
```

### Request/Response Flow

```
UI → BLoC → Use Case → Repository → Data Source → API
                ↓
UI ← BLoC ← Use Case ← Repository ← Data Source ← API
```

---

## 🎨 Design System

### Colors

- **Primary**: Orange (#FF8C00)
- **Background**: Light Beige (#FFFBF5)
- **Text Primary**: Black (#000000)
- **Text Secondary**: Gray (#99A1AF)

### Typography

- **Titles**: Tinos (Google Fonts)
- **Body**: Arimo (Google Fonts)

### Components

- **Border Radius**: 12-16px (scaled)
- **Padding**: 16-20px (scaled)
- **Shadows**: Subtle with alpha 0.03-0.05
- **Buttons**: Height 52px, border radius 16px

---

## 📱 Supported Platforms

- ✅ **Android** (API 21+)
- ✅ **iOS** (iOS 12.0+)
- ✅ **Web** (Chrome, Firefox, Safari, Edge)

---

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/features/auth/presentation/bloc/auth_bloc_test.dart
```

---

## 📝 Documentation

- **Architecture Guidelines**: [`.cursor/skills/project-rule/SKILL.md`](.cursor/skills/project-rule/SKILL.md)
- **API Documentation**: See `lib/core/apis/api_endpoints.dart`
- **Widget Documentation**: See `lib/core/widgets/app_widgets.dart`

---

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Follow the coding standards in `SKILL.md`
4. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
5. Push to the branch (`git push origin feature/AmazingFeature`)
6. Open a Pull Request

### Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

---

## 📄 License

This project is proprietary and confidential. All rights reserved.

---

## 👥 Team

**The Joyful Nest Development Team**

For questions or support, please contact the development team.

---

## 🔗 Related Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [BLoC Pattern](https://bloclibrary.dev/)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Dio HTTP Client](https://pub.dev/packages/dio)

---

<div align="center">

**Made with ❤️ by Postpartum Service Team**

</div>
