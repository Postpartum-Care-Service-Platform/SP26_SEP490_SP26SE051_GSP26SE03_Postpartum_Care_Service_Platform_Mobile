# Danh sách API của Staff chưa được sử dụng trong Mobile App

_Document này liệt kê các API dành cho Staff theo tài liệu `cursor_api_functionalities_for_staff.md` nhưng chưa được tích hợp vào mobile app._

---

## 📋 Tổng quan

Dựa trên tài liệu API functionalities for staff, có **2 nhóm API**:
1. **Nhóm A - Explicit cho staff**: endpoint có role chứa `staff`
2. **Nhóm B - Authenticated**: endpoint chỉ `[Authorize]` (Staff cũng gọi được)

---

## ✅ API đã được sử dụng

### AppointmentController
- ✅ `GET /api/Appointment/my-assigned` - Lấy lịch hẹn được phân công cho staff
- ✅ `GET /api/Appointment/all` - Lấy tất cả lịch hẹn
- ✅ `PUT /api/Appointment/{id}/confirm` - Xác nhận lịch hẹn
- ✅ `PUT /api/Appointment/{id}/complete` - Đánh dấu hoàn thành lịch hẹn
- ✅ `POST /api/Appointment/create-for-customer` - Staff tạo lịch hẹn cho customer

### AccountController
- ✅ `GET /api/Account/GetAll` - Lấy toàn bộ tài khoản (dùng cho customer selection)

### ChatController
- ✅ `POST /api/Chat/conversations/{id}/staff-message` - Staff nhắn tin trong cuộc hội thoại (đã có endpoint trong `api_endpoints.dart`)

---

## ❌ API chưa được sử dụng

### 1. AuthController
- ✅ `POST /api/Auth/create-customer`  
  **Mô tả:** Staff/Admin/Manager tạo tài khoản customer  
  **Trạng thái:** ✅ BE đã có (`WebAPI/Controllers/AuthController.cs`) và **mobile staff đã tích hợp** (Quick menu → `Tạo KH`)  
  **Ghi chú:** API trả về `temporaryPassword` + message; staff có thể copy mật khẩu tạm để gửi cho khách

### 2. AccountController
- ❌ `PATCH /api/Account/SetRole/{accountId}/role/{roleId}`  
  **Mô tả:** Gán role cho tài khoản  
  **Trạng thái:** Chưa có trong codebase  
  **Ghi chú:** Cần cho quản lý quyền người dùng

- ❌ `PATCH /api/Account/SetAccountActive/{accountId}`  
  **Mô tả:** Kích hoạt tài khoản  
  **Trạng thái:** Chưa có trong codebase  
  **Ghi chú:** Cần cho quản lý trạng thái tài khoản

- ❌ `PATCH /api/Account/SetAccountInactive/{accountId}`  
  **Mô tả:** Vô hiệu hóa tài khoản  
  **Trạng thái:** Chưa có trong codebase  
  **Ghi chú:** Cần cho quản lý trạng thái tài khoản

### 3. BookingController
- ✅ `GET /api/Booking/all`  
  **Mô tả:** Lấy tất cả booking  
  **Trạng thái:** ✅ BE đã có (`WebAPI/Controllers/BookingController.cs`) và **mobile staff đã tích hợp** (dùng trong `StaffBookingListScreen`)  
  **Ghi chú:** Cần cho staff xem toàn bộ booking của khách hàng

- ✅ `POST /api/Booking/create-for-customer`  
  **Mô tả:** Staff tạo booking cho khách  
  **Trạng thái:** ✅ BE đã có (`WebAPI/Controllers/BookingController.cs`) và **mobile staff đã tích hợp** (dùng trong `EmployeePackageBookingScreen`)  
  **Ghi chú:** Cần cho staff đặt dịch vụ thay khách hàng (chọn customer → chọn gói/phòng/ngày → tạo booking)

- ✅ `PUT /api/Booking/{id}/confirm`  
  **Mô tả:** Xác nhận booking  
  **Trạng thái:** ✅ BE đã có (`WebAPI/Controllers/BookingController.cs`) và **mobile staff đã tích hợp** (dùng trong `StaffBookingListScreen`)  
  **Ghi chú:** Cần cho staff xác nhận booking (trạng thái pending → confirmed)

- ✅ `PUT /api/Booking/{id}/complete`  
  **Mô tả:** Hoàn thành booking  
  **Trạng thái:** ✅ BE đã có (`WebAPI/Controllers/BookingController.cs`) và **mobile staff đã tích hợp** (dùng trong `StaffBookingListScreen`)  
  **Ghi chú:** Cần cho staff đánh dấu booking đã hoàn thành (confirmed → completed)

