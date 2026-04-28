# Kế Hoạch Triển Khai Tính Năng Ghi Chú Sức Khỏe & Chăm Sóc Cho Nhân Viên (Staff Health & Care)

Tiến trình thực hiện dựa trên tài liệu `staff_api_spec.md`:

## Các Bước Triển Khai
- [x] **Bước 1: Bổ sung API Endpoints**
  - Cập nhật `lib/core/apis/api_endpoints.dart` thêm các route cho HealthRecord, ActivityCondition.
- [x] **Bước 2: Xây dựng Domain & Data Layer cho HealthRecord và Activity Restriction**
  - [x] Tạo Entities và Models dựa trên JSON từ spec.
  - [x] Cập nhật `HealthRecordRepository` và `HealthRecordRemoteDataSource`.
  - [x] Bổ sung logic lấy danh sách `HealthCondition`.
  - [x] Bổ sung logic `CheckRestriction` và `BatchCheckRestrictions`.
- [x] **Bước 3: Tích hợp vào Workflow của Nhân Viên**
  - [x] Cập nhật `HealthRecordBloc` xử lý các sự kiện mới.
  - [x] Đăng ký DI trong `InjectionContainer`.
- [ ] **Bước 4: Thiết kế Giao Diện (UI)**
  - [x] Tạo màn hình `StaffHealthCareFlowScreen` (Form ghi nhận sức khỏe).
  - [x] Tích hợp nút "Ghi nhận sức khỏe" vào hồ sơ gia đình khách hàng.
  - [ ] Tích hợp kiểm tra chống chỉ định (Activity Restriction) vào flow.

## Hướng Dẫn Kiểm Tra Giao Diện (Cách Vô Check UI)

### Cách 1: Qua Hồ sơ gia đình (Khuyên dùng để test đầy đủ tính năng)
1. Đăng nhập vào Portal Nhân viên.
2. Truy cập vào mục **"Gia đình được phân công"** (Assigned Families).
3. Chọn một gia đình bất kỳ -> Chọn **"Mở hồ sơ gia đình"** (Nút nằm ở trên cùng của Timeline).
4. Tại tab **"Gia đình"**, bạn sẽ thấy danh sách các thành viên.
5. Mỗi thành viên sẽ có nút **"Ghi nhận sức khỏe"**.
6. Nhấn vào nút đó để mở form:
   - Hệ thống sẽ tự động tải dữ liệu sức khỏe mới nhất của thành viên đó (nếu có).
   - Bạn có thể nhập: Cân nặng, Nhiệt độ, Tình trạng chung.
   - Chọn các **Tình trạng bệnh lý** từ danh sách (được load từ API).
   - Nhập ghi chú thêm và nhấn **"Lưu bản ghi"**.

### Cách 2: Qua Danh sách công việc (Tasks)
1. Tại màn hình chính của nhân viên, chọn tab **"Công việc"** (Tasks).
2. Tìm một lịch hẹn đang ở trạng thái **"Đang thực hiện"** (Scheduled - Màu xanh dương).
3. Bạn sẽ thấy nút **"Sức khỏe"** (Màu cam) bên cạnh nút "Hoàn thành".
4. Hiện tại nút này sẽ hướng dẫn bạn vào Hồ sơ gia đình để chọn đúng thành viên cần ghi nhận (vì một lịch hẹn có thể liên quan đến cả mẹ và bé).

---
**Lưu ý kỹ thuật:** 
- Các thông số như Cân nặng, Nhiệt độ sẽ được lưu vào hệ thống và hiển thị lại cho nhân viên khác hoặc chính bạn ở lần chăm sóc tiếp theo.
- Tính năng **Activity Restriction** (Chống chỉ định) đang được tích hợp sâu hơn vào luồng xác nhận hoàn tất công việc để cảnh báo nhân viên nếu sức khỏe của khách hàng không phù hợp với hoạt động đó.

