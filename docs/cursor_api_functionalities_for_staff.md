# API functionalities for staff
_Exported on 2/26/2026 at 05:43:34 GMT+7 from Cursor (2.3.34)_

---

**User**

@SP26_SEP490_SP26SE051_GSP26SE03_Postpartum_Care_Service_Platform/WebAPI/Middlewares @SP26_SEP490_SP26SE051_GSP26SE03_Postpartum_Care_Service_Platform/WebAPI/Controllers 
Bạn hãy liệt kê ra những API chức năng nào à staff có thể sử dụng và mô tả sơ lược chức năng đó

---

**Cursor**

Mình sẽ rà `DOCS/` trước rồi quét các controller/middleware để tổng hợp chính xác các API mà role `Staff` dùng được, kèm mô tả ngắn gọn.

[Mode: Intelligent]  
Preliminary analysis shows the request best fits the Intelligent stage. The protocol starts in Intelligent mode.

Mình đã rà trong `WebAPI/Controllers` và `WebAPI/Middlewares`.  
Kết luận nhanh: **`Middlewares` không có API endpoint cho Staff** (chỉ có middleware xử lý exception).  
Các API Staff có thể dùng nằm ở `Controllers` như sau.

## Cách hiểu phạm vi Staff (2 nhóm)
1. **Nhóm A – Explicit cho staff**: endpoint có role chứa `staff` (ví dụ `admin,manager,staff`, `AdminOrStaff`, `StaffRoleName`, `StaffOrCustomer`).
2. **Nhóm B – Authenticated**: endpoint chỉ `[Authorize]` (Staff đăng nhập cũng gọi được, nhưng có thể bị chặn thêm ở tầng service/nghiệp vụ).

---

## 1) API explicit cho Staff

### `AuthController`
- `POST /api/Auth/create-customer`  
  Staff/Admin/Manager tạo tài khoản customer.

### `AccountController`
- `GET /api/Account/GetAll`  
  Lấy toàn bộ tài khoản.
- `PATCH /api/Account/SetRole/{accountId}/role/{roleId}`  
  Gán role cho tài khoản.
- `PATCH /api/Account/SetAccountActive/{accountId}`  
  Kích hoạt tài khoản.
- `PATCH /api/Account/SetAccountInactive/{accountId}`  
  Vô hiệu hóa tài khoản.

### `BookingController`
- `GET /api/Booking/all`  
  Lấy tất cả booking.
- `POST /api/Booking/create-for-customer`  
  Staff tạo booking cho khách.
- `PUT /api/Booking/{id}/confirm`  
  Xác nhận booking.
- `PUT /api/Booking/{id}/complete`  
  Hoàn thành booking.

### `AppointmentController`
- `GET /api/Appointment/my-assigned`  
  Lấy lịch hẹn được phân công cho staff hiện tại.
- `GET /api/Appointment/all`  
  Lấy tất cả lịch hẹn.
- `PUT /api/Appointment/{id}/complete`  
  Đánh dấu hoàn thành lịch hẹn.
- `PUT /api/Appointment/{id}/confirm`  
  Xác nhận lịch hẹn.
- `POST /api/Appointment/create-for-customer`  
  Staff tạo lịch hẹn cho customer.

### `ContractController`
- `GET /api/Contract/all`
- `GET /api/Contract/{id}`
- `GET /api/Contract/preview/{bookingId}`
- `GET /api/Contract/{id}/export-pdf`
- `POST /api/Contract`
- `POST /api/Contract/from-booking/{bookingId}`
- `PUT /api/Contract/{id}/send`
- `PUT /api/Contract/{id}/upload-signed`
- `PUT /api/Contract/{id}/update-content`
- `GET /api/Contract/no-schedule`  
  Nhóm này phục vụ quy trình nghiệp vụ hợp đồng: xem/tạo/preview/xuất PDF/gửi/upload signed/cập nhật nội dung/lấy hợp đồng chưa lên lịch.

