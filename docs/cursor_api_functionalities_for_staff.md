# API functionalities for staff
_Cập nhật lần cuối: 2/26/2026_

---

## Giới thiệu

Tài liệu này liệt kê tất cả các API endpoint mà role **Staff** có quyền sử dụng trong hệ thống Postpartum Care Service Platform.

## Cách hiểu phạm vi Staff (2 nhóm)

1. **Nhóm A – Explicit cho staff**: endpoint có role chứa `staff` (ví dụ `admin,manager,staff`, `AdminOrStaff`, `StaffRoleName`, `StaffOrCustomer`).
2. **Nhóm B – Authenticated**: endpoint chỉ `[Authorize]` (Staff đăng nhập cũng gọi được, nhưng có thể bị chặn thêm ở tầng service/nghiệp vụ).

---

## 1) API explicit cho Staff

### `AuthController`
- `POST /api/Auth/create-customer`  
  **Mô tả**: Staff/Admin/Manager tạo tài khoản customer.  
  **Authorization**: `[Authorize(Roles = "admin,manager,staff")]`

### `AccountController`
- `GET /api/Account/GetAll`  
  **Mô tả**: Lấy toàn bộ tài khoản trong hệ thống.  
  **Authorization**: `[Authorize(Roles = AppConstants.Role.AdminOrStaff)]` (admin,staff)

- `PATCH /api/Account/SetRole/{accountId}/role/{roleId}`  
  **Mô tả**: Gán role cho tài khoản.  
  **Authorization**: `[Authorize(Roles = AppConstants.Role.AdminOrStaff)]` (admin,staff)

- `PATCH /api/Account/SetAccountStatus/{accountId}`  
  **Mô tả**: Kích hoạt/vô hiệu hóa tài khoản.  
  **Authorization**: `[Authorize(Roles = AppConstants.Role.AdminOrStaff)]` (admin,staff)

### `BookingController`
- `GET /api/Booking/all`  
  **Mô tả**: Lấy tất cả booking trong hệ thống.  
  **Authorization**: `[Authorize(Roles = "admin,manager,staff")]`

- `POST /api/Booking/create-for-customer`  
  **Mô tả**: Staff tạo booking cho khách tại trung tâm.  
  **Authorization**: `[Authorize(Roles = "admin,manager,staff")]`

- `PUT /api/Booking/{id}/confirm`  
  **Mô tả**: Xác nhận booking.  
  **Authorization**: `[Authorize(Roles = "admin,manager,staff")]`

- `PUT /api/Booking/{id}/complete`  
  **Mô tả**: Hoàn thành booking.  
  **Authorization**: `[Authorize(Roles = "admin,manager,staff")]`

### `AppointmentController`
- `GET /api/Appointment/my-assigned`  
  **Mô tả**: Lấy lịch hẹn được phân công cho staff hiện tại.  
  **Authorization**: `[Authorize(Roles = "admin,manager,staff")]`

- `GET /api/Appointment/all`  
  **Mô tả**: Lấy tất cả lịch hẹn trong hệ thống.  
  **Authorization**: `[Authorize(Roles = "admin,manager,staff")]`

- `PUT /api/Appointment/{id}/complete`  
  **Mô tả**: Đánh dấu hoàn thành lịch hẹn.  
  **Authorization**: `[Authorize(Roles = "admin,manager,staff")]`

- `PUT /api/Appointment/{id}/confirm`  
  **Mô tả**: Xác nhận lịch hẹn.  
  **Authorization**: `[Authorize(Roles = "admin,manager,staff")]`

- `POST /api/Appointment/create-for-customer`  
  **Mô tả**: Staff tạo lịch hẹn cho customer.  
  **Authorization**: `[Authorize(Roles = "admin,manager,staff")]`

### `ContractController`
- `GET /api/Contract/all`  
  **Mô tả**: Lấy tất cả hợp đồng trong hệ thống.  
  **Authorization**: `[Authorize(Roles = "admin,manager,staff")]`

- `GET /api/Contract/{id}`  
  **Mô tả**: Lấy chi tiết hợp đồng theo ID.  
  **Authorization**: `[Authorize(Roles = "admin,manager,staff")]`

- `GET /api/Contract/preview/{bookingId}`  
  **Mô tả**: Preview hợp đồng từ booking.  
  **Authorization**: `[Authorize(Roles = "admin,manager,staff")]`

