# TO-DO Staff Mobile (Cập nhật hoàn thiện)

## Trạng thái tổng quan
- **Tiến độ kỹ thuật:** 8/8 hạng mục đã triển khai code.
- **Tiến độ kiểm thử/bàn giao:** 0/3 hạng mục QA (mục 8) cần hoàn tất trước release chính thức.

---

## 1) Hợp đồng: HTML + hình ảnh chung 1 screen
**API:** `GET /api/Contract/{id}`

- [x] Đã dùng chung màn `staff_contract_screen.dart` cho:
  - xem nội dung hợp đồng (HTML)
  - xem ảnh hợp đồng đã ký (nếu có `fileUrl`)
- [x] Nút xem preview HTML hoạt động trong cùng flow quản lý hợp đồng.

**Kết luận:** Hoàn tất.

---

## 2) Xuất PDF trên mobile Flutter

- [x] Đã triển khai tải PDF về local (`documents directory`) và mở file ngoài app.
- [x] Nút `Xuất PDF` đang hoạt động trên màn hợp đồng dịch vụ.

**Kết luận:** Hoàn tất.

---

## 3) Rule nút Upload đã ký

- [x] Đã khóa theo đúng nghiệp vụ:
  - Chỉ cho upload khi hợp đồng đã **Gửi khách** (`status = sent`).
- [x] Nếu bấm khi chưa đủ điều kiện, hiển thị toast:
  - `Vui lòng bấm "Gửi khách" trước khi upload hợp đồng đã ký.`

**Kết luận:** Hoàn tất.

---

## 4) Bổ sung UI chỉnh sửa hợp đồng
**API:** `PUT /api/Contract/{id}/update-content`

Đã bổ sung đầy đủ các trường trên UI edit sheet:
- [x] `customerName`
- [x] `customerPhone`
- [x] `customerAddress`
- [x] `effectiveFrom`
- [x] `effectiveTo`
- [x] `checkinDate`
- [x] `checkoutDate`
- [x] `totalPrice`
- [x] `discountAmount`
- [x] `finalAmount`

**Kết luận:** Hoàn tất.

---

## 5) Staff Schedule + Menu Record (trạng thái test/gắn API)

### Staff Schedule
- [x] `GET /api/StaffSchedule/me?from={from}&to={to}` đã gắn ở:
  - `EmployeeScheduleScreenNew` (`employee_schedule_work.dart`)
  - `check_in_out_screen.dart`

### Menu Record by staff
- [x] `GET /api/MenuRecord/customer/{customerId}`
- [x] `GET /api/MenuRecord/customer/{customerId}/date?date={date}`
- [x] `GET /api/MenuRecord/customer/{customerId}/date-range?from={from}&to={to}`
- [x] `POST /api/MenuRecord/by-staff?customerId={customerId}`
- [x] `PUT /api/MenuRecord/by-staff?customerId={customerId}`
- [x] `DELETE /api/MenuRecord/by-staff/{id}?customerId={customerId}`

UI đã có đủ:
- [x] Filter tất cả / theo ngày / khoảng ngày
- [x] Thêm record
- [x] Sửa record
- [x] Xóa record

**Kết luận:** Hoàn tất.

---

## 6) UX giao dịch + tạo FamilySchedule từ giao dịch

### UX danh sách giao dịch
- [x] Việt hóa loại giao dịch:
  - `deposit` → `Đặt cọc`
  - `remaining` → `Thanh toán còn lại`
  - `full` → `Thanh toán toàn bộ`
- [x] Việt hóa trạng thái:
  - `pending` → `Chờ xử lý`
  - `paid` → `Đã thanh toán`
  - `failed` → `Thất bại`