### `TransactionController`
- `GET /api/Transaction/all`  
  Lấy toàn bộ giao dịch.
- `POST /api/Transaction/payment`  
  Staff ghi nhận thanh toán thủ công cho khách.

### `NotificationController`
- `POST /api/Notification`  
  Tạo thông báo.
- `GET /api/Notification`  
  Lấy toàn bộ thông báo.
- `PUT /api/Notification/{id}`  
  Cập nhật thông báo.

### `FamilyProfileController`
- `GET /api/FamilyProfile/GetAll`
- `GET /api/FamilyProfile/GetById/{id}`
- `GET /api/FamilyProfile/GetByCustomerId/{customerId}`  
  Staff xem hồ sơ gia đình toàn hệ thống/theo customer.

### `StaffScheduleController` (các endpoint dành trực tiếp cho staff)
- `GET /api/StaffSchedule/me`  
  Xem lịch của chính staff.
- `PATCH /api/StaffSchedule/check`  
  Check/chấm trạng thái lịch làm việc.
- `PATCH /api/StaffSchedule/swap-schedule`  
  Tạo yêu cầu đổi lịch.
- `GET /api/StaffSchedule/my-swap-requests`  
  Xem yêu cầu đổi lịch đã gửi.
- `GET /api/StaffSchedule/my-incoming-swap-requests`  
  Xem yêu cầu đổi lịch đến.
- `PATCH /api/StaffSchedule/respond-swap-request/{requestId}/{respond}`  
  Phản hồi yêu cầu đổi lịch.

### `ChatController`
- `GET /api/Chat/conversations/all`  
  Xem tất cả conversation.
- `GET /api/Chat/support-requests`  
  Lấy các yêu cầu hỗ trợ đang chờ.
- `GET /api/Chat/support-requests/my`  
  Lấy yêu cầu hỗ trợ staff đang xử lý.
- `PUT /api/Chat/support-requests/{id}/accept`  
  Staff nhận yêu cầu hỗ trợ.
- `PUT /api/Chat/support-requests/{id}/resolve`  
  Staff đánh dấu đã xử lý.
- `POST /api/Chat/conversations/{id}/staff-message`  
  Staff nhắn tin trong cuộc hội thoại.

### `AmenityTicketController`
- `POST /api/AmenityTicket/staff-create`  
  Staff tạo ticket tiện ích cho khách.
- `PUT /api/AmenityTicket/{id}`  
  Staff/Customer cập nhật ticket.
- `PATCH /api/AmenityTicket/cancel/{id}`  
  Staff/Customer hủy ticket.

### `MemberTypesController`
- `GET /api/member-types/{id}`  
  Staff xem chi tiết loại thành viên.

---

## 2) API `[Authorize]` mà Staff cũng gọi được (tuỳ nghiệp vụ service)

Ví dụ đáng chú ý:
- `GET /api/Account/GetById/{id}`, `GetByEmail/{email}`, `GetByPhone/{phone}`, `GetCurrentAccount`
- `GET /api/Booking/{id}`, `GET /api/Appointment/{id}`
- `GET /api/Transaction/{id}`, `GET /api/Transaction/check-status/{orderCode}`
- `GET /api/Notification/me`, `GET /api/Notification/{id}`, `PUT /api/Notification/mark-as-read/{id}`
- `POST /api/FamilyProfile/Create`, `PUT/DELETE/PATCH FamilyProfile`
- `GET /api/AmenityTicket/{id}`, `POST /api/AmenityTicket`
- Các endpoint chat chung: `conversations`, `messages`, `request-support`, ...

---

Nếu bạn muốn, mình có thể xuất tiếp **một bảng chuẩn dạng Excel/CSV** gồm: `Method | Endpoint | Controller | Staff Access Type (Explicit/Auth) | Mô tả | Ghi chú nghiệp vụ` để team QA/test case dùng luôn.