- `GET /api/Contract/{id}/export-pdf`  
  **Mô tả**: Xuất hợp đồng ra PDF.  
  **Authorization**: `[Authorize(Roles = "admin,manager,staff")]`

- `POST /api/Contract`  
  **Mô tả**: Tạo hợp đồng cho booking.  
  **Authorization**: `[Authorize(Roles = "admin,manager,staff")]`

- `POST /api/Contract/from-booking/{bookingId}`  
  **Mô tả**: Tạo hợp đồng tự động từ booking.  
  **Authorization**: `[Authorize(Roles = "admin,manager,staff")]`

- `PUT /api/Contract/{id}/send`  
  **Mô tả**: Gửi hợp đồng cho khách xem.  
  **Authorization**: `[Authorize(Roles = "admin,manager,staff")]`

- `PUT /api/Contract/{id}/upload-signed`  
  **Mô tả**: Upload hợp đồng đã ký.  
  **Authorization**: `[Authorize(Roles = "admin,manager,staff")]`

- `PUT /api/Contract/{id}/update-content`  
  **Mô tả**: Cập nhật nội dung hợp đồng.  
  **Authorization**: `[Authorize(Roles = "admin,manager,staff")]`

- `GET /api/Contract/no-schedule`  
  **Mô tả**: Lấy các hợp đồng chưa được lên lịch.  
  **Authorization**: `[Authorize(Roles = "admin,manager,staff")]`

### `TransactionController`
- `GET /api/Transaction/all`  
  **Mô tả**: Lấy toàn bộ giao dịch trong hệ thống.  
  **Authorization**: `[Authorize(Roles = "admin,manager,staff")]`

- `POST /api/Transaction/payment`  
  **Mô tả**: Staff ghi nhận thanh toán thủ công cho khách.  
  **Authorization**: `[Authorize(Roles = "admin,manager,staff")]`

### `NotificationController`
- `POST /api/Notification`  
  **Mô tả**: Tạo thông báo mới.  
  **Authorization**: `[Authorize(Roles = AppConstants.Role.AdminOrStaff)]` (admin,staff)

- `GET /api/Notification`  
  **Mô tả**: Lấy toàn bộ thông báo trong hệ thống.  
  **Authorization**: `[Authorize(Roles = AppConstants.Role.AdminOrStaff)]` (admin,staff)

- `PUT /api/Notification/{id}`  
  **Mô tả**: Cập nhật thông báo.  
  **Authorization**: `[Authorize(Roles = AppConstants.Role.AdminOrStaff)]` (admin,staff)

### `FamilyProfileController`
- `GET /api/FamilyProfile/GetAll`  
  **Mô tả**: Lấy danh sách tất cả hồ sơ gia đình.  
  **Authorization**: `[Authorize(Roles = AppConstants.Role.AdminOrStaff)]` (admin,staff)

- `GET /api/FamilyProfile/GetById/{id}`  
  **Mô tả**: Lấy hồ sơ gia đình theo ID.  
  **Authorization**: `[Authorize(Roles = AppConstants.Role.AdminOrStaff)]` (admin,staff)

- `GET /api/FamilyProfile/GetByCustomerId/{customerId}`  
  **Mô tả**: Lấy danh sách hồ sơ gia đình theo CustomerId.  
  **Authorization**: `[Authorize(Roles = AppConstants.Role.AdminOrStaff)]` (admin,staff)

### `StaffScheduleController` (các endpoint dành trực tiếp cho staff)
- `GET /api/StaffSchedule/me`  
  **Mô tả**: Xem lịch làm việc của chính staff (với query params: from, to).  
  **Authorization**: `[Authorize(Roles = AppConstants.Role.StaffRoleName)]` (staff)

- `PATCH /api/StaffSchedule/check`  
  **Mô tả**: Check/chấm trạng thái lịch làm việc (check-in/check-out).  
  **Authorization**: `[Authorize(Roles = AppConstants.Role.StaffRoleName)]` (staff)

- `PATCH /api/StaffSchedule/swap-schedule`  
  **Mô tả**: Tạo yêu cầu đổi lịch làm việc với nhân viên khác.  
  **Authorization**: `[Authorize(Roles = AppConstants.Role.StaffRoleName)]` (staff)

