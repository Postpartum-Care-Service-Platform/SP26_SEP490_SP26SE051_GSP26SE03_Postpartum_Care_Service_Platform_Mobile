## Tài liệu API cho role `staff`

Tổng hợp các API mà **role `staff`** sẽ sử dụng cho các chức năng liên quan đến:
- **Hợp đồng**
- **Lịch làm việc, Menu, Lịch gia đình, Chat**
- **Booking, Appointment, Thanh toán**

---

## 1. Hợp đồng (HTML + hình ảnh đã ký)

Controller: `ContractController`

- **Lấy tất cả hợp đồng (Staff/Admin)**
  - **Method**: `GET`
  - **URL**: `/api/Contract/all`
  - **Authorize**: `Roles = admin,manager,staff`
  - **Use case**: Màn danh sách hợp đồng cho staff.

- **Lấy chi tiết hợp đồng (Staff/Admin)**
  - **Method**: `GET`
  - **URL**: `/api/Contract/{id}`
  - **Authorize**: `Roles = admin,manager,staff`
  - **Use case**: Xem chi tiết nội dung hợp đồng (bảng HTML).

- **Preview hợp đồng từ booking (Staff/Admin)**
  - **Method**: `GET`
  - **URL**: `/api/Contract/preview/{bookingId}`
  - **Authorize**: `Roles = admin,manager,staff`
  - **Use case**: Preview hợp đồng trước khi tạo/ghi nhận chính thức.

- **Xuất hợp đồng ra PDF (Staff/Admin)**
  - **Method**: `GET`
  - **URL**: `/api/Contract/{id}/export-pdf`
  - **Authorize**: `Roles = admin,manager,staff`
  - **Use case**: Nút tải xuống PDF hợp đồng.

- **Tạo hợp đồng cho booking (Staff/Admin)**
  - **Method**: `POST`
  - **URL**: `/api/Contract`
  - **Body**: `CreateContractRequest`
  - **Authorize**: `Roles = admin,manager,staff`
  - **Use case**: Staff tạo hợp đồng thủ công từ thông tin booking.

- **Tạo hợp đồng tự động từ booking (Staff/Admin)**
  - **Method**: `POST`
  - **URL**: `/api/Contract/from-booking/{bookingId}`
  - **Authorize**: `Roles = admin,manager,staff`
  - **Use case**: Tạo nhanh hợp đồng từ booking đã chọn.

- **Gửi hợp đồng cho khách xem (Staff/Admin)**
  - **Method**: `PUT`
  - **URL**: `/api/Contract/{id}/send`
  - **Authorize**: `Roles = admin,manager,staff`
  - **Use case**: Nút "Gửi hợp đồng" cho khách hàng.

- **Upload hợp đồng đã ký (Staff/Admin)**
  - **Method**: `PUT`
  - **URL**: `/api/Contract/{id}/upload-signed`
  - **Body**: `UploadSignedContractRequest`
  - **Authorize**: `Roles = admin,manager,staff`
  - **Use case**: Upload hình ảnh hợp đồng đã ký. FE dùng field hình ảnh để hiển thị nút **"Xem hợp đồng hoàn thiện"**.

- **Cập nhật nội dung hợp đồng (Staff/Admin)**
  - **Method**: `PUT`
  - **URL**: `/api/Contract/{id}/update-content`
  - **Body**: `UpdateContractContentRequest`
  - **Authorize**: `Roles = admin,manager,staff`
  - **Use case**: Chỉnh sửa nội dung HTML hợp đồng.

- **Lấy các hợp đồng chưa được lên lịch (Staff/Admin)**
  - **Method**: `GET`
  - **URL**: `/api/Contract/no-schedule`
  - **Authorize**: `Roles = admin,manager,staff`
  - **Use case**: Dùng cho flow tạo lịch gia đình cho hợp đồng chưa có lịch.

---

## 2. Staff – Lịch làm việc, Menu, Confirm, Chat, Profile, Lịch gia đình

### 2.1. Lịch làm việc Staff (`StaffScheduleController`)

- **Staff xem lịch làm việc của mình**
  - **Method**: `GET`
  - **URL**: `/api/StaffSchedule/me?from=yyyy-MM-dd&to=yyyy-MM-dd`
  - **Authorize**: `Roles = Staff`
  - **Use case**: Staff Home / Staff Center hiển thị lịch làm việc trong khoảng ngày.

