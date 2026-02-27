---
name: project-rule
description: Quy tắc và chuẩn coding cho dự án Postpartum Service
---

# Project Rules - Postpartum Service

## 1. Kiến trúc (Architecture)

### 1.1. Clean Architecture
- **Bắt buộc** tuân theo Clean Architecture với 3 layers:
  - **Domain Layer**: Entities, Repositories (interfaces), Use Cases
  - **Data Layer**: Models, Data Sources, Repository Implementations
  - **Presentation Layer**: BLoC, Screens, Widgets

### 1.2. Cấu trúc thư mục Feature
```
lib/features/{feature_name}/
├── data/
│   ├── datasources/        # Remote/Local data sources
│   ├── models/             # Data models (extends entities)
│   └── repositories/       # Repository implementations
├── domain/
│   ├── entities/           # Business entities
│   ├── repositories/       # Repository interfaces
│   └── usecases/          # Business logic use cases
└── presentation/
    ├── bloc/              # BLoC (events, states, bloc)
    ├── screens/           # Screen widgets
    └── widgets/          # Feature-specific widgets
```

## 2. State Management

### 2.1. BLoC Pattern
- **Bắt buộc** sử dụng BLoC pattern cho state management
- Mỗi feature có 3 files:
  - `{feature}_event.dart` - Events (extends Equatable)
  - `{feature}_state.dart` - States (extends Equatable)
  - `{feature}_bloc.dart` - BLoC implementation

### 2.2. BLoC Naming
- Event: `{Feature}LoadRequested`, `{Feature}Refresh`, etc.
- State: `{Feature}Initial`, `{Feature}Loading`, `{Feature}Loaded`, `{Feature}Error`

## 3. Dependency Injection

### 3.1. InjectionContainer
- Tất cả dependencies được quản lý trong `lib/core/di/injection_container.dart`
- Pattern: Data Sources → Repositories → Use Cases → BLoCs
- Sử dụng getter methods với prefix `_` cho private dependencies

### 3.2. BLoC Provider
- BLoC được provide ở screen level hoặc widget level
- Sử dụng `BlocProvider.value` khi navigate để share BLoC instance

## 4. Constants & Configuration

### 4.1. AppColors (`lib/core/constants/app_colors.dart`)
- **Bắt buộc** định nghĩa tất cả màu sắc trong AppColors
- Không hard-code màu trong widgets
- Pattern: `AppColors.{colorName}`
- Package colors: `packageVip`, `packagePro` cho các loại package

### 4.2. AppStrings (`lib/core/constants/app_strings.dart`)
- **Bắt buộc** định nghĩa tất cả strings trong AppStrings
- Không hard-code strings trong code
- Pattern: `AppStrings.{stringName}`
- Hỗ trợ đa ngôn ngữ (tiếng Việt và tiếng Anh)

### 4.3. AppTextStyles (`lib/core/utils/app_text_styles.dart`)
- Sử dụng Google Fonts: Tinos (titles) và Arimo (body)
- Methods: `AppTextStyles.tinos()`, `AppTextStyles.arimo()`
- Không hard-code font styles

### 4.4. AppResponsive (`lib/core/utils/app_responsive.dart`)
- **Bắt buộc** sử dụng `AppResponsive.scaleFactor(context)` cho responsive sizing
- Pattern: `value * scale` cho tất cả dimensions
- Breakpoints: Tablet (600px), Desktop (1024px)

## 5. API & Network

### 5.1. API Client
- Sử dụng Dio với `ApiClient.dio`
- Base URL từ `AppConfig.apiUrl`
- Tự động handle token refresh
- Error handling với DioException

### 5.2. API Endpoints
- Tất cả endpoints trong `lib/core/apis/api_endpoints.dart`
- Pattern: `static const String {endpointName} = '/path'`
- Dynamic paths: `static String {method}({params}) => '/path/$param'`

### 5.3. Data Sources
- Interface và Implementation pattern
- Constructor nhận Dio (optional, default: ApiClient.dio)
- Error handling: DioException → Exception với message rõ ràng

## 6. Models & Entities

### 6.1. Entities (Domain)
- Pure Dart classes, extends Equatable
- Không có dependencies với Flutter hoặc external packages
- Chỉ chứa business logic

### 6.2. Models (Data)
- Extends hoặc implements Entity
- Có `fromJson()`, `toJson()`, `toEntity()` methods
- Xử lý type casting và null safety

## 7. UI/UX Standards

### 7.1. Widgets
- Tách thành các widget nhỏ, reusable
- Feature-specific widgets trong `presentation/widgets/`
- Common widgets trong `lib/core/widgets/app_widgets.dart`