- `GET /api/StaffSchedule/my-swap-requests`  
  **Mô tả**: Xem yêu cầu đổi lịch đã gửi.  
  **Authorization**: `[Authorize(Roles = AppConstants.Role.StaffRoleName)]` (staff)

- `GET /api/StaffSchedule/my-incoming-swap-requests`  
  **Mô tả**: Xem yêu cầu đổi lịch đến (cần phản hồi).  
  **Authorization**: `[Authorize(Roles = AppConstants.Role.StaffRoleName)]` (staff)

- `PATCH /api/StaffSchedule/respond-swap-request/{requestId}/{respond}`  
  **Mô tả**: Phản hồi yêu cầu đổi lịch (true = đồng ý, false = từ chối).  
  **Authorization**: `[Authorize(Roles = AppConstants.Role.StaffRoleName)]` (staff)

### `ChatController`
- `GET /api/Chat/conversations/all`  
  **Mô tả**: Xem tất cả conversation trong hệ thống.  
  **Authorization**: `[Authorize(Roles = "admin,manager,staff")]`

- `GET /api/Chat/support-requests`  
  **Mô tả**: Lấy các yêu cầu hỗ trợ đang chờ xử lý.  
  **Authorization**: `[Authorize(Roles = "admin,manager,staff")]`

- `GET /api/Chat/support-requests/my`  
  **Mô tả**: Lấy yêu cầu hỗ trợ mà staff đang xử lý.  
  **Authorization**: `[Authorize(Roles = "admin,manager,staff")]`

- `PUT /api/Chat/support-requests/{id}/accept`  
  **Mô tả**: Staff nhận yêu cầu hỗ trợ.  
  **Authorization**: `[Authorize(Roles = "admin,manager,staff")]`

- `PUT /api/Chat/support-requests/{id}/resolve`  
  **Mô tả**: Staff đánh dấu đã giải quyết yêu cầu hỗ trợ.  
  **Authorization**: `[Authorize(Roles = "admin,manager,staff")]`

- `POST /api/Chat/conversations/{id}/staff-message`  
  **Mô tả**: Staff nhắn tin trong cuộc hội thoại.  
  **Authorization**: `[Authorize(Roles = "admin,manager,staff")]`

### `AmenityTicketController`
- `POST /api/AmenityTicket/staff-create`  
  **Mô tả**: Staff tạo ticket tiện ích cho khách hàng.  
  **Authorization**: `[Authorize(Roles = AppConstants.Role.StaffRoleName)]` (staff)

- `PUT /api/AmenityTicket/{id}`  
  **Mô tả**: Staff/Customer cập nhật ticket tiện ích.  
  **Authorization**: `[Authorize(Roles = AppConstants.Role.StaffOrCustomer)]` (staff,customer)

- `PATCH /api/AmenityTicket/cancel/{id}`  
  **Mô tả**: Staff/Customer hủy ticket tiện ích.  
  **Authorization**: `[Authorize(Roles = AppConstants.Role.StaffOrCustomer)]` (staff,customer)

### `MemberTypesController`
- `GET /api/member-types/{id}`  
  **Mô tả**: Staff xem chi tiết loại thành viên.  
  **Authorization**: `[Authorize(Roles = "admin,manager,staff")]`

---

## 2) API `[Authorize]` mà Staff cũng gọi được (tuỳ nghiệp vụ service)

Các endpoint này chỉ yêu cầu `[Authorize]` (không chỉ định role cụ thể), nên Staff đăng nhập cũng có thể gọi được. Tuy nhiên, logic nghiệp vụ ở tầng service có thể giới hạn quyền truy cập dữ liệu.

### `AuthController`
- `POST /api/Auth/change-password`  
  **Mô tả**: Đổi mật khẩu (yêu cầu đăng nhập).  
  **Authorization**: `[Authorize]`

### `AccountController`
- `GET /api/Account/GetById/{id}`  
  **Mô tả**: Lấy chi tiết tài khoản theo ID.  
  **Authorization**: `[Authorize]`

- `GET /api/Account/GetByEmail/{email}`  
  **Mô tả**: Lấy tài khoản theo email.  
  **Authorization**: `[Authorize]`

- `GET /api/Account/GetByPhone/{phone}`  
  **Mô tả**: Lấy tài khoản theo số điện thoại.  
  **Authorization**: `[Authorize]`

