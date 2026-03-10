# 📋 Tài Liệu API GET Cho Customer

Tài liệu này liệt kê tất cả các **API GET** mà **customer** có thể sử dụng để **hiển thị dữ liệu** trong hệ thống Postpartum Care Service Platform.

---

## 📄 Mục Lục

1. [API Public (Không Cần Đăng Nhập)](#1-api-public-không-cần-đăng-nhập)
2. [API Cần Đăng Nhập - Xem Dữ Liệu Của Chính Mình](#2-api-cần-đăng-nhập---xem-dữ-liệu-của-chính-mình)
3. [API Cần Đăng Nhập - Xem Dữ Liệu Chung](#3-api-cần-đăng-nhập---xem-dữ-liệu-chung)

---

## 1. 🌐 API Public (Không Cần Đăng Nhập)

### 📦 Packages (Gói Dịch Vụ)

#### 1.1. Xem Danh Sách Gói Dịch Vụ Tại Trung Tâm
**Endpoint:** `GET /api/Packages/center`  
**Authorization:** `[AllowAnonymous]` - Không cần đăng nhập  
**Mô tả:** Lấy danh sách tất cả gói dịch vụ tại trung tâm (Center Package)  
**Dùng cho:** Trang chủ, trang danh sách gói dịch vụ

#### 1.2. Xem Chi Tiết Gói Dịch Vụ
**Endpoint:** `GET /api/Packages/{id}`  
**Authorization:** `[AllowAnonymous]` - Không cần đăng nhập  
**Mô tả:** Lấy chi tiết gói dịch vụ theo ID  
**Dùng cho:** Trang chi tiết gói dịch vụ

---

### 🏠 Room (Phòng)

#### 1.3. Xem Tất Cả Phòng
**Endpoint:** `GET /api/Room`  
**Authorization:** `[AllowAnonymous]` - Không cần đăng nhập  
**Mô tả:** Lấy danh sách tất cả phòng trong hệ thống  
**Dùng cho:** Trang danh sách phòng, trang booking

#### 1.4. Xem Chi Tiết Phòng
**Endpoint:** `GET /api/Room/{id}`  
**Authorization:** `[AllowAnonymous]` - Không cần đăng nhập  
**Mô tả:** Lấy chi tiết phòng theo ID  
**Dùng cho:** Trang chi tiết phòng

#### 1.5. Xem Phòng Theo Tầng
**Endpoint:** `GET /api/Room/floor/{floorNumber}`  
**Authorization:** `[AllowAnonymous]` - Không cần đăng nhập  
**Route Parameters:**
- `floorNumber`: int (số tầng)  
**Mô tả:** Lấy danh sách phòng theo tầng cụ thể  
**Dùng cho:** Trang xem phòng theo tầng

#### 1.6. Xem Phòng Có Sẵn Trong Khoảng Thời Gian ⭐
**Endpoint:** `GET /api/Room/available?startDate={startDate}&endDate={endDate}`  
**Authorization:** `[AllowAnonymous]` - Không cần đăng nhập  
**Query Parameters:**
- `startDate`: DateOnly (yyyy-MM-dd)
- `endDate`: DateOnly (yyyy-MM-dd)  
**Mô tả:** Lấy danh sách phòng còn trống trong khoảng thời gian được chọn  
**Dùng cho:** Trang booking - chọn phòng theo ngày

#### 1.7. Xem Lịch Đặt Phòng
**Endpoint:** `GET /api/Room/booking-periods`  
**Authorization:** `[AllowAnonymous]` - Không cần đăng nhập  
**Mô tả:** Lấy tất cả khoảng thời gian phòng đã được đặt (còn hiệu lực)  
**Dùng cho:** Hiển thị lịch đặt phòng trên calendar

#### 1.8. Xem Lịch Đặt Phòng Theo Phòng
**Endpoint:** `GET /api/Room/{id}/booking-periods`  
**Authorization:** `[AllowAnonymous]` - Không cần đăng nhập  
**Mô tả:** Lấy khoảng thời gian đã đặt của một phòng cụ thể  
**Dùng cho:** Xem lịch đặt của từng phòng

---

### 🏷️ RoomType (Loại Phòng)

#### 1.9. Xem Danh Sách Loại Phòng (Cho Customer)
**Endpoint:** `GET /api/RoomType/for-customer`  
**Authorization:** `[AllowAnonymous]` - Không cần đăng nhập  
**Mô tả:** Lấy danh sách loại phòng dành cho customer (chỉ hiển thị loại đang active)  
**Dùng cho:** Trang danh sách loại phòng, filter phòng

#### 1.10. Xem Chi Tiết Loại Phòng
**Endpoint:** `GET /api/RoomType/{id}`  
**Authorization:** `[AllowAnonymous]` - Không cần đăng nhập  
**Mô tả:** Lấy chi tiết loại phòng theo ID  
**Dùng cho:** Trang chi tiết loại phòng

---

### 🍽️ Menu (Thực Đơn)

#### 1.11. Xem Tất Cả Menu
**Endpoint:** `GET /api/Menu`  
**Authorization:** `[AllowAnonymous]` - Không cần đăng nhập  
**Mô tả:** Lấy danh sách tất cả menu  
**Dùng cho:** Trang danh sách menu

#### 1.12. Xem Chi Tiết Menu
**Endpoint:** `GET /api/Menu/{id}`  
**Authorization:** `[AllowAnonymous]` - Không cần đăng nhập  
**Mô tả:** Lấy chi tiết menu theo ID  
**Dùng cho:** Trang chi tiết menu

#### 1.13. Xem Menu Theo Loại Menu
**Endpoint:** `GET /api/Menu/byMenuType/{menuTypeId}`  
**Authorization:** `[AllowAnonymous]` - Không cần đăng nhập  
**Route Parameters:**
- `menuTypeId`: int  
**Mô tả:** Lấy danh sách menu theo loại menu  
**Dùng cho:** Filter menu theo loại

---

### 🏷️ MenuType (Loại Thực Đơn)

#### 1.14. Xem Tất Cả Loại Menu
**Endpoint:** `GET /api/MenuType`  
**Authorization:** `[AllowAnonymous]` - Không cần đăng nhập  
**Mô tả:** Lấy danh sách tất cả loại menu  
**Dùng cho:** Filter menu, dropdown loại menu

#### 1.15. Xem Chi Tiết Loại Menu
**Endpoint:** `GET /api/MenuType/{id}`  
**Authorization:** `[AllowAnonymous]` - Không cần đăng nhập  
**Mô tả:** Lấy chi tiết loại menu theo ID

---

### 🍜 Food (Món Ăn)

#### 1.16. Xem Tất Cả Món Ăn
**Endpoint:** `GET /api/Food`  
**Authorization:** `[AllowAnonymous]` - Không cần đăng nhập  
**Mô tả:** Lấy danh sách tất cả món ăn  
**Dùng cho:** Trang danh sách món ăn

#### 1.17. Xem Chi Tiết Món Ăn
**Endpoint:** `GET /api/Food/{id}`  
**Authorization:** `[AllowAnonymous]` - Không cần đăng nhập  
**Mô tả:** Lấy chi tiết món ăn theo ID  
**Dùng cho:** Trang chi tiết món ăn

---

### 🎯 Activities (Hoạt Động)

#### 1.18. Xem Tất Cả Hoạt Động
**Endpoint:** `GET /api/Activities`  
**Authorization:** `[AllowAnonymous]` - Không cần đăng nhập  
**Mô tả:** Lấy danh sách tất cả hoạt động (Public)  
**Dùng cho:** Trang danh sách hoạt động

#### 1.19. Xem Chi Tiết Hoạt Động
**Endpoint:** `GET /api/Activities/{id}`  
**Authorization:** `[AllowAnonymous]` - Không cần đăng nhập  
**Mô tả:** Lấy chi tiết hoạt động theo ID  
**Dùng cho:** Trang chi tiết hoạt động

---

### 🏷️ ActivityType (Loại Hoạt Động)

#### 1.20. Xem Tất Cả Loại Hoạt Động
**Endpoint:** `GET /api/ActivityType`  
**Authorization:** `[AllowAnonymous]` - Không cần đăng nhập  
**Mô tả:** Lấy danh sách tất cả loại hoạt động  
**Dùng cho:** Filter hoạt động

#### 1.21. Xem Chi Tiết Loại Hoạt Động
**Endpoint:** `GET /api/ActivityType/{id}`  
**Authorization:** `[AllowAnonymous]` - Không cần đăng nhập  
**Mô tả:** Lấy chi tiết loại hoạt động theo ID

---

### 🎫 AmenityService (Dịch Vụ Tiện Ích)

#### 1.22. Xem Tất Cả Dịch Vụ Tiện Ích
**Endpoint:** `GET /api/AmenityService`  
**Authorization:** `[AllowAnonymous]` - Không cần đăng nhập  
**Mô tả:** Lấy danh sách tất cả dịch vụ tiện ích  
**Dùng cho:** Trang danh sách dịch vụ tiện ích

#### 1.23. Xem Chi Tiết Dịch Vụ Tiện Ích
**Endpoint:** `GET /api/AmenityService/{id}`  
**Authorization:** `[AllowAnonymous]` - Không cần đăng nhập  
**Mô tả:** Lấy chi tiết dịch vụ tiện ích theo ID  
**Dùng cho:** Trang chi tiết dịch vụ tiện ích

---

### 📋 CarePlanDetails (Chi Tiết Kế Hoạch Chăm Sóc)

#### 1.24. Xem Tất Cả Chi Tiết Kế Hoạch Chăm Sóc
**Endpoint:** `GET /api/care-plan-details`  
**Authorization:** `[AllowAnonymous]` - Không cần đăng nhập  
**Mô tả:** Lấy danh sách tất cả chi tiết kế hoạch chăm sóc (Public)  
**Dùng cho:** Trang thông tin kế hoạch chăm sóc

#### 1.25. Xem Chi Tiết Kế Hoạch Chăm Sóc Theo ID
**Endpoint:** `GET /api/care-plan-details/{id}`  
**Authorization:** `[AllowAnonymous]` - Không cần đăng nhập  
**Mô tả:** Lấy chi tiết kế hoạch chăm sóc theo ID

#### 1.26. Xem Chi Tiết Kế Hoạch Chăm Sóc Theo Package ⭐
**Endpoint:** `GET /api/care-plan-details/by-package/{packageId}`  
**Authorization:** `[AllowAnonymous]` - Không cần đăng nhập  
**Route Parameters:**
- `packageId`: int  
**Mô tả:** Lấy danh sách chi tiết kế hoạch chăm sóc theo Package  
**Dùng cho:** Hiển thị kế hoạch chăm sóc của từng gói dịch vụ

---

### 🏷️ PackageType (Loại Gói)

#### 1.27. Xem Tất Cả Loại Gói
**Endpoint:** `GET /api/PackageType`  
**Authorization:** `[AllowAnonymous]` - Không cần đăng nhập  
**Mô tả:** Lấy danh sách tất cả loại gói  
**Dùng cho:** Filter gói dịch vụ

#### 1.28. Xem Chi Tiết Loại Gói
**Endpoint:** `GET /api/PackageType/{id}`  
**Authorization:** `[AllowAnonymous]` - Không cần đăng nhập  
**Mô tả:** Lấy chi tiết loại gói theo ID

---

### 🏷️ AppointmentType (Loại Lịch Hẹn)

#### 1.29. Xem Tất Cả Loại Lịch Hẹn
**Endpoint:** `GET /api/AppointmentType`  
**Authorization:** `[AllowAnonymous]` - Không cần đăng nhập  
**Mô tả:** Lấy danh sách tất cả loại lịch hẹn  
**Dùng cho:** Dropdown loại lịch hẹn khi đặt lịch

#### 1.30. Xem Chi Tiết Loại Lịch Hẹn
**Endpoint:** `GET /api/AppointmentType/{id}`  
**Authorization:** `[AllowAnonymous]` - Không cần đăng nhập  
**Mô tả:** Lấy chi tiết loại lịch hẹn theo ID

---

### 🏠 HomeBooking (Đặt Dịch Vụ Tại Nhà)

#### 1.31. Xem Danh Sách Nhân Viên Phục Vụ Tại Nhà
**Endpoint:** `GET /api/HomeBooking/home-staff`  
**Authorization:** `[AllowAnonymous]` - Không cần đăng nhập  
**Mô tả:** Lấy danh sách tất cả nhân viên phục vụ tại nhà (Home Staff)  
**Dùng cho:** Trang chọn nhân viên cho dịch vụ tại nhà

#### 1.32. Xem Nhân Viên Có Thời Gian Rảnh ⭐
**Endpoint:** `GET /api/HomeBooking/free-home-staff?from={from}&to={to}&startTime={startTime}&endTime={endTime}`  
**Authorization:** `[AllowAnonymous]` - Không cần đăng nhập  
**Query Parameters:**
- `from`: DateOnly (yyyy-MM-dd)
- `to`: DateOnly (yyyy-MM-dd)
- `startTime`: TimeOnly (HH:mm:ss)
- `endTime`: TimeOnly (HH:mm:ss)  
**Mô tả:** Lấy danh sách nhân viên phục vụ tại nhà có thời gian rảnh trong khoảng thời gian cụ thể  
**Dùng cho:** Chọn nhân viên khi đặt dịch vụ tại nhà

---

### 💳 Transaction (Giao Dịch)

#### 1.33. Kiểm Tra Trạng Thái Thanh Toán
**Endpoint:** `GET /api/Transaction/check-status/{orderCode}`  
**Authorization:** `[AllowAnonymous]` - Không cần đăng nhập  
**Route Parameters:**
- `orderCode`: string  
**Mô tả:** Kiểm tra trạng thái thanh toán theo orderCode  
**Dùng cho:** Trang kiểm tra thanh toán, callback từ payment gateway

---

## 2. 🔐 API Cần Đăng Nhập - Xem Dữ Liệu Của Chính Mình

### 📋 Booking (Đặt Phòng)

#### 2.1. Xem Danh Sách Booking Của Mình ⭐
**Endpoint:** `GET /api/Booking`  
**Authorization:** `[Authorize]` - Cần đăng nhập  
**Mô tả:** Lấy danh sách booking của customer đang đăng nhập  
**Dùng cho:** Trang "Đơn đặt của tôi", Dashboard customer

#### 2.2. Xem Chi Tiết Booking
**Endpoint:** `GET /api/Booking/{id}`  
**Authorization:** `[Authorize]` - Cần đăng nhập  
**Mô tả:** Lấy chi tiết booking (customer chỉ xem được booking của mình)  
**Dùng cho:** Trang chi tiết đơn đặt

---

### 📅 Appointment (Lịch Hẹn)

#### 2.3. Xem Danh Sách Lịch Hẹn Của Mình ⭐
**Endpoint:** `GET /api/Appointment`  
**Authorization:** `[Authorize]` - Cần đăng nhập  
**Mô tả:** Lấy danh sách lịch hẹn của customer đang đăng nhập  
**Dùng cho:** Trang "Lịch hẹn của tôi", Dashboard customer

#### 2.4. Xem Chi Tiết Appointment
**Endpoint:** `GET /api/Appointment/{id}`  
**Authorization:** `[Authorize]` - Cần đăng nhập  
**Mô tả:** Lấy chi tiết lịch hẹn (customer chỉ xem được appointment của mình)  
**Dùng cho:** Trang chi tiết lịch hẹn

---

### 📄 Contract (Hợp Đồng)

#### 2.5. Xem Hợp Đồng Của Booking ⭐
**Endpoint:** `GET /api/Contract/my/{bookingId}`  
**Authorization:** `[Authorize]` - Cần đăng nhập  
**Route Parameters:**
- `bookingId`: int  
**Mô tả:** Khách xem hợp đồng của booking (chỉ xem được hợp đồng của mình)  
**Dùng cho:** Trang xem hợp đồng, trang chi tiết booking

---

### 📅 FamilySchedule (Lịch Sinh Hoạt Gia Đình)

#### 2.6. Xem Lịch Sinh Hoạt Gia Đình Của Mình ⭐
**Endpoint:** `GET /api/FamilySchedule/my-schedules`  
**Authorization:** `[Authorize]` - Cần đăng nhập  
**Mô tả:** Lấy lịch sinh hoạt gia đình theo ngày trong hợp đồng mới nhất của khách hàng hiện tại  
**Dùng cho:** Trang lịch sinh hoạt của tôi, Dashboard customer

#### 2.7. Xem Lịch Sinh Hoạt Theo Ngày
**Endpoint:** `GET /api/FamilySchedule/{date}`  
**Authorization:** `[Authorize]` - Cần đăng nhập  
**Route Parameters:**
- `date`: DateOnly (yyyy-MM-dd)  
**Mô tả:** Lấy lịch sinh hoạt gia đình theo ngày cụ thể  
**Dùng cho:** Xem lịch theo ngày cụ thể

#### 2.8. Xem Lịch Sinh Hoạt Theo Khoảng Ngày
**Endpoint:** `GET /api/FamilySchedule/date-range?dateFrom={dateFrom}&dateTo={dateTo}`  
**Authorization:** `[Authorize]` - Cần đăng nhập  
**Query Parameters:**
- `dateFrom`: DateOnly (yyyy-MM-dd)
- `dateTo`: DateOnly (yyyy-MM-dd)  
**Mô tả:** Lấy lịch sinh hoạt gia đình trong khoảng ngày  
**Dùng cho:** Xem lịch theo tuần/tháng

---

### 🍽️ MenuRecord (Bản Ghi Menu)

#### 2.9. Xem Menu Record Của Mình ⭐
**Endpoint:** `GET /api/MenuRecord/my`  
**Authorization:** `[Authorize(Roles = DefaultRoleName)]` - Cần đăng nhập (customer)  
**Mô tả:** Lấy MenuRecord của tài khoản hiện tại  
**Dùng cho:** Trang "Menu của tôi"

#### 2.10. Xem Menu Record Theo Ngày
**Endpoint:** `GET /api/MenuRecord/my/date?date={date}`  
**Authorization:** `[Authorize(Roles = DefaultRoleName)]` - Cần đăng nhập (customer)  
**Query Parameters:**
- `date`: DateOnly (yyyy-MM-dd)  
**Mô tả:** Lấy MenuRecord của tài khoản hiện tại theo ngày  
**Dùng cho:** Xem menu theo ngày cụ thể

#### 2.11. Xem Menu Record Theo Khoảng Ngày
**Endpoint:** `GET /api/MenuRecord/my/date-range?from={from}&to={to}`  
**Authorization:** `[Authorize(Roles = DefaultRoleName)]` - Cần đăng nhập (customer)  
**Query Parameters:**
- `from`: DateOnly (yyyy-MM-dd)
- `to`: DateOnly (yyyy-MM-dd)  
**Mô tả:** Lấy MenuRecord của tài khoản hiện tại theo khoảng ngày  
**Dùng cho:** Xem menu theo tuần/tháng

#### 2.12. Xem Chi Tiết Menu Record
**Endpoint:** `GET /api/MenuRecord/{id}`  
**Authorization:** `[Authorize]` - Cần đăng nhập  
**Mô tả:** Lấy MenuRecord theo ID (chỉ xem được của mình)

---

### 👨‍👩‍👧‍👦 FamilyProfile (Hồ Sơ Gia Đình)

#### 2.13. Xem Hồ Sơ Gia Đình Của Mình ⭐
**Endpoint:** `GET /api/FamilyProfile/GetMyFamilyProfiles`  
**Authorization:** `[Authorize]` - Cần đăng nhập  
**Mô tả:** Lấy danh sách hồ sơ gia đình của chính mình (phía Customer)  
**Dùng cho:** Trang "Hồ sơ gia đình của tôi"

---

### 💳 Transaction (Giao Dịch)

#### 2.14. Xem Giao Dịch Của Mình ⭐
**Endpoint:** `GET /api/Transaction`  
**Authorization:** `[Authorize]` - Cần đăng nhập  
**Mô tả:** Lấy giao dịch của customer đang đăng nhập  
**Dùng cho:** Trang "Lịch sử thanh toán", Dashboard customer

#### 2.15. Xem Chi Tiết Giao Dịch
**Endpoint:** `GET /api/Transaction/{id}`  
**Authorization:** `[Authorize]` - Cần đăng nhập  
**Mô tả:** Lấy chi tiết giao dịch theo ID (customer chỉ xem được của mình)  
**Dùng cho:** Trang chi tiết giao dịch

---

### 💬 Chat (Trò Chuyện)

#### 2.16. Xem Danh Sách Cuộc Hội Thoại Của Mình ⭐
**Endpoint:** `GET /api/Chat/conversations`  
**Authorization:** `[Authorize]` - Cần đăng nhập  
**Mô tả:** Lấy danh sách cuộc hội thoại của user đang đăng nhập  
**Dùng cho:** Trang danh sách chat, sidebar chat

#### 2.17. Xem Chi Tiết Cuộc Hội Thoại
**Endpoint:** `GET /api/Chat/conversations/{id}`  
**Authorization:** `[Authorize]` - Cần đăng nhập  
**Mô tả:** Lấy chi tiết cuộc hội thoại với messages (chỉ xem được conversation của mình)  
**Dùng cho:** Trang chat chi tiết

---

### 🔔 Notification (Thông Báo)

#### 2.18. Xem Thông Báo Của Mình ⭐
**Endpoint:** `GET /api/Notification/me`  
**Authorization:** `[Authorize]` - Cần đăng nhập  
**Mô tả:** Lấy thông báo cho người dùng hiện tại (sắp xếp theo thời gian mới nhất)  
**Dùng cho:** Trang thông báo, dropdown notification

#### 2.19. Xem Chi Tiết Thông Báo
**Endpoint:** `GET /api/Notification/{id}`  
**Authorization:** `[Authorize]` - Cần đăng nhập  
**Mô tả:** Lấy thông báo theo ID

---

### 💬 Feedback (Phản Hồi)

#### 2.20. Xem Tất Cả Phản Hồi
**Endpoint:** `GET /api/Feedback`  
**Authorization:** `[Authorize]` - Cần đăng nhập  
**Mô tả:** Lấy tất cả phản hồi trong hệ thống  
**Dùng cho:** Trang danh sách phản hồi

#### 2.21. Xem Phản Hồi Của Mình ⭐
**Endpoint:** `GET /api/Feedback/my-feedback`  
**Authorization:** `[Authorize]` - Cần đăng nhập  
**Mô tả:** Lấy phản hồi của khách hàng hiện tại  
**Dùng cho:** Trang "Phản hồi của tôi"

#### 2.22. Xem Chi Tiết Phản Hồi
**Endpoint:** `GET /api/Feedback/{id}`  
**Authorization:** `[Authorize]` - Cần đăng nhập  
**Mô tả:** Lấy chi tiết phản hồi theo ID

---

### 🎫 AmenityTicket (Vé Tiện Ích)

#### 2.23. Xem Vé Tiện Ích Của Mình ⭐
**Endpoint:** `GET /api/AmenityTicket/my-tickets`  
**Authorization:** `[Authorize(Roles = DefaultRoleName)]` - Cần đăng nhập (customer)  
**Mô tả:** Lấy tất cả vé tiện ích của người dùng đang đăng nhập  
**Dùng cho:** Trang "Vé tiện ích của tôi"

#### 2.24. Xem Chi Tiết Vé Tiện Ích
**Endpoint:** `GET /api/AmenityTicket/{id}`  
**Authorization:** `[Authorize]` - Cần đăng nhập  
**Mô tả:** Lấy chi tiết vé tiện ích theo ID (chỉ xem được của mình)

---

### 👤 Account (Tài Khoản)

#### 2.25. Xem Tài Khoản Hiện Tại ⭐
**Endpoint:** `GET /api/Account/GetCurrentAccount`  
**Authorization:** `[Authorize]` - Cần đăng nhập  
**Mô tả:** Lấy thông tin tài khoản đang đăng nhập (kèm thông tin gói dịch vụ nếu có)  
**Dùng cho:** Trang profile, header user info

#### 2.26. Xem Chi Tiết Tài Khoản Theo ID
**Endpoint:** `GET /api/Account/GetById/{id}`  
**Authorization:** `[Authorize]` - Cần đăng nhập  
**Mô tả:** Lấy chi tiết tài khoản theo ID

#### 2.27. Xem Tài Khoản Theo Email
**Endpoint:** `GET /api/Account/GetByEmail/{email}`  
**Authorization:** `[Authorize]` - Cần đăng nhập  
**Mô tả:** Lấy tài khoản theo email

#### 2.28. Xem Tài Khoản Theo Số Điện Thoại
**Endpoint:** `GET /api/Account/GetByPhone/{phone}`  
**Authorization:** `[Authorize]` - Cần đăng nhập  
**Mô tả:** Lấy tài khoản theo số điện thoại

---

### 🏥 MedicalRecord (Hồ Sơ Y Tế)

#### 2.29. Xem Hồ Sơ Y Tế Của Mình
**Endpoint:** `GET /api/MedicalRecord/{id}`  
**Authorization:** `[Authorize]` - Cần đăng nhập  
**Mô tả:** Lấy hồ sơ y tế theo ID (customer chỉ xem được của mình)  
**Dùng cho:** Trang xem hồ sơ y tế

---

### 🏠 Room (Phòng)

#### 2.30. Xem Phòng Trống
**Endpoint:** `GET /api/Room/empty`  
**Authorization:** `[Authorize]` - Cần đăng nhập  
**Mô tả:** Lấy danh sách phòng đang trống  
**Dùng cho:** Trang booking - chọn phòng trống

---

### 📦 Packages (Gói Dịch Vụ)

#### 2.31. Xem Gói Dịch Vụ Tại Nhà Của Mình ⭐
**Endpoint:** `GET /api/Packages/home/my`  
**Authorization:** `[Authorize(Roles = DefaultRoleName)]` - Cần đăng nhập (customer)  
**Mô tả:** Lấy danh sách gói dịch vụ tại nhà của khách hàng hiện tại  
**Dùng cho:** Trang "Gói dịch vụ tại nhà của tôi"

---

## 3. 🔐 API Cần Đăng Nhập - Xem Dữ Liệu Chung

### 💬 Chat (Trò Chuyện)

#### 3.1. Xem Chi Tiết Cuộc Hội Thoại (Đã Kiểm Tra Quyền)
**Endpoint:** `GET /api/Chat/conversations/{id}`  
**Authorization:** `[Authorize]` - Cần đăng nhập  
**Mô tả:** Lấy chi tiết cuộc hội thoại với messages (service tự kiểm tra quyền)  
**Lưu ý:** Service sẽ kiểm tra xem user có quyền xem conversation này không

---

### 🏥 MedicalRecord (Hồ Sơ Y Tế)

#### 3.2. Xem Hồ Sơ Y Tế (Đã Kiểm Tra Quyền)
**Endpoint:** `GET /api/MedicalRecord/{id}`  
**Authorization:** `[Authorize]` - Cần đăng nhập  
**Mô tả:** Lấy hồ sơ y tế theo ID (service tự kiểm tra quyền - customer chỉ xem được của mình)  
**Lưu ý:** Service sẽ kiểm tra xem user có quyền xem medical record này không

---

## 📌 Tóm Tắt Các API Quan Trọng Cho Customer

### ⭐ API Cho Trang Chủ / Danh Sách:
1. `GET /api/Packages/center` - Xem gói dịch vụ tại trung tâm
2. `GET /api/Room` - Xem danh sách phòng
3. `GET /api/RoomType/for-customer` - Xem loại phòng
4. `GET /api/Menu` - Xem danh sách menu
5. `GET /api/Food` - Xem danh sách món ăn
6. `GET /api/Activities` - Xem danh sách hoạt động
7. `GET /api/AmenityService` - Xem dịch vụ tiện ích
8. `GET /api/care-plan-details/by-package/{packageId}` - Xem kế hoạch chăm sóc theo gói

### ⭐ API Cho Trang Booking:
1. `GET /api/Room/available?startDate=...&endDate=...` - Xem phòng có sẵn
2. `GET /api/Room/booking-periods` - Xem lịch đặt phòng
3. `GET /api/HomeBooking/free-home-staff` - Xem nhân viên rảnh (dịch vụ tại nhà)

### ⭐ API Cho Dashboard Customer:
1. `GET /api/Booking` - Xem booking của mình
2. `GET /api/Appointment` - Xem appointment của mình
3. `GET /api/FamilySchedule/my-schedules` - Xem lịch sinh hoạt
4. `GET /api/MenuRecord/my` - Xem menu record của mình
5. `GET /api/Transaction` - Xem giao dịch của mình
6. `GET /api/Chat/conversations` - Xem cuộc hội thoại
7. `GET /api/Notification/me` - Xem thông báo
8. `GET /api/Account/GetCurrentAccount` - Xem thông tin tài khoản

### ⭐ API Cho Trang Chi Tiết:
1. `GET /api/Booking/{id}` - Chi tiết booking
2. `GET /api/Appointment/{id}` - Chi tiết appointment
3. `GET /api/Contract/my/{bookingId}` - Xem hợp đồng
4. `GET /api/Packages/{id}` - Chi tiết gói dịch vụ
5. `GET /api/Room/{id}` - Chi tiết phòng

---

## 🔐 Lưu Ý Về Authorization

- **`[AllowAnonymous]`** hoặc **không có `[Authorize]`**: Không cần đăng nhập - Customer có thể truy cập
- **`[Authorize]`**: Cần đăng nhập (bất kỳ role nào, bao gồm customer)
- **`[Authorize(Roles = DefaultRoleName)]`**: Chỉ customer (role mặc định)
- **`[Authorize(Roles = "admin,manager,staff")]`**: Chỉ admin/manager/staff - Customer KHÔNG được truy cập

---

## 📝 Ghi Chú

1. Tất cả các API GET đều trả về dữ liệu dạng **JSON**.

2. Các API có kiểm tra quyền trong **Service Layer** sẽ tự động kiểm tra xem customer có quyền xem dữ liệu đó không (ví dụ: customer chỉ xem được booking/appointment của chính mình).

3. Các API public có thể được cache ở frontend để tăng hiệu suất.

4. Khi gọi API cần đăng nhập, phải gửi kèm **Bearer Token** trong header:
   ```
   Authorization: Bearer {token}
   ```

5. Format ngày tháng: `DateOnly` sử dụng format `yyyy-MM-dd` (ví dụ: `2024-01-15`)

6. Format thời gian: `TimeOnly` sử dụng format `HH:mm:ss` (ví dụ: `14:30:00`)

---

**Cập nhật lần cuối:** Dựa trên code trong thư mục `WebAPI/Controllers`  
**Phiên bản:** 1.0