### 7.2. Design System
- Border radius: 12-16px (scaled)
- Padding: 16-20px (scaled)
- Shadows: subtle với alpha 0.03-0.05
- Colors: Primary (Orange #FF8C00), Background (Beige #FFFBF5)

### 7.3. Bottom Sheet
- Sử dụng `showModalBottomSheet` với `isScrollControlled: true`
- Height: 85% màn hình
- Có handle bar ở top
- Background transparent với rounded corners

### 7.4. Loading & Error States
- Loading: `CircularProgressIndicator` với `AppColors.primary`
- Error: Icon + message + retry button
- Empty: Icon + message

## 8. Code Style

### 8.1. Naming Conventions
- Files: `snake_case.dart`
- Classes: `PascalCase`
- Variables/Methods: `camelCase`
- Constants: `UPPER_SNAKE_CASE` hoặc `camelCase` trong classes

### 8.2. Private Members
- Private classes: `_{ClassName}`
- Private methods/variables: `_{name}`

### 8.3. Imports
- Group imports: Flutter → Packages → Core → Features
- Relative imports cho cùng feature
- Absolute imports cho cross-feature

## 9. Error Handling

### 9.1. Try-Catch
- Luôn wrap API calls trong try-catch
- Catch DioException riêng để handle network errors
- Generic catch cho unexpected errors

### 9.2. Error Messages
- User-friendly messages trong AppStrings
- Technical errors chỉ log, không hiển thị trực tiếp

## 10. Testing & Quality

### 10.1. Null Safety
- **Bắt buộc** null-safe code
- Sử dụng `?`, `!`, `??` appropriately
- Kiểm tra null trước khi access properties

### 10.2. Responsive
- Tất cả dimensions phải scale với `AppResponsive.scaleFactor()`
- Test trên nhiều screen sizes

## 11. Specific Patterns

### 11.1. Repository Pattern
```dart
// Domain
abstract class FeatureRepository {
  Future<List<Entity>> getData();
}

// Data
class FeatureRepositoryImpl implements FeatureRepository {
  final FeatureDataSource dataSource;
  // Implementation
}
```

### 11.2. Use Case Pattern
```dart
class GetFeatureUsecase {
  final FeatureRepository repository;
  Future<List<Entity>> call() async {
    return await repository.getData();
  }
}
```

### 11.3. BLoC Pattern
```dart
class FeatureBloc extends Bloc<FeatureEvent, FeatureState> {
  final GetFeatureUsecase usecase;
  // Event handlers
}
```

## 12. UI Components Standards

### 12.1. Cards
- Border radius: 12-16px
- Shadow: subtle với blur radius 8-12px
- Padding: 16-20px
- Border: optional với primary color alpha 0.1-0.3

### 12.2. Buttons
- Primary: Orange background, white text
- Secondary: White background, black border
- Height: 52px (default)
- Border radius: 16px

### 12.3. Text Inputs
- Height: 52px
- Border radius: 16px
- Focus border: Primary color, width 2px
- Error border: Red color

## 13. Carousel/Slides

### 13.1. Infinite Scroll
- Sử dụng PageView với large itemCount (length * 2000)
- Start ở middle (length * 1000)
- Auto-scroll với Timer.periodic
- Page indicators với AnimatedContainer

## 14. Timeline Components

### 14.1. Activity Timeline
- Dots: 12px circle với primary color
- Connecting lines: 2px với primary color alpha 0.3
- Cards: White background với shadow
- Time badges: Primary color background

## 15. File Organization

### 15.1. Feature Structure
- Mỗi feature độc lập, có thể reuse
- Shared code trong `lib/core/`
- Feature-specific code trong `lib/features/{feature}/`

### 15.2. Widget Organization
- StatelessWidget khi có thể
- StatefulWidget chỉ khi cần state management
- Extract complex widgets thành separate files

## 16. Best Practices

### 16.1. Code Reusability
- Tạo reusable widgets trong `app_widgets.dart`
- Sử dụng constants thay vì magic numbers
- Extract common logic thành utilities

### 16.2. Performance
- Sử dụng `const` constructors khi có thể
- Lazy loading cho lists
- Dispose controllers và timers

### 16.3. Maintainability
- Clear naming
- Comments cho complex logic
- Consistent code style
- Follow DRY principle

## 17. Vietnamese Language Support

### 17.1. Strings
- Tất cả user-facing strings bằng tiếng Việt
- Error messages: tiếng Việt
- Placeholders: tiếng Việt

### 17.2. Date/Time Format
- Vietnamese format: "ngày", "phút trước", "giờ trước"
- Currency: VND với format "X.XXX.XXX đ"

## 18. Git & Version Control

### 18.1. Commit Messages
- Clear và descriptive
- Reference issue numbers nếu có

---

**Lưu ý**: Tất cả các quy tắc trên phải được tuân thủ nghiêm ngặt để đảm bảo tính nhất quán và chất lượng code trong dự án.