### 4. ContractController
- ❌ `GET /api/Contract/all`  
  **Mô tả:** Lấy tất cả hợp đồng  
  **Trạng thái:** Chưa có trong codebase  
  **Ghi chú:** Cần cho staff xem toàn bộ hợp đồng

- ❌ `GET /api/Contract/{id}`  
  **Mô tả:** Lấy chi tiết hợp đồng  
  **Trạng thái:** Chưa có trong codebase  
  **Ghi chú:** Cần cho staff xem chi tiết hợp đồng

- ❌ `GET /api/Contract/preview/{bookingId}`  
  **Mô tả:** Preview hợp đồng  
  **Trạng thái:** Chưa có trong codebase  
  **Ghi chú:** Cần cho staff xem preview hợp đồng trước khi gửi

- ❌ `GET /api/Contract/{id}/export-pdf`  
  **Mô tả:** Xuất PDF hợp đồng  
  **Trạng thái:** Chưa có trong codebase (có endpoint `/Contract/{contractId}/export-pdf` nhưng chưa dùng cho staff)  
  **Ghi chú:** Cần cho staff xuất PDF hợp đồng

- ❌ `POST /api/Contract`  
  **Mô tả:** Tạo hợp đồng  
  **Trạng thái:** Chưa có trong codebase  
  **Ghi chú:** Cần cho staff tạo hợp đồng

- ❌ `POST /api/Contract/from-booking/{bookingId}`  
  **Mô tả:** Tạo hợp đồng từ booking  
  **Trạng thái:** Chưa có trong codebase  
  **Ghi chú:** Cần cho staff tạo hợp đồng từ booking

- ❌ `PUT /api/Contract/{id}/send`  
  **Mô tả:** Gửi hợp đồng  
  **Trạng thái:** Chưa có trong codebase  
  **Ghi chú:** Cần cho staff gửi hợp đồng cho khách hàng

- ❌ `PUT /api/Contract/{id}/upload-signed`  
  **Mô tả:** Upload hợp đồng đã ký  
  **Trạng thái:** Chưa có trong codebase  
  **Ghi chú:** Cần cho staff upload hợp đồng đã được khách ký

- ❌ `PUT /api/Contract/{id}/update-content`  
  **Mô tả:** Cập nhật nội dung hợp đồng  
  **Trạng thái:** Chưa có trong codebase  
  **Ghi chú:** Cần cho staff chỉnh sửa nội dung hợp đồng

- ❌ `GET /api/Contract/no-schedule`  
  **Mô tả:** Lấy hợp đồng chưa lên lịch  
  **Trạng thái:** Chưa có trong codebase  
  **Ghi chú:** Cần cho staff xem hợp đồng chưa có lịch

### 5. TransactionController
- ✅ `GET /api/Transaction/all`  
  **Mô tả:** Lấy toàn bộ giao dịch  
  **Trạng thái:** ✅ BE đã có (`WebAPI/Controllers/TransactionController.cs`) và **mobile staff đã tích hợp** (màn `StaffTransactionListScreen`)  
  **Ghi chú:** Staff xem toàn bộ giao dịch thanh toán, có filter theo loại (Deposit/Remaining/Full) và trạng thái (Pending/Paid/Failed)

- ✅ `POST /api/Transaction/payment`  
  **Mô tả:** Staff ghi nhận thanh toán thủ công cho khách  
  **Trạng thái:** ✅ BE đã có (`WebAPI/Controllers/TransactionController.cs`) và **mobile staff đã tích hợp** (dùng trong `EmployeeOfflinePaymentScreen` được mở từ `StaffBookingListScreen`)  
  **Ghi chú:** Staff ghi nhận thanh toán offline (tiền mặt / chuyển khoản) dựa trên booking + customer, payload `bookingId`, `customerId`, `amount`, `paymentMethod`, `note?`

### 6. NotificationController
- ✅ `POST /api/Notification`  
  **Mô tả:** Tạo thông báo  
  **Trạng thái:** ✅ BE đã có nhưng **mobile staff chưa tích hợp UI** (chưa có màn tạo thông báo riêng cho staff/admin)  
  **Ghi chú:** Dự kiến dùng cho staff/admin tạo thông báo cho khách hàng

