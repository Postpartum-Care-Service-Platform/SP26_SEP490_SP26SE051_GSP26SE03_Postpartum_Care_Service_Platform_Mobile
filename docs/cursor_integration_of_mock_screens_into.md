# Integration of mock screens into routing
_Exported on 2/26/2026 at 06:11:15 GMT+7 from Cursor (2.3.34)_

---

**User**

2) Nhóm màn có trong thư mục nhưng thiên về mock/legacy/chưa gắn route chính
employee_schedule_screen.dart
Bản lịch làm việc cũ (dữ liệu hardcode/mock).
tasks_screen.dart
Bản công việc cũ (mock).
check_in_out_screen.dart
Màn check-in/check-out ca làm.
Đang dùng state cục bộ, dữ liệu mẫu, chưa thấy tích hợp API thật (có ghi chú upload ảnh là placeholder).
requests_screen.dart
Màn quản lý yêu cầu (nghỉ phép/đổi ca), có tab pending/approved/rejected.
Hiện là mock data + form tạo yêu cầu giả lập.
employee_service_booking_screen.dart
Bản UI đặt dịch vụ kiểu cũ/mẫu (services + my bookings + booking form mock).
Luồng hiện tại đang dùng service_booking_screen.dart thay vì màn này.

Vậy bạn triển khai nhóm 2 cái nào chưa gắn vô route thì gắn giúp tôi tương ứng với menu trong @postpartum_service_mobile/lib/features/employee/presentation/widgets/employee_quick_menu.dart 

---

**Cursor**

[Mode: Execution] Preliminary analysis shows the request best fits the Execution stage. The protocol starts in Execution mode.

Mình đã gắn route cho nhóm màn “mock/legacy/chưa gắn route chính” và nối vào menu nhanh trong `employee_quick_menu.dart` như bạn yêu cầu.

Đã làm xong:

- Thêm action mới trong quick menu:
  - `legacySchedule`
  - `tasks`
  - `checkInOut`
  - `legacyServiceBooking`
- Thêm item tương ứng trong `EmployeeQuickMenuPresets.allItems()`:
  - `Lịch cũ`
  - `Công việc`
  - `Check-in/out`
  - `Đặt DV cũ`
- Gắn điều hướng trong `employee_schedule_screen_new.dart`:
  - `legacySchedule` -> `AppRoutes.employeeSchedule`
  - `tasks` -> `AppRoutes.employeeTasks`
  - `checkInOut` -> `AppRoutes.employeeCheckInOut`
  - `legacyServiceBooking` -> `AppRoutes.employeeServiceBooking`
- Bổ sung route thật trong `app_router.dart` cho các màn legacy:
  - `employee_schedule_screen.dart`
  - `tasks_screen.dart`
  - `check_in_out_screen.dart`
  - `requests_screen.dart`
  - `employee_service_booking_screen.dart`
- Đã import đầy đủ các screen legacy vào `app_router.dart`.

Các điểm thay đổi chính:

```15:25:postpartum_service_mobile/lib/features/employee/presentation/widgets/employee_quick_menu.dart
enum EmployeeQuickMenuExtraAction {
  amenityService,
  amenityTicket,
  room,
  mealPlan,
  requests,
  legacySchedule,
  tasks,
  checkInOut,
  legacyServiceBooking,
  staffProfile,
  familyProfile,
}
```

```521:548:postpartum_service_mobile/lib/features/employee/presentation/widgets/employee_quick_menu.dart
      EmployeeQuickMenuItem.extra(
        id: 'legacy_schedule',
        label: 'Lịch cũ',
        iconAsset: AppAssets.calendar,
        action: EmployeeQuickMenuExtraAction.legacySchedule,
      ),
      EmployeeQuickMenuItem.extra(
        id: 'tasks',
        label: 'Công việc',
        iconAsset: AppAssets.menuFirst,
        action: EmployeeQuickMenuExtraAction.tasks,
      ),
      EmployeeQuickMenuItem.extra(
        id: 'check_in_out',
        label: 'Check-in/out',
        iconAsset: AppAssets.calendarBold,
        action: EmployeeQuickMenuExtraAction.checkInOut,
      ),
      EmployeeQuickMenuItem.extra(
        id: 'legacy_service_booking',
        label: 'Đặt DV cũ',
        iconAsset: AppAssets.serviceAmenity,
        action: EmployeeQuickMenuExtraAction.legacyServiceBooking,
      ),
```