- `GET /api/Account/GetCurrentAccount`  
  **Mô tả**: Lấy thông tin tài khoản hiện tại (kèm thông tin gói dịch vụ nếu có).  
  **Authorization**: `[Authorize]`

### `BookingController`
- `GET /api/Booking`  
  **Mô tả**: Lấy danh sách booking của customer đang đăng nhập.  
  **Authorization**: `[Authorize]` (Staff có thể gọi nhưng sẽ trả về booking của chính họ nếu họ là customer)

- `GET /api/Booking/{id}`  
  **Mô tả**: Lấy chi tiết booking (Customer xem của mình, Staff/Manager/Admin xem tất cả).  
  **Authorization**: `[Authorize]`

- `POST /api/Booking`  
  **Mô tả**: Customer tạo booking online.  
  **Authorization**: `[Authorize]`

- `PUT /api/Booking/{id}/cancel`  
  **Mô tả**: Hủy booking.  
  **Authorization**: `[Authorize]`

### `AppointmentController`
- `GET /api/Appointment`  
  **Mô tả**: Lấy danh sách lịch hẹn của customer đang đăng nhập.  
  **Authorization**: `[Authorize]`

- `GET /api/Appointment/{id}`  
  **Mô tả**: Lấy chi tiết lịch hẹn (Customer xem của mình, Staff/Manager/Admin xem tất cả).  
  **Authorization**: `[Authorize]`

- `POST /api/Appointment`  
  **Mô tả**: Đặt lịch thăm quan.  
  **Authorization**: `[Authorize]`

- `PUT /api/Appointment/{id}`  
  **Mô tả**: Cập nhật lịch hẹn.  
  **Authorization**: `[Authorize]`

- `PUT /api/Appointment/{id}/cancel`  
  **Mô tả**: Hủy lịch hẹn.  
  **Authorization**: `[Authorize]`

- `PUT /api/Appointment/{id}/customer-confirm`  
  **Mô tả**: Khách hàng xác nhận lịch hẹn (do AI tạo).  
  **Authorization**: `[Authorize]`

### `ContractController`
- `GET /api/Contract/my/{bookingId}`  
  **Mô tả**: Khách xem hợp đồng của booking.  
  **Authorization**: `[Authorize]`

### `TransactionController`
- `GET /api/Transaction`  
  **Mô tả**: Lấy giao dịch của customer đang đăng nhập.  
  **Authorization**: `[Authorize]`

- `GET /api/Transaction/{id}`  
  **Mô tả**: Lấy chi tiết giao dịch theo ID (Staff/Admin xem tất cả, Customer xem của mình).  
  **Authorization**: `[Authorize]`

- `POST /api/Transaction/deposit`  
  **Mô tả**: Khách đặt cọc online.  
  **Authorization**: `[Authorize]`

- `POST /api/Transaction/create-payment-link`  
  **Mô tả**: Tạo payment link PayOS.  
  **Authorization**: `[Authorize]`

- `POST /api/Transaction/create-home-service-payment-link`  
  **Mô tả**: Tạo payment link PayOS cho dịch vụ tại nhà.  
  **Authorization**: `[Authorize]`

- `GET /api/Transaction/check-status/{orderCode}`  
  **Mô tả**: Kiểm tra trạng thái thanh toán.  
  **Authorization**: `[AllowAnonymous]` (Không cần đăng nhập)

### `NotificationController`
- `GET /api/Notification/me`  
  **Mô tả**: Lấy thông báo cho người dùng hiện tại.  
  **Authorization**: `[Authorize]`

- `GET /api/Notification/{id}`  
  **Mô tả**: Lấy thông báo theo ID.  
  **Authorization**: `[Authorize]`

- `PUT /api/Notification/mark-as-read/{id}`  
  **Mô tả**: Đánh dấu thông báo là đã đọc.  
  **Authorization**: `[Authorize]`

### `FamilyProfileController`
- `POST /api/FamilyProfile/Create`  
  **Mô tả**: Tạo hồ sơ gia đình + upload avatar (nếu có).  
  **Authorization**: `[Authorize]`

- `GET /api/FamilyProfile/GetMyFamilyProfiles`  
  **Mô tả**: Lấy danh sách hồ sơ gia đình của chính mình (phía Customer).  
  **Authorization**: `[Authorize]`

- `PUT /api/FamilyProfile/Update/{id}`  
  **Mô tả**: Update hồ sơ gia đình.  
  **Authorization**: `[Authorize]`