- **Staff check lịch làm việc (check ca làm việc)**
  - **Method**: `PATCH`
  - **URL**: `/api/StaffSchedule/check`
  - **Body**: `CheckStaffScheduleRequest`
  - **Authorize**: `Roles = Staff`
  - **Use case**: Nút check-in/out ca, xác nhận lịch làm việc.

- **Staff yêu cầu đổi lịch (swap schedule)**
  - **Method**: `PATCH`
  - **URL**: `/api/StaffSchedule/swap-schedule`
  - **Body**: `CreateScheduleSwapRequest`
  - **Authorize**: `Roles = Staff`
  - **Use case**: Gửi yêu cầu đổi lịch với staff khác.

- **Xem yêu cầu đổi lịch do mình gửi**
  - **Method**: `GET`
  - **URL**: `/api/StaffSchedule/my-swap-requests`
  - **Authorize**: `Roles = Staff`

- **Xem yêu cầu đổi lịch gửi đến mình**
  - **Method**: `GET`
  - **URL**: `/api/StaffSchedule/my-incoming-swap-requests`
  - **Authorize**: `Roles = Staff`

- **Phản hồi yêu cầu đổi lịch**
  - **Method**: `PATCH`
  - **URL**: `/api/StaffSchedule/respond-swap-request/{requestId}/{respond}`
  - **Authorize**: `Roles = Staff`

> Các API `GetAllStaffAsync`, `CreateRangeAsync`, `ChangeStaffAsync`, `ApproveSwapRequestAsync` chủ yếu dùng cho Admin/Manager, không phải cho UI staff cơ bản.

---

### 2.2. Staff Menu Record (`MenuRecordController`)

- **Staff tạo MenuRecord cho khách hàng**
  - **Method**: `POST`
  - **URL**: `/api/MenuRecord/by-staff?customerId={customerId}`
  - **Body**: `List<CreateMenuRecordRequest>`
  - **Authorize**: `Roles = Staff`
  - **Use case**: Thêm menu ăn uống cho gia đình do staff quản lý.

- **Staff xem MenuRecord của khách hàng**
  - **Method**: `GET`
  - **URL**:
    - `/api/MenuRecord/customer/{customerId}`
    - `/api/MenuRecord/customer/{customerId}/date?date=yyyy-MM-dd`
    - `/api/MenuRecord/customer/{customerId}/date-range?from=...&to=...`
  - **Authorize**: `Roles = Staff`
  - **Use case**: Xem menu của khách theo ngày hoặc khoảng ngày.

- **Staff cập nhật MenuRecord cho khách hàng**
  - **Method**: `PUT`
  - **URL**: `/api/MenuRecord/by-staff?customerId={customerId}`
  - **Body**: `List<UpdateMenuRecordRequest>`
  - **Authorize**: `Roles = Staff`

- **Staff xoá/khôi phục MenuRecord của khách**
  - **Method**: `DELETE`
  - **URL**: `/api/MenuRecord/by-staff/{id}?customerId={customerId}`
  - **Authorize**: `Roles = Staff`
  - **Method**: `PATCH`
  - **URL**: `/api/MenuRecord/by-staff/restore/{id}?customerId={customerId}`
  - **Authorize**: `Roles = Staff`

---

### 2.3. Staff Confirm – Appointment (`AppointmentController`)

- **Lấy danh sách lịch hẹn được assign cho staff**
  - **Method**: `GET`
  - **URL**: `/api/Appointment/my-assigned`
  - **Authorize**: `Roles = admin,manager,staff`
  - **Use case**: Trang Staff Confirm – Appointment (danh sách lịch hẹn).

- **Staff/Admin xác nhận lịch hẹn**
  - **Method**: `PUT`
  - **URL**: `/api/Appointment/{id}/confirm`
  - **Authorize**: `Roles = admin,manager,staff`
  - **Use case**: Nút "Xác nhận" lịch hẹn.

- **Staff/Admin đánh dấu hoàn thành lịch hẹn**
  - **Method**: `PUT`
  - **URL**: `/api/Appointment/{id}/complete`
  - **Authorize**: `Roles = admin,manager,staff`
  - **Use case**: Nút "Hoàn thành" lịch hẹn sau khi đã thực hiện xong.

> Ngoài ra còn có `GET /api/Appointment/all` (xem tất cả) và các API cho customer, admin.

---

### 2.4. Staff Confirm – Booking (`BookingController`)

- **Lấy tất cả booking (Staff/Admin)**
  - **Method**: `GET`
  - **URL**: `/api/Booking/all`
  - **Authorize**: `Roles = admin,manager,staff`
  - **Use case**: Trang danh sách booking cho Staff Confirm – Booking.