- ✅ `GET /api/Notification`  
  **Mô tả:** Lấy toàn bộ thông báo  
  **Trạng thái:** ✅ BE đã có và **đã tích hợp trên mobile** (màn `NotificationScreen` dùng chung, header staff hiển thị badge số lượng chưa đọc)  
  **Ghi chú:** Staff xem toàn bộ thông báo hệ thống, badge ở `EmployeeHeaderBar` gọi unread count

- ✅ `PUT /api/Notification/{id}`  
  **Mô tả:** Cập nhật thông báo / đánh dấu đã đọc  
  **Trạng thái:** ✅ BE đã có và **đã tích hợp trên mobile** ở mức mark-read (tap vào thông báo)  
  **Ghi chú:** Dùng cho flow đánh dấu thông báo đã đọc; chưa có màn chỉnh sửa nội dung thông báo

### 7. FamilyProfileController
- ✅ `GET /api/FamilyProfile/GetAll`  
  **Mô tả:** Lấy toàn bộ hồ sơ gia đình (Admin/Staff)  
  **Trạng thái:** Đã có ở BE (`WebAPI/Controllers/FamilyProfileController.cs`) nhưng **chưa dùng trên mobile**  
  **Ghi chú:** Không ưu tiên cho staff vì nghiệp vụ staff **chỉ xem các gia đình thuộc lịch/ca được phân công**

- ✅ `GET /api/FamilyProfile/GetById/{id}`  
  **Mô tả:** Lấy hồ sơ gia đình theo ID (Admin/Staff)  
  **Trạng thái:** Đã có ở BE nhưng **chưa dùng trên mobile** (mobile staff đang đi theo `customerId`)  
  **Ghi chú:** Có thể dùng sau nếu cần mở “xem chi tiết theo memberId”

- ✅ `GET /api/FamilyProfile/GetByCustomerId/{customerId}`  
  **Mô tả:** Lấy hồ sơ gia đình theo customer ID (Admin/Staff)  
  **Trạng thái:** **Đã tích hợp trên mobile staff** (Quick menu `Gia đình` → danh sách khách hàng được phân công → xem hồ sơ theo `customerId`)  
  **Ghi chú:** Staff **chỉ xem** hộ gia đình mà mình được phân công (nguồn phân công lấy từ `GET /api/Appointment/my-assigned`, gom theo `customerId`)

### 8. StaffScheduleController
- ✅ `GET /api/StaffSchedule/me`  
  **Mô tả:** Xem lịch của chính staff  
  **Trạng thái:** Đã tích hợp trong `check_in_out_screen.dart` và `requests_screen.dart` (dùng để load schedule cho check và dropdown đổi ca)  
  **Ghi chú:** Đã dùng query `from/to`

- ✅ `PATCH /api/StaffSchedule/check`  
  **Mô tả:** Check/chấm trạng thái lịch làm việc  
  **Trạng thái:** Đã tích hợp trong `check_in_out_screen.dart`  
  **Ghi chú:** Đang dùng payload `staffScheduleId`, `note`

- ✅ `PATCH /api/StaffSchedule/swap-schedule`  
  **Mô tả:** Tạo yêu cầu đổi lịch  
  **Trạng thái:** Đã tích hợp trong `requests_screen.dart`  
  **Ghi chú:** Đã dùng dropdown chọn `fromScheduleId/toScheduleId` + dropdown người nhận staff

- ✅ `GET /api/StaffSchedule/my-swap-requests`  
  **Mô tả:** Xem yêu cầu đổi lịch đã gửi  
  **Trạng thái:** Đã tích hợp trong `requests_screen.dart`  
  **Ghi chú:** Có filter theo ngày tạo cơ bản

- ✅ `GET /api/StaffSchedule/my-incoming-swap-requests`  
  **Mô tả:** Xem yêu cầu đổi lịch đến  
  **Trạng thái:** Đã tích hợp trong `requests_screen.dart`  
  **Ghi chú:** Có action phản hồi nhanh theo trạng thái

- ✅ `PATCH /api/StaffSchedule/respond-swap-request/{requestId}/{respond}`  
  **Mô tả:** Phản hồi yêu cầu đổi lịch  
  **Trạng thái:** Đã tích hợp trong `requests_screen.dart`  
  **Ghi chú:** Chấp nhận/Từ chối từ tab incoming

**TODO follow-up cho StaffSchedule (chưa làm):**
- ⏳ Đồng bộ định dạng ngày giờ hiển thị (hiện đang hiển thị `DateTime.toString()` thô).
- ⏳ Bổ sung validation rule nghiệp vụ đổi ca (không cho chọn trùng from/to, chặn tự gửi cho chính mình nếu backend yêu cầu).
- ⏳ Thêm phân trang/tải thêm cho danh sách swap requests khi dữ liệu lớn.
- ⏳ Bổ sung test UI/integration cho 2 màn `check_in_out_screen.dart` và `requests_screen.dart`.