### Flow khi click giao dịch cụ thể
- [x] Đã bổ sung nút: `Tạo lịch sinh hoạt từ giao dịch này`
- [x] Flow đã triển khai:
  1. Lấy `bookingId` + `customerId` từ transaction item.
  2. Gọi `GET /api/Booking/{id}` để lấy booking theo item đã chọn.
  3. Kiểm tra điều kiện đã thanh toán đủ (`remainingAmount <= 0`).
  4. Lấy `contractId` từ booking (hợp đồng gắn booking).
  5. Gọi `POST /api/FamilySchedule` với `{ customerId, contractId }`.

**Kết luận:** Hoàn tất.

---

## 7) Tình trạng chất lượng hiện tại

- [x] Đã rà lint các file chính:
  - `employee_customer_family_profiles_screen.dart`
  - `staff_contract_screen.dart`
  - `staff_transaction_list_screen.dart`
- [x] Hiện tại: **không có lỗi lint**.

**Kết luận:** Hoàn tất.

---

## 8) Checklist QA/UAT trước release (bắt buộc)

### 8.1 API error handling thực tế
- [ ] Test end-to-end trên thiết bị thật cho các case backend: `401 / 403 / 404 / 500`.
- [ ] Xác nhận toast/message hiển thị đúng ngữ cảnh cho từng case.

### 8.2 Manual test theo luồng nghiệp vụ
- [ ] Contract flow: gửi khách → upload signed → xem ảnh signed.
- [ ] MenuRecord flow: all/date/range + create/update/delete by-staff.
- [ ] Transaction flow: filter + tạo FamilySchedule từ transaction hợp lệ.

### 8.3 Bàn giao QA
- [ ] Chụp evidence màn hình theo từng flow chính.
- [ ] Ghi kết quả test (Pass/Fail, note lỗi nếu có).

**Kết luận:** Chưa hoàn tất (chờ QA/UAT).

---

## Chốt release
- **Code implementation:** ✅ Hoàn tất.
- **Sẵn sàng release production:** ⛔ Chưa (cần hoàn tất mục 8).

---

## 9) Danh sách trang Quick Menu đã đối chiếu và cập nhật

| Quick Menu label | Action/Route | Trạng thái mới | Đã làm |
|---|---|---|---|
| `Công việc` | `employeeTasks` | ✅ Đã gắn API | Route đã chuyển sang `TasksScreenNew` (dùng `AppointmentBloc`, lấy dữ liệu từ `LoadMyAssignedAppointments`). |
| `Suất ăn` | `employeeMealPlan` | ✅ Bỏ hard-code/mock chính | `EmployeeMealPlanScreen` đã bỏ danh sách `_families` hard-code, lấy danh sách khách từ `getMyAssignedAppointments`, cho chọn khách và điều hướng vào `EmployeeCustomerFamilyProfilesScreen` để thao tác tab Menu Record theo flow API staff. |
| `Phòng ở` | `employeeRooms` | ✅ Đã có screen UI + API | Tạo mới `EmployeeRoomsScreen`, dùng `RoomBloc` + `LoadAllRooms` để gọi API phòng; route `employeeRooms` đã map vào screen mới. |

### Chi tiết kỹ thuật vừa cập nhật
- `app_router.dart`
  - Import thêm `tasks_screen_new.dart`, `employee_rooms_screen.dart`.
  - `employeeTasks` -> `TasksScreenNew`.
  - `employeeRooms` -> `EmployeeRoomsScreen`.
- `employee_meal_plan_screen.dart`
  - Bỏ mock `_families`.
  - Dùng source customer từ appointments được phân công.
  - Điều hướng sang màn profile khách để staff xử lý Menu Record.
- `employee_rooms_screen.dart`
  - Màn mới hiển thị danh sách phòng, trạng thái phòng, loại phòng, tầng, active/inactive.

### Ghi chú
- Dòng `initialTabIndex` trước đó gây lỗi compile đã được loại bỏ để tương thích constructor hiện tại của `EmployeeCustomerFamilyProfilesScreen`.
- Các file đã chỉnh đã qua check lint: không phát hiện lỗi mới.