- **Huỷ booking**
  - **Method**: `PUT`
  - **URL**: `/api/Booking/{id}/cancel`
  - **Authorize**: `[Authorize]` (service kiểm tra quyền và điều kiện)
  - **Business rule**:
    - Chưa hoàn thành đơn.
    - Không tới check-in.

- **Staff/Admin xác nhận booking**
  - **Method**: `PUT`
  - **URL**: `/api/Booking/{id}/confirm`
  - **Authorize**: `Roles = admin,manager,staff`
  - **Use case**: Nút "Confirm" booking.

- **Staff/Admin hoàn thành booking**
  - **Method**: `PUT`
  - **URL**: `/api/Booking/{id}/complete`
  - **Authorize**: `Roles = admin,manager,staff`
  - **Business rule**:
    - Đã thanh toán toàn bộ chi phí.
    - Đã check-out (kể cả out giữa chừng).

---

### 2.5. Chat – Staff chỉ chat khi được phân công (`ChatController`)

- **Lấy danh sách yêu cầu hỗ trợ đang chờ (chưa ai nhận)**
  - **Method**: `GET`
  - **URL**: `/api/Chat/support-requests`
  - **Authorize**: `Roles = admin,manager,staff`
  - **Use case**: Màn "Yêu cầu hỗ trợ" cho staff.

- **Lấy danh sách yêu cầu hỗ trợ mà staff hiện tại đang xử lý**
  - **Method**: `GET`
  - **URL**: `/api/Chat/support-requests/my`
  - **Authorize**: `Roles = admin,manager,staff`
  - **Use case**: Staff Home/Center hiển thị các cuộc hỗ trợ mình đã nhận.

- **Staff nhận một yêu cầu hỗ trợ (được phân công)**
  - **Method**: `PUT`
  - **URL**: `/api/Chat/support-requests/{id}/accept`
  - **Authorize**: `Roles = admin,manager,staff`
  - **Use case**: Nút "Nhận hỗ trợ". Sau bước này staff mới được chat trong conversation tương ứng.

- **Staff đánh dấu yêu cầu đã giải quyết**
  - **Method**: `PUT`
  - **URL**: `/api/Chat/support-requests/{id}/resolve`
  - **Authorize**: `Roles = admin,manager,staff`

- **Staff gửi tin nhắn vào conversation**
  - **Method**: `POST`
  - **URL**: `/api/Chat/conversations/{id}/staff-message`
  - **Body**: `SendMessageRequest`
  - **Authorize**: `Roles = admin,manager,staff`
  - **Use case**: Chat giữa staff và khách trong conversation mà staff đã được phân công.

> Quy tắc "staff chỉ được chat nếu được phân công/chỉ định" được kiểm soát ở layer service (`SendStaffMessageAsync`).

---

### 2.6. Staff Home / Center – Tổng hợp API

Gợi ý các API hiển thị trên dashboard Staff:

- **Lịch làm việc của mình**
  - `GET /api/StaffSchedule/me?from=...&to=...`

- **Lịch hẹn của mình**
  - `GET /api/Appointment/my-assigned`

- **Danh sách booking/hợp đồng liên quan**
  - `GET /api/Booking/all`
  - `GET /api/Contract/no-schedule`

- **Yêu cầu chat hỗ trợ mà mình đang xử lý**
  - `GET /api/Chat/support-requests/my`

- **(Tuỳ chọn) Thống kê giao dịch**
  - `GET /api/Transaction/all`

---

### 2.7. Staff xem profile khách hàng (`FamilyProfileController`)

- **Xem danh sách hồ sơ gia đình (Admin/Staff)**
  - **Method**: `GET`
  - **URL**: `/api/FamilyProfile/GetAll`
  - **Authorize**: `Roles = AdminOrStaff`

- **Xem hồ sơ gia đình theo Id (Admin/Staff)**
  - **Method**: `GET`
  - **URL**: `/api/FamilyProfile/GetById/{id}`
  - **Authorize**: `Roles = AdminOrStaff`

- **Xem hồ sơ gia đình theo CustomerId (Admin/Staff)**
  - **Method**: `GET`
  - **URL**: `/api/FamilyProfile/GetByCustomerId/{customerId}`
  - **Authorize**: `Roles = AdminOrStaff`

> Đây là nhóm API gắn cho màn Staff xem profile khách hàng, từ đó có thể mở thêm MenuRecord, lịch sinh hoạt, v.v.

---

### 2.8. Tạo lịch sinh hoạt gia đình khi check-in (đã thanh toán đủ)

Controller: `FamilyScheduleController`