### 9. ChatController
- ❌ `GET /api/Chat/conversations/all`  
  **Mô tả:** Xem tất cả conversation  
  **Trạng thái:** Chưa có trong codebase (hiện tại chỉ dùng `/Chat/conversations` cho customer)  
  **Ghi chú:** Cần cho staff xem tất cả cuộc trò chuyện của khách hàng

- ❌ `GET /api/Chat/support-requests`  
  **Mô tả:** Lấy các yêu cầu hỗ trợ đang chờ  
  **Trạng thái:** Chưa có trong codebase  
  **Ghi chú:** Cần cho staff xem danh sách yêu cầu hỗ trợ cần xử lý

- ❌ `GET /api/Chat/support-requests/my`  
  **Mô tả:** Lấy yêu cầu hỗ trợ staff đang xử lý  
  **Trạng thái:** Chưa có trong codebase  
  **Ghi chú:** Cần cho staff xem các yêu cầu hỗ trợ mình đang xử lý

- ❌ `PUT /api/Chat/support-requests/{id}/accept`  
  **Mô tả:** Staff nhận yêu cầu hỗ trợ  
  **Trạng thái:** Chưa có trong codebase  
  **Ghi chú:** Cần cho staff nhận xử lý yêu cầu hỗ trợ

- ❌ `PUT /api/Chat/support-requests/{id}/resolve`  
  **Mô tả:** Staff đánh dấu đã xử lý  
  **Trạng thái:** Chưa có trong codebase (có realtime event `SupportResolved` nhưng chưa có API call)  
  **Ghi chú:** Cần cho staff đánh dấu đã xử lý xong yêu cầu hỗ trợ

### 10. AmenityTicketController
- ❌ `POST /api/AmenityTicket/staff-create`  
  **Mô tả:** Staff tạo ticket tiện ích cho khách  
  **Trạng thái:** Chưa có trong codebase  
  **Ghi chú:** Cần cho staff đặt tiện ích thay khách hàng

- ❌ `PUT /api/AmenityTicket/{id}`  
  **Mô tả:** Staff/Customer cập nhật ticket  
  **Trạng thái:** Chưa có trong codebase  
  **Ghi chú:** Cần cho staff cập nhật thông tin ticket

- ❌ `PATCH /api/AmenityTicket/cancel/{id}`  
  **Mô tả:** Staff/Customer hủy ticket  
  **Trạng thái:** Chưa có trong codebase  
  **Ghi chú:** Cần cho staff hủy ticket tiện ích

### 11. MemberTypesController
- ❌ `GET /api/member-types/{id}`  
  **Mô tả:** Staff xem chi tiết loại thành viên  
  **Trạng thái:** Chưa có trong codebase (có endpoint `/member-types` nhưng chưa có theo ID)  
  **Ghi chú:** Cần cho staff xem chi tiết loại thành viên

---

## 📊 Tổng kết

### Số lượng API
- **Tổng số API dành cho Staff:** ~50 endpoints
- **Đã sử dụng:** ~6 endpoints (12%)
- **Chưa sử dụng:** ~44 endpoints (88%)

### Nhóm API chưa sử dụng nhiều nhất
1. **ContractController** - 10 endpoints (0% đã dùng)
2. **StaffScheduleController** - 6 endpoints (0% đã dùng)
3. **ChatController (staff-specific)** - 5 endpoints (20% đã dùng - chỉ có staff-message)
4. **BookingController** - 4 endpoints (0% đã dùng)
5. **AccountController** - 3 endpoints (33% đã dùng - chỉ có GetAll)

### Ưu tiên tích hợp (đề xuất)
1. **Cao:** StaffScheduleController (check-in/out, swap schedule) - liên quan trực tiếp đến nghiệp vụ staff
2. **Cao:** ChatController (support-requests) - cần cho staff xử lý yêu cầu hỗ trợ
3. **Trung bình:** BookingController - cần cho staff quản lý booking
4. **Trung bình:** ContractController - cần cho staff quản lý hợp đồng
5. **Thấp:** AccountController (SetRole, SetActive/Inactive) - thường dùng ở admin panel hơn mobile

---

## 🔗 Tham khảo
- File gốc: `cursor_api_functionalities_for_staff.md`
- Ngày tạo: 26/02/2026
- Ngày cập nhật: ${new Date().toLocaleDateString('vi-VN')}