- `DELETE /api/FamilyProfile/Delete/{id}`  
  **Mô tả**: Xóa hồ sơ gia đình (soft delete).  
  **Authorization**: `[Authorize]`

- `PATCH /api/FamilyProfile/Restore/{id}`  
  **Mô tả**: Restore hồ sơ gia đình đã xóa.  
  **Authorization**: `[Authorize]`

### `ChatController`
- `GET /api/Chat/conversations`  
  **Mô tả**: Lấy danh sách cuộc hội thoại của user.  
  **Authorization**: `[Authorize]`

- `GET /api/Chat/conversations/{id}`  
  **Mô tả**: Lấy chi tiết cuộc hội thoại với messages.  
  **Authorization**: `[Authorize]`

- `POST /api/Chat/conversations`  
  **Mô tả**: Tạo cuộc hội thoại mới.  
  **Authorization**: `[Authorize]`

- `POST /api/Chat/conversations/{id}/messages`  
  **Mô tả**: Gửi tin nhắn và nhận phản hồi từ AI.  
  **Authorization**: `[Authorize]`

- `POST /api/Chat/conversations/{id}/messages/stream`  
  **Mô tả**: Gửi tin nhắn và stream phản hồi AI (SSE).  
  **Authorization**: `[Authorize]`

- `PUT /api/Chat/conversations/{id}/messages/read`  
  **Mô tả**: Đánh dấu tất cả messages trong conversation là đã đọc.  
  **Authorization**: `[Authorize]`

- `POST /api/Chat/conversations/{id}/request-support`  
  **Mô tả**: Khách hàng yêu cầu hỗ trợ từ nhân viên.  
  **Authorization**: `[Authorize]`

### `AmenityTicketController`
- `POST /api/AmenityTicket`  
  **Mô tả**: Tạo vé tiện ích mới.  
  **Authorization**: `[Authorize]`

- `GET /api/AmenityTicket/{id}`  
  **Mô tả**: Lấy vé tiện ích theo ID.  
  **Authorization**: `[Authorize]`

### `RoomController`
- `GET /api/Room/empty`  
  **Mô tả**: Lấy danh sách phòng trống.  
  **Authorization**: `[Authorize]`

### `MenuRecordController`
- `GET /api/MenuRecord/{id}`  
  **Mô tả**: Lấy MenuRecord theo ID.  
  **Authorization**: `[Authorize]`

### `MemberTypesController`
- `GET /api/member-types`  
  **Mô tả**: Lấy danh sách loại thành viên (Admin, Manager, Staff).  
  **Authorization**: `[Authorize]`

### `HomeBookingController`
- `GET /api/HomeBooking/home-staff`  
  **Mô tả**: Lấy danh sách tất cả nhân viên phục vụ tại nhà (Home Staff).  
  **Authorization**: `[AllowAnonymous]` (Không cần đăng nhập)

- `GET /api/HomeBooking/free-home-staff`  
  **Mô tả**: Lấy danh sách nhân viên phục vụ tại nhà có thời gian rảnh trong khoảng thời gian cụ thể.  
  **Authorization**: `[AllowAnonymous]` (Không cần đăng nhập)

---

## 3) Ghi chú về Authorization

### Các role constants được sử dụng:
- `AppConstants.Role.AdminOrStaff` = `"admin,staff"`
- `AppConstants.Role.StaffRoleName` = `"staff"`
- `AppConstants.Role.StaffOrCustomer` = `"staff,customer"`
- `AppConstants.Role.DefaultRoleName` = `"customer"`
- `"admin,manager,staff"` = String literal

### Lưu ý:
- Các endpoint có `[Authorize]` không chỉ định role cụ thể sẽ cho phép bất kỳ user đã đăng nhập nào truy cập, nhưng logic nghiệp vụ ở service layer có thể giới hạn quyền truy cập dữ liệu dựa trên role.
- Một số endpoint có thể có logic kiểm tra bổ sung ở service layer để đảm bảo staff chỉ truy cập được dữ liệu phù hợp với quyền của họ.

---

## 4) Tổng kết

**Tổng số API explicit cho Staff**: ~50+ endpoints  
**Tổng số API [Authorize] mà Staff có thể dùng**: ~30+ endpoints

Tài liệu này được cập nhật dựa trên codebase thực tế từ các Controller files trong `WebAPI/Controllers`.