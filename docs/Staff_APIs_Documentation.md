# 📋 Tài Liệu API Cho Role Staff

Tài liệu này liệt kê tất cả các API mà **role `staff`** có thể sử dụng trong hệ thống Postpartum Care Service Platform.

---

## 📄 Mục Lục

0. [Dashboard Staff (Trang chính)](#0-dashboard-staff-trang-chính)
1. [Hợp Đồng (Contract)](#1-hợp-đồng-contract)
2. [Lịch Làm Việc Staff (Staff Schedule)](#2-lịch-làm-việc-staff-staff-schedule)
3. [Menu Record](#3-menu-record)
4. [Booking](#4-booking)
5. [Appointment](#5-appointment)
6. [Chat & Hỗ Trợ](#6-chat--hỗ-trợ)
7. [Lịch Sinh Hoạt Gia Đình (Family Schedule)](#7-lịch-sinh-hoạt-gia-đình-family-schedule)
8. [Hồ Sơ Gia Đình (Family Profile)](#8-hồ-sơ-gia-đình-family-profile)
9. [Giao Dịch & Thanh Toán (Transaction)](#9-giao-dịch--thanh-toán-transaction)
10. [Phòng (Room)](#10-phòng-room)
11. [Thông Báo (Notification)](#11-thông-báo-notification)
12. [Tài Khoản (Account)](#12-tài-khoản-account)
13. [Hồ Sơ Y Tế (Medical Record)](#13-hồ-sơ-y-tế-medical-record)
14. [Vé Tiện Ích (Amenity Ticket)](#14-vé-tiện-ích-amenity-ticket)
15. [Phản Hồi (Feedback)](#15-phản-hồi-feedback)

---

## 0. 🏠 Dashboard Staff (Trang chính)

### 0.1. Mô Tả Màn Hình
- Đây là **trang mặc định sau khi staff đăng nhập** (`EmployeePortalScreen` → `EmployeeScheduleScreenNew`).
- Giao diện dạng **dashboard** gồm:
  - Thanh header: chào nhân viên, tiêu đề "Portal Nhân viên / Quản lý công việc".
  - **Thẻ tổng quan (Stats)**: số lịch hẹn được giao, đã hoàn thành, đang xử lý.
  - **Quick Menu**: lưới các icon thao tác nhanh (lịch làm việc, dịch vụ, chat, hợp đồng, giao dịch, phòng, suất ăn, check-in/out, v.v.).
  - Danh sách chi tiết các **appointment được assign** cho staff.

### 0.2. API GET Tổng Hợp Dùng Cho Dashboard
Các API chủ yếu là **GET** để lấy dữ liệu tổng quan hiển thị dashboard:

1. **Lịch làm việc của staff**
   - `GET /api/StaffSchedule/me?from={dateFrom}&to={dateTo}`
   - Dùng để hiển thị lịch hôm nay/tuần này (nếu cần block lịch trong dashboard).

2. **Appointment được assign cho staff (core của dashboard hiện tại)**
   - `GET /api/Appointment/my-assigned`
   - Dùng để:
     - Load danh sách appointment gán cho nhân viên.
     - Tính toán **các chỉ số**: tổng số, hoàn thành, đang xử lý (hiển thị ở `StatsGrid`).

3. **Yêu cầu hỗ trợ đang xử lý**
   - `GET /api/Chat/support-requests/my`
   - Dùng để hiển thị số yêu cầu hỗ trợ staff đang phụ trách (có thể hiển thị dưới dạng badge/tổng số trên dashboard).

4. **Booking cần xử lý**
   - `GET /api/Booking/all`
   - FE filter theo trạng thái/ngày để:
     - Đếm số booking cần xác nhận/hôm nay.
     - Hiển thị widget nhỏ trong dashboard (nếu cần).

5. **Hợp đồng chưa lên lịch**
   - `GET /api/Contract/no-schedule`
   - Dùng để show **số hợp đồng chưa được tạo lịch sinh hoạt gia đình** (nhắc việc cho staff).

6. **Thông báo của staff**
   - `GET /api/Notification/me`
   - Dùng để hiển thị **một vài thông báo mới nhất** hoặc badge số lượng thông báo chưa đọc.

### 0.3. Quick Menu & Điều Hướng Từ Dashboard
- Quick menu được implement bằng `EmployeeQuickMenuSection` + `EmployeeQuickMenuPresets`.
- Một số điều hướng chính từ dashboard:
  - **Lịch làm việc** → `AppBottomTab.appointment` (mặc định đang ở tab này).
  - **Dịch vụ** → màn booking gói/dịch vụ (`EmployeePackageBookingScreen`) → sử dụng các API Booking/Transaction.
  - **Trao đổi (Chat)** → `EmployeeChatScreen` → sử dụng nhóm API Chat.
  - **Hợp đồng** → `StaffContractListScreen` → sử dụng nhóm API Contract.
  - **Giao dịch** → màn danh sách giao dịch (`staffTransactionList`) → sử dụng API Transaction.
  - **Check-in/out, Suất ăn, Yêu cầu, Gia đình, Tạo KH, Phòng ở...** → điều hướng sang các màn tương ứng, dùng các API trong các section còn lại của tài liệu này.

---

## 1. 📄 Hợp Đồng (Contract)

### 1.1. Xem Danh Sách Hợp Đồng
**Endpoint:** `GET /api/Contract/all`  
**Authorization:** `admin,manager,staff`  
**Mô tả:** Lấy tất cả hợp đồng trong hệ thống (Staff/Admin)

### 1.2. Xem Chi Tiết Hợp Đồng
**Endpoint:** `GET /api/Contract/{id}`  
**Authorization:** `admin,manager,staff`  
**Mô tả:** Lấy chi tiết hợp đồng theo ID (hiển thị bảng HTML không có chữ ký)

### 1.3. Preview Hợp Đồng Từ Booking
**Endpoint:** `GET /api/Contract/preview/{bookingId}`  
**Authorization:** `admin,manager,staff`  
**Mô tả:** Xem trước nội dung hợp đồng từ booking trước khi tạo chính thức

### 1.4. Xuất Hợp Đồng PDF
**Endpoint:** `GET /api/Contract/{id}/export-pdf`  
**Authorization:** `admin,manager,staff`  
**Mô tả:** Xuất hợp đồng ra file PDF để tải xuống  
**Response:** File PDF

### 1.5. Tạo Hợp Đồng
**Endpoint:** `POST /api/Contract`  
**Authorization:** `admin,manager,staff`  
**Body:** `CreateContractRequest`  
**Mô tả:** Tạo hợp đồng mới cho booking

### 1.6. Tạo Hợp Đồng Tự Động Từ Booking
**Endpoint:** `POST /api/Contract/from-booking/{bookingId}`  
**Authorization:** `admin,manager,staff`  
**Mô tả:** Tạo hợp đồng tự động từ thông tin booking đã có

### 1.7. Gửi Hợp Đồng Cho Khách
**Endpoint:** `PUT /api/Contract/{id}/send`  
**Authorization:** `admin,manager,staff`  
**Mô tả:** Gửi hợp đồng cho khách hàng xem qua email/notification

### 1.8. Upload Hợp Đồng Đã Ký ⭐
**Endpoint:** `PUT /api/Contract/{id}/upload-signed`  
**Authorization:** `admin,manager,staff`  
**Body:** `UploadSignedContractRequest`  
**Mô tả:** **API quan trọng** - Upload hình ảnh hợp đồng đã ký (dùng cho bảng "Xem hợp đồng hoàn thiện")

### 1.9. Cập Nhật Nội Dung Hợp Đồng
**Endpoint:** `PUT /api/Contract/{id}/update-content`  
**Authorization:** `admin,manager,staff`  
**Body:** `UpdateContractContentRequest`  
**Mô tả:** Cập nhật nội dung HTML của hợp đồng

### 1.10. Lấy Hợp Đồng Chưa Được Lên Lịch
**Endpoint:** `GET /api/Contract/no-schedule`  
**Authorization:** `admin,manager,staff`  
**Mô tả:** Lấy danh sách hợp đồng chưa được tạo lịch sinh hoạt gia đình

---

## 2. 📅 Lịch Làm Việc Staff (Staff Schedule)

### 2.1. Xem Lịch Làm Việc Của Mình ⭐
**Endpoint:** `GET /api/StaffSchedule/me?from={dateFrom}&to={dateTo}`  
**Authorization:** `staff`  
**Query Parameters:**
- `from`: DateOnly (yyyy-MM-dd)
- `to`: DateOnly (yyyy-MM-dd)  
**Mô tả:** **API chính** - Staff xem lịch làm việc của chính mình trong khoảng ngày (dùng cho Staff Home/Center)

### 2.2. Check Lịch Làm Việc
**Endpoint:** `PATCH /api/StaffSchedule/check`  
**Authorization:** `staff`  
**Body:** `CheckStaffScheduleRequest`  
**Mô tả:** Staff check-in/check-out ca làm việc

### 2.3. Swap Lịch Làm Việc
**Endpoint:** `PATCH /api/StaffSchedule/swap-schedule`  
**Authorization:** `staff`  
**Body:** `CreateScheduleSwapRequest`  
**Mô tả:** Gửi yêu cầu đổi lịch làm việc với nhân viên khác

### 2.4. Xem Yêu Cầu Đổi Lịch Của Mình
**Endpoint:** `GET /api/StaffSchedule/my-swap-requests`  
**Authorization:** `staff`  
**Mô tả:** Xem các yêu cầu đổi lịch mà mình đã gửi

### 2.5. Xem Yêu Cầu Đổi Lịch Đến Mình
**Endpoint:** `GET /api/StaffSchedule/my-incoming-swap-requests`  
**Authorization:** `staff`  
**Mô tả:** Xem các yêu cầu đổi lịch mà nhân viên khác gửi đến mình

### 2.6. Phản Hồi Yêu Cầu Đổi Lịch
**Endpoint:** `PATCH /api/StaffSchedule/respond-swap-request/{requestId}/{respond}`  
**Authorization:** `staff`  
**Route Parameters:**
- `requestId`: int
- `respond`: bool (true = đồng ý, false = từ chối)  
**Mô tả:** Phản hồi yêu cầu đổi lịch từ nhân viên khác

---

## 3. 🍽️ Menu Record

### 3.1. Tạo Menu Record Cho Khách Hàng ⭐
**Endpoint:** `POST /api/MenuRecord/by-staff?customerId={customerId}`  
**Authorization:** `staff`  
**Query Parameters:**
- `customerId`: Guid  
**Body:** `List<CreateMenuRecordRequest>`  
**Mô tả:** **API chính** - Staff tạo menu record cho khách hàng

### 3.2. Xem Menu Record Của Khách Hàng
**Endpoint:** `GET /api/MenuRecord/customer/{customerId}`  
**Authorization:** `staff`  
**Mô tả:** Lấy tất cả menu record của một khách hàng

### 3.3. Xem Menu Record Theo Ngày
**Endpoint:** `GET /api/MenuRecord/customer/{customerId}/date?date={date}`  
**Authorization:** `staff`  
**Query Parameters:**
- `date`: DateOnly (yyyy-MM-dd)  
**Mô tả:** Lấy menu record của khách hàng theo ngày cụ thể

### 3.4. Xem Menu Record Theo Khoảng Ngày
**Endpoint:** `GET /api/MenuRecord/customer/{customerId}/date-range?from={from}&to={to}`  
**Authorization:** `staff`  
**Query Parameters:**
- `from`: DateOnly
- `to`: DateOnly  
**Mô tả:** Lấy menu record của khách hàng trong khoảng ngày

### 3.5. Cập Nhật Menu Record
**Endpoint:** `PUT /api/MenuRecord/by-staff?customerId={customerId}`  
**Authorization:** `staff`  
**Body:** `List<UpdateMenuRecordRequest>`  
**Mô tả:** Cập nhật menu record của khách hàng

### 3.6. Xóa Menu Record
**Endpoint:** `DELETE /api/MenuRecord/by-staff/{id}?customerId={customerId}`  
**Authorization:** `staff`  
**Mô tả:** Xóa menu record của khách hàng (soft delete)

### 3.7. Khôi Phục Menu Record
**Endpoint:** `PATCH /api/MenuRecord/by-staff/restore/{id}?customerId={customerId}`  
**Authorization:** `staff`  
**Mô tả:** Khôi phục menu record đã xóa

---

## 4. 📋 Booking

### 4.1. Xem Tất Cả Booking
**Endpoint:** `GET /api/Booking/all`  
**Authorization:** `admin,manager,staff`  
**Mô tả:** Lấy danh sách tất cả booking trong hệ thống

### 4.2. Xem Chi Tiết Booking
**Endpoint:** `GET /api/Booking/{id}`  
**Authorization:** `[Authorize]` (tất cả role)  
**Mô tả:** Lấy chi tiết booking (service tự kiểm tra quyền)

### 4.3. Tạo Booking Cho Khách Tại Trung Tâm
**Endpoint:** `POST /api/Booking/create-for-customer`  
**Authorization:** `admin,manager,staff`  
**Body:** `CreateBookingByStaffRequest`  
**Mô tả:** Staff tạo booking cho khách hàng tại trung tâm

### 4.4. Hủy Booking
**Endpoint:** `PUT /api/Booking/{id}/cancel`  
**Authorization:** `[Authorize]`  
**Mô tả:** Hủy booking (điều kiện: chưa hoàn thành đơn, không tới check-in)  
**Lưu ý:** Service sẽ kiểm tra điều kiện nghiệp vụ

### 4.5. Xác Nhận Booking ⭐
**Endpoint:** `PUT /api/Booking/{id}/confirm`  
**Authorization:** `admin,manager,staff`  
**Mô tả:** **API cho trang Staff Confirm** - Xác nhận booking

### 4.6. Hoàn Thành Booking ⭐
**Endpoint:** `PUT /api/Booking/{id}/complete`  
**Authorization:** `admin,manager,staff`  
**Mô tả:** **API cho trang Staff Confirm** - Hoàn thành booking  
**Điều kiện nghiệp vụ:**
- Đã thanh toán toàn bộ chi phí
- Đã check-out (kể cả trường hợp out giữa chừng)  
**Lưu ý:** Service sẽ kiểm tra các điều kiện này

---

## 5. 📅 Appointment

### 5.1. Xem Lịch Hẹn Được Assign Cho Mình
**Endpoint:** `GET /api/Appointment/my-assigned`  
**Authorization:** `admin,manager,staff`  
**Mô tả:** Lấy danh sách appointment được phân công cho staff đang đăng nhập

### 5.2. Xem Tất Cả Appointment
**Endpoint:** `GET /api/Appointment/all`  
**Authorization:** `admin,manager,staff`  
**Mô tả:** Lấy tất cả appointment trong hệ thống

### 5.3. Xem Chi Tiết Appointment
**Endpoint:** `GET /api/Appointment/{id}`  
**Authorization:** `[Authorize]`  
**Mô tả:** Lấy chi tiết appointment (service kiểm tra quyền)

### 5.4. Tạo Appointment Cho Khách
**Endpoint:** `POST /api/Appointment/create-for-customer`  
**Authorization:** `admin,manager,staff`  
**Body:** `CreateAppointmentByStaffRequest`  
**Mô tả:** Staff tạo appointment cho khách hàng

### 5.5. Xác Nhận Appointment ⭐
**Endpoint:** `PUT /api/Appointment/{id}/confirm`  
**Authorization:** `admin,manager,staff`  
**Mô tả:** **API cho trang Staff Confirm** - Xác nhận appointment

### 5.6. Hoàn Thành Appointment ⭐
**Endpoint:** `PUT /api/Appointment/{id}/complete`  
**Authorization:** `admin,manager,staff`  
**Mô tả:** **API cho trang Staff Confirm** - Đánh dấu appointment đã hoàn thành

---

## 6. 💬 Chat & Hỗ Trợ

### 6.1. Xem Tất Cả Cuộc Hội Thoại
**Endpoint:** `GET /api/Chat/conversations/all`  
**Authorization:** `admin,manager,staff`  
**Mô tả:** Lấy tất cả cuộc hội thoại trong hệ thống

### 6.2. Xem Cuộc Hội Thoại Của Mình
**Endpoint:** `GET /api/Chat/conversations`  
**Authorization:** `[Authorize]`  
**Mô tả:** Lấy danh sách cuộc hội thoại của user đang đăng nhập

### 6.3. Xem Chi Tiết Cuộc Hội Thoại
**Endpoint:** `GET /api/Chat/conversations/{id}`  
**Authorization:** `[Authorize]`  
**Mô tả:** Lấy chi tiết cuộc hội thoại với messages (service kiểm tra quyền)

### 6.4. Lấy Yêu Cầu Hỗ Trợ Đang Chờ ⭐
**Endpoint:** `GET /api/Chat/support-requests`  
**Authorization:** `admin,manager,staff`  
**Mô tả:** Lấy danh sách yêu cầu hỗ trợ chưa được nhận (dùng cho Staff Home/Center)

### 6.5. Lấy Yêu Cầu Hỗ Trợ Của Mình ⭐
**Endpoint:** `GET /api/Chat/support-requests/my`  
**Authorization:** `admin,manager,staff`  
**Mô tả:** Lấy danh sách yêu cầu hỗ trợ mà staff đang xử lý (dùng cho Staff Home/Center)

### 6.6. Nhận Yêu Cầu Hỗ Trợ ⭐
**Endpoint:** `PUT /api/Chat/support-requests/{id}/accept`  
**Authorization:** `admin,manager,staff`  
**Mô tả:** **API quan trọng** - Staff nhận yêu cầu hỗ trợ (từ đây staff được phép chat trong conversation đó)

### 6.7. Đánh Dấu Đã Giải Quyết
**Endpoint:** `PUT /api/Chat/support-requests/{id}/resolve`  
**Authorization:** `admin,manager,staff`  
**Mô tả:** Staff đánh dấu yêu cầu hỗ trợ đã được giải quyết

### 6.8. Gửi Tin Nhắn (Staff) ⭐
**Endpoint:** `POST /api/Chat/conversations/{id}/staff-message`  
**Authorization:** `admin,manager,staff`  
**Body:** `SendMessageRequest`  
**Mô tả:** **API quan trọng** - Staff gửi tin nhắn vào conversation (chỉ được gửi sau khi đã accept support request)

### 6.9. Đánh Dấu Đã Đọc
**Endpoint:** `PUT /api/Chat/conversations/{id}/messages/read`  
**Authorization:** `[Authorize]`  
**Mô tả:** Đánh dấu tất cả messages trong conversation là đã đọc

---

## 7. 📅 Lịch Sinh Hoạt Gia Đình (Family Schedule)

### 7.1. Tạo Lịch Sinh Hoạt Gia Đình ⭐
**Endpoint:** `POST /api/FamilySchedule`  
**Authorization:** `staff,manager` (StaffOrManager)  
**Body:** `CreateFamilyScheduleRequest`  
**Mô tả:** **API quan trọng** - Tạo lịch sinh hoạt gia đình khi khách check-in (điều kiện: phải thanh toán đầy đủ)  
**Lưu ý:** Service sẽ tự động dựa trên hợp đồng mới nhất của khách hàng để tạo lịch

### 7.2. Xem Lịch Sinh Hoạt Theo Ngày
**Endpoint:** `GET /api/FamilySchedule/{date}`  
**Authorization:** `[Authorize]`  
**Route Parameters:**
- `date`: DateOnly (yyyy-MM-dd)  
**Mô tả:** Lấy lịch sinh hoạt gia đình theo ngày cụ thể

### 7.3. Xem Lịch Sinh Hoạt Theo Khoảng Ngày
**Endpoint:** `GET /api/FamilySchedule/date-range?dateFrom={dateFrom}&dateTo={dateTo}`  
**Authorization:** `[Authorize]`  
**Query Parameters:**
- `dateFrom`: DateOnly
- `dateTo`: DateOnly  
**Mô tả:** Lấy lịch sinh hoạt gia đình trong khoảng ngày

### 7.4. Cập Nhật Lịch Sinh Hoạt
**Endpoint:** `PUT /api/FamilySchedule/{scheduleId}`  
**Authorization:** `[Authorize]`  
**Body:** `UpdateFamilyScheduleRequest`  
**Mô tả:** Cập nhật lịch sinh hoạt gia đình

### 7.5. Xóa Lịch Sinh Hoạt
**Endpoint:** `DELETE /api/FamilySchedule/{scheduleId}`  
**Authorization:** `[Authorize]`  
**Mô tả:** Xóa (cancel) lịch trình sinh hoạt gia đình

---

## 8. 👨‍👩‍👧‍👦 Hồ Sơ Gia Đình (Family Profile)

### 8.1. Xem Tất Cả Hồ Sơ Gia Đình
**Endpoint:** `GET /api/FamilyProfile/GetAll`  
**Authorization:** `admin,staff` (AdminOrStaff)  
**Mô tả:** Lấy danh sách tất cả hồ sơ gia đình

### 8.2. Xem Hồ Sơ Gia Đình Theo ID
**Endpoint:** `GET /api/FamilyProfile/GetById/{id}`  
**Authorization:** `admin,staff` (AdminOrStaff)  
**Mô tả:** Lấy chi tiết hồ sơ gia đình theo ID

### 8.3. Xem Hồ Sơ Gia Đình Theo Customer ID ⭐
**Endpoint:** `GET /api/FamilyProfile/GetByCustomerId/{customerId}`  
**Authorization:** `admin,staff` (AdminOrStaff)  
**Mô tả:** **API chính** - Lấy danh sách hồ sơ gia đình của một khách hàng (dùng cho trang xem profile khách hàng)

---

## 9. 💳 Giao Dịch & Thanh Toán (Transaction)

### 9.1. Xem Tất Cả Giao Dịch
**Endpoint:** `GET /api/Transaction/all`  
**Authorization:** `admin,manager,staff`  
**Mô tả:** Lấy tất cả giao dịch trong hệ thống (dùng để kiểm tra thanh toán)

### 9.2. Xem Chi Tiết Giao Dịch
**Endpoint:** `GET /api/Transaction/{id}`  
**Authorization:** `[Authorize]`  
**Mô tả:** Lấy chi tiết giao dịch theo ID (staff có thể xem tất cả)

### 9.3. Ghi Nhận Thanh Toán ⭐
**Endpoint:** `POST /api/Transaction/payment`  
**Authorization:** `admin,manager,staff`  
**Body:** `CreatePaymentRequest`  
**Mô tả:** **API quan trọng** - Staff ghi nhận thanh toán tại quầy (tiền mặt/chuyển khoản)

### 9.4. Tạo Payment Link
**Endpoint:** `POST /api/Transaction/create-payment-link`  
**Authorization:** `[Authorize]`  
**Body:** `CreatePaymentLinkRequest`  
**Mô tả:** Tạo payment link PayOS cho khách thanh toán online  
**Type:** "Deposit" (đặt cọc 10%), "Full" (thanh toán 100%), "Remaining" (thanh toán phần còn lại)

### 9.5. Tạo Payment Link Cho Dịch Vụ Tại Nhà
**Endpoint:** `POST /api/Transaction/create-home-service-payment-link`  
**Authorization:** `[Authorize]`  
**Body:** `CreateHomeServicePaymentLinkRequest`  
**Mô tả:** Tạo payment link cho dịch vụ tại nhà (Home Service)

### 9.6. Kiểm Tra Trạng Thái Thanh Toán
**Endpoint:** `GET /api/Transaction/check-status/{orderCode}`  
**Authorization:** `[AllowAnonymous]`  
**Mô tả:** Kiểm tra trạng thái thanh toán theo orderCode

---

## 10. 🏠 Phòng (Room)

### 10.1. Xem Tất Cả Phòng
**Endpoint:** `GET /api/Room`  
**Authorization:** `[AllowAnonymous]`  
**Mô tả:** Lấy danh sách tất cả phòng

### 10.2. Xem Chi Tiết Phòng
**Endpoint:** `GET /api/Room/{id}`  
**Authorization:** `[AllowAnonymous]`  
**Mô tả:** Lấy chi tiết phòng theo ID

### 10.3. Xem Phòng Trống
**Endpoint:** `GET /api/Room/empty`  
**Authorization:** `[Authorize]`  
**Mô tả:** Lấy danh sách phòng đang trống

### 10.4. Xem Phòng Có Sẵn Trong Khoảng Thời Gian
**Endpoint:** `GET /api/Room/available?startDate={startDate}&endDate={endDate}`  
**Authorization:** `[AllowAnonymous]`  
**Query Parameters:**
- `startDate`: DateOnly
- `endDate`: DateOnly  
**Mô tả:** Lấy danh sách phòng còn trống trong khoảng thời gian được chọn

### 10.5. Xem Lịch Đặt Phòng
**Endpoint:** `GET /api/Room/booking-periods`  
**Authorization:** `[AllowAnonymous]`  
**Mô tả:** Lấy tất cả khoảng thời gian phòng đã được đặt (còn hiệu lực)

### 10.6. Xem Lịch Đặt Phòng Theo Phòng
**Endpoint:** `GET /api/Room/{id}/booking-periods`  
**Authorization:** `[AllowAnonymous]`  
**Mô tả:** Lấy khoảng thời gian đã đặt của một phòng cụ thể

---

## 11. 🔔 Thông Báo (Notification)

### 11.1. Tạo Thông Báo
**Endpoint:** `POST /api/Notification`  
**Authorization:** `admin,staff` (AdminOrStaff)  
**Body:** `CreateNotificationRequest`  
**Mô tả:** Staff tạo thông báo mới

### 11.2. Xem Tất Cả Thông Báo
**Endpoint:** `GET /api/Notification`  
**Authorization:** `admin,staff` (AdminOrStaff)  
**Mô tả:** Lấy tất cả thông báo trong hệ thống

### 11.3. Xem Thông Báo Của Mình
**Endpoint:** `GET /api/Notification/me`  
**Authorization:** `[Authorize]`  
**Mô tả:** Lấy thông báo của user đang đăng nhập

### 11.4. Đánh Dấu Đã Đọc
**Endpoint:** `PUT /api/Notification/mark-as-read/{id}`  
**Authorization:** `[Authorize]`  
**Mô tả:** Đánh dấu thông báo là đã đọc

---

## 12. 👤 Tài Khoản (Account)

### 12.1. Xem Tất Cả Tài Khoản
**Endpoint:** `GET /api/Account/GetAll`  
**Authorization:** `admin,staff` (AdminOrStaff)  
**Mô tả:** Lấy danh sách tất cả tài khoản

### 12.2. Xem Chi Tiết Tài Khoản
**Endpoint:** `GET /api/Account/GetById/{id}`  
**Authorization:** `[Authorize]`  
**Mô tả:** Lấy chi tiết tài khoản theo ID

### 12.3. Xem Tài Khoản Theo Email
**Endpoint:** `GET /api/Account/GetByEmail/{email}`  
**Authorization:** `[Authorize]`  
**Mô tả:** Lấy tài khoản theo email

### 12.4. Xem Tài Khoản Theo Số Điện Thoại
**Endpoint:** `GET /api/Account/GetByPhone/{phone}`  
**Authorization:** `[Authorize]`  
**Mô tả:** Lấy tài khoản theo số điện thoại

### 12.5. Xem Tài Khoản Hiện Tại
**Endpoint:** `GET /api/Account/GetCurrentAccount`  
**Authorization:** `[Authorize]`  
**Mô tả:** Lấy thông tin tài khoản đang đăng nhập (kèm thông tin gói dịch vụ nếu có)

---

## 13. 🏥 Hồ Sơ Y Tế (Medical Record)

### 13.1. Xem Tất Cả Hồ Sơ Y Tế
**Endpoint:** `GET /api/MedicalRecord/all`  
**Authorization:** `admin,manager,staff`  
**Mô tả:** Lấy tất cả hồ sơ y tế trong hệ thống

### 13.2. Xem Chi Tiết Hồ Sơ Y Tế
**Endpoint:** `GET /api/MedicalRecord/{id}`  
**Authorization:** `[Authorize]`  
**Mô tả:** Lấy chi tiết hồ sơ y tế theo ID

### 13.3. Xem Hồ Sơ Y Tế Của Khách Hàng
**Endpoint:** `GET /api/MedicalRecord/customer/{customerId}`  
**Authorization:** `admin,manager,staff`  
**Mô tả:** Lấy hồ sơ y tế của một khách hàng

### 13.4. Tạo Hồ Sơ Y Tế
**Endpoint:** `POST /api/MedicalRecord?customerId={customerId}`  
**Authorization:** `admin,manager,staff`  
**Query Parameters:**
- `customerId`: Guid  
**Body:** `CreateMedicalRecordRequest`  
**Mô tả:** Tạo hồ sơ y tế cho khách hàng

### 13.5. Cập Nhật Hồ Sơ Y Tế
**Endpoint:** `PUT /api/MedicalRecord/{id}`  
**Authorization:** `[Authorize]`  
**Body:** `UpdateMedicalRecordRequest`  
**Mô tả:** Cập nhật hồ sơ y tế

---

## 14. 🎫 Vé Tiện Ích (Amenity Ticket)

### 14.1. Tạo Vé Tiện Ích Cho Khách
**Endpoint:** `POST /api/AmenityTicket/staff-create`  
**Authorization:** `staff`  
**Body:** `StaffCreateAmenityTicketRequest`  
**Mô tả:** Staff tạo vé tiện ích cho khách hàng

### 14.2. Xem Chi Tiết Vé Tiện Ích
**Endpoint:** `GET /api/AmenityTicket/{id}`  
**Authorization:** `[Authorize]`  
**Mô tả:** Lấy chi tiết vé tiện ích theo ID

### 14.3. Cập Nhật Vé Tiện Ích
**Endpoint:** `PUT /api/AmenityTicket/{id}`  
**Authorization:** `staff,customer` (StaffOrCustomer)  
**Body:** `UpdateAmenityTicketRequest`  
**Mô tả:** Cập nhật vé tiện ích

### 14.4. Hủy Vé Tiện Ích
**Endpoint:** `PATCH /api/AmenityTicket/cancel/{id}`  
**Authorization:** `staff,customer` (StaffOrCustomer)  
**Mô tả:** Hủy vé tiện ích

---

## 15. 💬 Phản Hồi (Feedback)

### 15.1. Xem Tất Cả Phản Hồi
**Endpoint:** `GET /api/Feedback`  
**Authorization:** `[Authorize]`  
**Mô tả:** Lấy tất cả phản hồi trong hệ thống

### 15.2. Xem Chi Tiết Phản Hồi
**Endpoint:** `GET /api/Feedback/{id}`  
**Authorization:** `[Authorize]`  
**Mô tả:** Lấy chi tiết phản hồi theo ID

---

## 📌 Tóm Tắt Các API Quan Trọng Cho Staff

### ⭐ API Cho Trang Staff Home/Center:
1. `GET /api/StaffSchedule/me` - Xem lịch làm việc
2. `GET /api/Appointment/my-assigned` - Xem appointment được assign
3. `GET /api/Chat/support-requests/my` - Xem yêu cầu hỗ trợ đang xử lý
4. `GET /api/Booking/all` - Xem tất cả booking
5. `GET /api/Contract/no-schedule` - Xem hợp đồng chưa lên lịch

### ⭐ API Cho Trang Staff Confirm:
1. `PUT /api/Booking/{id}/confirm` - Xác nhận booking
2. `PUT /api/Booking/{id}/complete` - Hoàn thành booking
3. `PUT /api/Appointment/{id}/confirm` - Xác nhận appointment
4. `PUT /api/Appointment/{id}/complete` - Hoàn thành appointment

### ⭐ API Cho Hợp Đồng (2 Bảng):
1. `GET /api/Contract/{id}` - Xem bảng HTML (không chữ ký)
2. `PUT /api/Contract/{id}/upload-signed` - Upload bảng hình ảnh có chữ ký
3. `GET /api/Contract/{id}/export-pdf` - Tải PDF hợp đồng

### ⭐ API Cho Chat (Staff Chỉ Chat Khi Được Phân Công):
1. `GET /api/Chat/support-requests` - Xem yêu cầu chờ
2. `PUT /api/Chat/support-requests/{id}/accept` - Nhận yêu cầu (bắt buộc)
3. `POST /api/Chat/conversations/{id}/staff-message` - Gửi tin nhắn (sau khi accept)

### ⭐ API Cho Tạo Lịch Gia Đình Khi Check-in:
1. `POST /api/FamilySchedule` - Tạo lịch (điều kiện: đã thanh toán đủ)
2. `GET /api/Transaction/all` - Kiểm tra thanh toán

### ⭐ API Cho Xem Profile Khách Hàng:
1. `GET /api/FamilyProfile/GetByCustomerId/{customerId}` - Xem hồ sơ gia đình
2. `GET /api/MenuRecord/customer/{customerId}` - Xem menu record
3. `GET /api/MedicalRecord/customer/{customerId}` - Xem hồ sơ y tế

### ⭐ API Cho Menu Record:
1. `POST /api/MenuRecord/by-staff?customerId={customerId}` - Tạo menu record
2. `PUT /api/MenuRecord/by-staff?customerId={customerId}` - Cập nhật menu record
3. `DELETE /api/MenuRecord/by-staff/{id}?customerId={customerId}` - Xóa menu record

### ⭐ API Cho Thanh Toán:
1. `POST /api/Transaction/payment` - Ghi nhận thanh toán tại quầy
2. `GET /api/Transaction/all` - Xem tất cả giao dịch

---

## 🔐 Lưu Ý Về Authorization

- `[Authorize]`: Yêu cầu đăng nhập (bất kỳ role nào)
- `[Authorize(Roles = "admin,manager,staff")]`: Chỉ admin, manager, hoặc staff
- `[Authorize(Roles = AppConstants.Role.StaffRoleName)]`: Chỉ staff
- `[Authorize(Roles = AppConstants.Role.AdminOrStaff)]`: Admin hoặc staff
- `[Authorize(Roles = AppConstants.Role.StaffOrManager)]`: Staff hoặc manager
- `[AllowAnonymous]`: Không cần đăng nhập

---

## 📝 Ghi Chú

1. **Điều kiện nghiệp vụ** (như "đã thanh toán đủ", "chưa check-in") được kiểm tra trong **Service Layer**, không phải Controller. Frontend chỉ cần gọi API đúng lúc.

2. **Staff chỉ được chat** sau khi đã **accept support request**. Backend sẽ kiểm tra điều kiện này trong `SendStaffMessageAsync`.

3. **Tạo lịch gia đình** yêu cầu role `staff,manager` (StaffOrManager). Service sẽ tự động dựa trên hợp đồng mới nhất của khách hàng.

4. **Hoàn thành booking** yêu cầu: đã thanh toán đủ + đã check-out. Service sẽ kiểm tra các điều kiện này.

5. Tất cả các API đều trả về JSON format, trừ API export PDF trả về file.

---

**Cập nhật lần cuối:** Dựa trên code trong thư mục `WebAPI/Controllers`  
**Phiên bản:** 1.0