- **Tạo lịch sinh hoạt gia đình dựa trên hợp đồng mới nhất**
  - **Method**: `POST`
  - **URL**: `/api/FamilySchedule`
  - **Body**: `CreateFamilyScheduleRequest`
  - **Authorize**: `Roles = Manager` (hiện tại)
  - **Use case**: Khi gia đình tới check-in và đã thanh toán đầy đủ, hệ thống sinh lịch sinh hoạt cho toàn bộ thời gian hợp đồng.

> Điều kiện "phải thanh toán đầy đủ" nên được kiểm tra:
> - Hoặc trong service tạo lịch (dựa trên trạng thái thanh toán trong hợp đồng/booking).
> - Hoặc FE chỉ hiển thị nút tạo lịch khi DTO booking/contract cho biết đã full paid.
>
> Nếu muốn **staff** (không phải manager) cũng có quyền tạo lịch, cần mở rộng `[Authorize]` cho action này để include role `staff`.

---

## 3. Booking & Thanh toán cho Staff

### 3.1. Booking (`BookingController`)

- **Huỷ booking**
  - **Method**: `PUT`
  - **URL**: `/api/Booking/{id}/cancel`
  - **Business rule**:
    - Chưa hoàn thành đơn.
    - Không tới check-in.

- **Xác nhận booking (Staff/Admin)**
  - **Method**: `PUT`
  - **URL**: `/api/Booking/{id}/confirm`
  - **Authorize**: `Roles = admin,manager,staff`

- **Hoàn thành booking (Staff/Admin)**
  - **Method**: `PUT`
  - **URL**: `/api/Booking/{id}/complete`
  - **Authorize**: `Roles = admin,manager,staff`
  - **Business rule**:
    - Đã thanh toán toàn bộ chi phí.
    - Đã check-out (kể cả out giữa chừng).

---

### 3.2. Thanh toán (`TransactionController` & `PaymentWebhookController`)

Controller: `TransactionController`

- **Staff ghi nhận thanh toán (tại quầy)**
  - **Method**: `POST`
  - **URL**: `/api/Transaction/payment`
  - **Body**: `CreatePaymentRequest`
  - **Authorize**: `Roles = admin,manager,staff`
  - **Use case**: Staff nhập giao dịch khi khách thanh toán trực tiếp.

- **Tạo payment link PayOS**
  - **Method**: `POST`
  - **URL**: `/api/Transaction/create-payment-link`
  - **Body**: `CreatePaymentLinkRequest`
  - **Use case**: Cho khách tự thanh toán online (Deposit/Full/Remaining).

- **Tạo payment link cho dịch vụ tại nhà**
  - **Method**: `POST`
  - **URL**: `/api/Transaction/create-home-service-payment-link`
  - **Body**: `CreateHomeServicePaymentLinkRequest`

- **Xem tất cả giao dịch (Staff/Admin)**
  - **Method**: `GET`
  - **URL**: `/api/Transaction/all`
  - **Authorize**: `Roles = admin,manager,staff`

Controller: `PaymentWebhookController` (PayOS gọi, không phải staff)

- **Verify webhook**
  - `GET /api/PaymentWebhook`

- **Nhận webhook thanh toán từ PayOS**
  - `POST /api/PaymentWebhook`

---

## 4. Gợi ý mapping UI → API (tóm tắt)

- **Hợp đồng**
  - Danh sách: `GET /api/Contract/all`
  - Chi tiết HTML: `GET /api/Contract/{id}`
  - Hợp đồng hoàn thiện (có chữ ký): dùng data từ `GET /api/Contract/{id}` sau khi `PUT /api/Contract/{id}/upload-signed`.

- **Staff Home**
  - Lịch làm việc: `GET /api/StaffSchedule/me`
  - Lịch hẹn: `GET /api/Appointment/my-assigned`
  - Yêu cầu hỗ trợ của mình: `GET /api/Chat/support-requests/my`

- **Staff Center**
  - Booking: `GET /api/Booking/all`
  - Hợp đồng chưa lên lịch: `GET /api/Contract/no-schedule`
  - Giao dịch: `GET /api/Transaction/all`

- **Profile khách hàng**
  - `GET /api/FamilyProfile/GetByCustomerId/{customerId}`
  - Menu khách: `GET /api/MenuRecord/customer/{customerId}[... ]`

- **Check-in & tạo lịch gia đình**
  - Kiểm tra thanh toán từ booking/contract/transaction DTO.
  - Tạo lịch: `POST /api/FamilySchedule` (role hiện tại: Manager).