```257:275:postpartum_service_mobile/lib/features/employee/presentation/screens/employee_schedule_screen_new.dart
                case EmployeeQuickMenuExtraAction.legacySchedule:
                  // Điều hướng tới màn lịch làm việc cũ (mock/legacy).
                  AppRouter.push(context, AppRoutes.employeeSchedule);
                  break;

                case EmployeeQuickMenuExtraAction.tasks:
                  // Điều hướng tới màn công việc cũ (mock/legacy).
                  AppRouter.push(context, AppRoutes.employeeTasks);
                  break;

                case EmployeeQuickMenuExtraAction.checkInOut:
                  // Điều hướng tới màn check-in/check-out ca làm.
                  AppRouter.push(context, AppRoutes.employeeCheckInOut);
                  break;

                case EmployeeQuickMenuExtraAction.legacyServiceBooking:
                  // Điều hướng tới màn đặt dịch vụ cũ (mock/legacy).
                  AppRouter.push(context, AppRoutes.employeeServiceBooking);
                  break;
```

```265:287:postpartum_service_mobile/lib/core/routing/app_router.dart
      case AppRoutes.employeeSchedule:
        return MaterialPageRoute(
          builder: (_) => const EmployeeScheduleScreen(),
        );

      case AppRoutes.employeeTasks:
        return MaterialPageRoute(
          builder: (_) => const TasksScreen(),
        );

      case AppRoutes.employeeCheckInOut:
        return MaterialPageRoute(
          builder: (_) => const CheckInOutScreen(),
        );

      case AppRoutes.employeeRequests:
        return MaterialPageRoute(
          builder: (_) => const RequestsScreen(),
        );

      case AppRoutes.employeeServiceBooking:
        return MaterialPageRoute(
          builder: (_) => const EmployeeServiceBookingScreen(),
        );
```

Mình cũng đã kiểm tra lint cho các file đã sửa, không thấy lỗi mới.

Nếu bạn muốn, mình có thể làm luôn bước tiếp theo: sắp xếp lại thứ tự item quick menu cho đúng ưu tiên nghiệp vụ (ví dụ đẩy 4 màn legacy xuống cuối cùng) để UX rõ ràng hơn.

```dart
enum EmployeeQuickMenuExtraAction {
  amenityService,
  amenityTicket,
  room,
  mealPlan,
  requests,
  legacySchedule,
  tasks,
  checkInOut,
  legacyServiceBooking,
  staffProfile,
  familyProfile,
}
```

```dart
      EmployeeQuickMenuItem.extra(
        id: 'legacy_schedule',
        label: 'Lịch cũ',
        iconAsset: AppAssets.calendar,
        action: EmployeeQuickMenuExtraAction.legacySchedule,
      ),
      EmployeeQuickMenuItem.extra(
        id: 'tasks',
        label: 'Công việc',
        iconAsset: AppAssets.menuFirst,
        action: EmployeeQuickMenuExtraAction.tasks,
      ),
      EmployeeQuickMenuItem.extra(
        id: 'check_in_out',
        label: 'Check-in/out',
        iconAsset: AppAssets.calendarBold,
        action: EmployeeQuickMenuExtraAction.checkInOut,
      ),
      EmployeeQuickMenuItem.extra(
        id: 'legacy_service_booking',
        label: 'Đặt DV cũ',
        iconAsset: AppAssets.serviceAmenity,
        action: EmployeeQuickMenuExtraAction.legacyServiceBooking,
      ),
```

```dart
                case EmployeeQuickMenuExtraAction.legacySchedule:
                  // Điều hướng tới màn lịch làm việc cũ (mock/legacy).
                  AppRouter.push(context, AppRoutes.employeeSchedule);
                  break;

                case EmployeeQuickMenuExtraAction.tasks:
                  // Điều hướng tới màn công việc cũ (mock/legacy).
                  AppRouter.push(context, AppRoutes.employeeTasks);
                  break;

                case EmployeeQuickMenuExtraAction.checkInOut:
                  // Điều hướng tới màn check-in/check-out ca làm.
                  AppRouter.push(context, AppRoutes.employeeCheckInOut);
                  break;

                case EmployeeQuickMenuExtraAction.legacyServiceBooking:
                  // Điều hướng tới màn đặt dịch vụ cũ (mock/legacy).
                  AppRouter.push(context, AppRoutes.employeeServiceBooking);
                  break;
```

```dart
      case AppRoutes.employeeSchedule:
        return MaterialPageRoute(
          builder: (_) => const EmployeeScheduleScreen(),
        );

      case AppRoutes.employeeTasks:
        return MaterialPageRoute(
          builder: (_) => const TasksScreen(),
        );

      case AppRoutes.employeeCheckInOut:
        return MaterialPageRoute(
          builder: (_) => const CheckInOutScreen(),
        );

      case AppRoutes.employeeRequests:
        return MaterialPageRoute(
          builder: (_) => const RequestsScreen(),
        );

      case AppRoutes.employeeServiceBooking:
        return MaterialPageRoute(
          builder: (_) => const EmployeeServiceBookingScreen(),
        );
```

---

**User**

ok triển khai.
Rồi có cái những màn nào sài mock data hay hard code liệt kê

