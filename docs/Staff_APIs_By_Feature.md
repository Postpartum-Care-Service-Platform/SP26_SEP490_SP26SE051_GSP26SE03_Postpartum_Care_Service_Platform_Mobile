# 📋 Mapping Tính Năng → API Cho Staff

Tài liệu này mapping chi tiết từng **tính năng** mà staff cần thực hiện với các **API cụ thể** cần sử dụng.

---

## 📄 1. HỢP ĐỒNG (Contract)

### Yêu Cầu:
- **Bảng HTML** (không có chữ ký)
- **Bảng hình ảnh** được upload lên (có nút "Xem hợp đồng hoàn thiện")

### API Cần Sử Dụng:

#### 1.1. Xem Danh Sách Hợp Đồng
**API:** `GET /api/Contract/all`  
**Authorization:** `admin,manager,staff`  
**Mô tả:** Lấy tất cả hợp đồng để hiển thị trong danh sách  
**Dùng cho:** Trang danh sách hợp đồng

#### 1.2. Xem Chi Tiết Hợp Đồng (Bảng HTML) ⭐
**API:** `GET /api/Contract/{id}`  
**Authorization:** `admin,manager,staff`  
**Mô tả:** **API chính** - Lấy chi tiết hợp đồng để hiển thị **bảng HTML không có chữ ký**  
**Response:** Bao gồm field `Content` (HTML) và các thông tin hợp đồng  
**Dùng cho:** Hiển thị nội dung hợp đồng dạng HTML

#### 1.3. Upload Hợp Đồng Đã Ký (Bảng Hình Ảnh) ⭐
**API:** `PUT /api/Contract/{id}/upload-signed`  
**Authorization:** `admin,manager,staff`  
**Body:** `UploadSignedContractRequest` (chứa URL hình ảnh hợp đồng đã ký)  
**Mô tả:** **API chính** - Upload hình ảnh hợp đồng đã ký lên hệ thống  
**Dùng cho:** Nút "Upload hợp đồng đã ký"

#### 1.4. Xem Hợp Đồng Hoàn Thiện (Hình Ảnh Đã Upload) ⭐
**API:** `GET /api/Contract/{id}`  
**Authorization:** `admin,manager,staff`  
**Mô tả:** Sau khi upload, gọi lại API này để lấy thông tin hợp đồng (bao gồm field hình ảnh đã upload)  
**Response:** Bao gồm field `SignedContractImageUrl` hoặc tương tự  
**Dùng cho:** Nút "Xem hợp đồng hoàn thiện" - hiển thị hình ảnh hợp đồng đã ký

#### 1.5. Cập Nhật Nội Dung Hợp Đồng ⭐
**API:** `PUT /api/Contract/{id}/update-content`  
**Authorization:** `admin,manager,staff`  
**Body:** `UpdateContractContentRequest`  
**Mô tả:** **API chính** - Cập nhật nội dung hợp đồng (thông tin khách hàng, ngày hiệu lực, giá cả, v.v.)  
**Dùng cho:** Nút "Chỉnh sửa hợp đồng" hoặc form cập nhật thông tin hợp đồng

**Ví dụ Body:**
```json
{
  "customerName": "Nguyễn Văn A",
  "customerPhone": "0123456789",
  "customerAddress": "123 Đường ABC, Quận XYZ",
  "effectiveFrom": "2024-01-15",
  "effectiveTo": "2024-02-15",
  "checkinDate": "2024-01-15",
  "checkoutDate": "2024-02-15",
  "totalPrice": 10000000,
  "discountAmount": 500000,
  "finalAmount": 9500000
}
```

**Lưu ý:** 
- Tất cả các field đều là optional (nullable)
- Chỉ cần gửi các field muốn cập nhật
- Service sẽ chỉ cập nhật các field được gửi lên

#### 1.6. Gửi Hợp Đồng Cho Khách Xem/Ký ⭐
**API:** `PUT /api/Contract/{id}/send`  
**Authorization:** `admin,manager,staff`  
**Mô tả:** **API chính** - Gửi hợp đồng cho khách hàng xem và ký (sau khi staff đã kiểm tra nội dung)  
**Response:** `{ "message": "..." }` (thông báo kết quả gửi)  
**Dùng cho:** Nút "Gửi khách" trên màn hình quản lý hợp đồng của staff

#### 1.7. Xuất PDF Hợp Đồng
**API:** `GET /api/Contract/{id}/export-pdf`  
**Authorization:** `admin,manager,staff`  
**Mô tả:** Tải xuống file PDF của hợp đồng  
**Response:** File PDF  
**Dùng cho:** Nút "Tải PDF"

#### 1.8. Tạo Hợp Đồng Từ Booking
**API:** `POST /api/Contract/from-booking/{bookingId}`  
**Authorization:** `admin,manager,staff`  
**Mô tả:** Tạo hợp đồng tự động từ booking  
**Dùng cho:** Tạo hợp đồng nhanh từ booking đã có

#### 1.9. Preview Hợp Đồng Trước Khi Tạo
**API:** `GET /api/Contract/preview/{bookingId}`  
**Authorization:** `admin,manager,staff`  
**Mô tả:** Xem trước nội dung hợp đồng từ booking  
**Dùng cho:** Preview trước khi tạo chính thức

---

## 👨‍⚕️ 2. STAFF SCHEDULE - Xem Lịch Làm Việc

### Yêu Cầu:
- Staff xem lịch làm việc của mình

### API Cần Sử Dụng:

#### 2.1. Xem Lịch Làm Việc Của Mình ⭐
**API:** `GET /api/StaffSchedule/me?from={dateFrom}&to={dateTo}`  
**Authorization:** `staff`  
**Query Parameters:**
- `from`: DateOnly (yyyy-MM-dd) - Ngày bắt đầu
- `to`: DateOnly (yyyy-MM-dd) - Ngày kết thúc  
**Mô tả:** **API chính** - Staff xem lịch làm việc của chính mình trong khoảng ngày  
**Dùng cho:** 
- Trang **Staff Home** - hiển thị lịch hôm nay/tuần này
- Trang **Staff Center** - hiển thị lịch theo tuần/tháng

**Ví dụ:**
```
GET /api/StaffSchedule/me?from=2024-01-01&to=2024-01-31
```

---

## 🍽️ 3. THÊM STAFF MENU RECORD

### Yêu Cầu:
- Staff có thể thêm Menu Record cho khách hàng

### API Cần Sử Dụng:

#### 3.1. Tạo Menu Record Cho Khách Hàng ⭐
**API:** `POST /api/MenuRecord/by-staff?customerId={customerId}`  
**Authorization:** `staff`  
**Query Parameters:**
- `customerId`: Guid - ID của khách hàng  
**Body:** `List<CreateMenuRecordRequest>`  
**Mô tả:** **API chính** - Staff tạo menu record cho khách hàng  
**Dùng cho:** Trang "Thêm Menu Record" khi staff đang xem profile khách hàng

**Ví dụ Body:**
```json
[
  {
    "menuId": 1,
    "date": "2024-01-15",
    "mealType": "Breakfast"
  },
  {
    "menuId": 2,
    "date": "2024-01-15",
    "mealType": "Lunch"
  }
]
```

#### 3.2. Xem Menu Record Của Khách Hàng
**API:** `GET /api/MenuRecord/customer/{customerId}`  
**Authorization:** `staff`  
**Mô tả:** Xem tất cả menu record của một khách hàng  
**Dùng cho:** Hiển thị danh sách menu record khi xem profile khách hàng

#### 3.3. Xem Menu Record Theo Ngày
**API:** `GET /api/MenuRecord/customer/{customerId}/date?date={date}`  
**Authorization:** `staff`  
**Query Parameters:**
- `date`: DateOnly (yyyy-MM-dd)  
**Mô tả:** Xem menu record của khách hàng theo ngày cụ thể

#### 3.4. Cập Nhật Menu Record
**API:** `PUT /api/MenuRecord/by-staff?customerId={customerId}`  
**Authorization:** `staff`  
**Body:** `List<UpdateMenuRecordRequest>`  
**Mô tả:** Cập nhật menu record của khách hàng

#### 3.5. Xóa Menu Record
**API:** `DELETE /api/MenuRecord/by-staff/{id}?customerId={customerId}`  
**Authorization:** `staff`  
**Mô tả:** Xóa menu record của khách hàng

---

## ✅ 4. STAFF CONFIRM - Xác Nhận Appointment và Booking

### Yêu Cầu:
- Staff xác nhận Appointment
- Staff xác nhận Booking

### API Cần Sử Dụng:

#### 4.1. Xem Appointment Được Assign Cho Mình ⭐
**API:** `GET /api/Appointment/my-assigned`  
**Authorization:** `admin,manager,staff`  
**Mô tả:** Lấy danh sách appointment được phân công cho staff đang đăng nhập  
**Dùng cho:** Trang **Staff Confirm** - hiển thị danh sách appointment cần xác nhận

#### 4.2. Xem Chi Tiết Appointment
**API:** `GET /api/Appointment/{id}`  
**Authorization:** `[Authorize]`  
**Mô tả:** Lấy chi tiết appointment để xem trước khi xác nhận

#### 4.3. Xác Nhận Appointment ⭐
**API:** `PUT /api/Appointment/{id}/confirm`  
**Authorization:** `admin,manager,staff`  
**Mô tả:** **API chính** - Staff xác nhận appointment  
**Dùng cho:** Nút "Xác nhận" trên trang **Staff Confirm - Appointment**

#### 4.4. Hoàn Thành Appointment ⭐
**API:** `PUT /api/Appointment/{id}/complete`  
**Authorization:** `admin,manager,staff`  
**Mô tả:** **API chính** - Staff đánh dấu appointment đã hoàn thành  
**Dùng cho:** Nút "Hoàn thành" sau khi appointment đã xong

#### 4.5. Xem Tất Cả Booking ⭐
**API:** `GET /api/Booking/all`  
**Authorization:** `admin,manager,staff`  
**Mô tả:** Lấy danh sách tất cả booking trong hệ thống  
**Dùng cho:** Trang **Staff Confirm** - hiển thị danh sách booking cần xác nhận

#### 4.6. Xem Chi Tiết Booking
**API:** `GET /api/Booking/{id}`  
**Authorization:** `[Authorize]`  
**Mô tả:** Lấy chi tiết booking để xem trước khi xác nhận

#### 4.7. Xác Nhận Booking ⭐
**API:** `PUT /api/Booking/{id}/confirm`  
**Authorization:** `admin,manager,staff`  
**Mô tả:** **API chính** - Staff xác nhận booking  
**Dùng cho:** Nút "Xác nhận" trên trang **Staff Confirm - Booking**

#### 4.8. Hoàn Thành Booking ⭐
**API:** `PUT /api/Booking/{id}/complete`  
**Authorization:** `admin,manager,staff`  
**Mô tả:** **API chính** - Staff hoàn thành booking  
**Điều kiện nghiệp vụ:** 
- Đã thanh toán toàn bộ chi phí
- Đã check-out (kể cả trường hợp out giữa chừng)  
**Lưu ý:** Service sẽ tự động kiểm tra các điều kiện này  
**Dùng cho:** Nút "Hoàn thành" trên trang **Staff Confirm - Booking**

---

## 💬 5. CHAT - Staff Chỉ Được Chat Nếu Được Phân Công/Chỉ Định

### Yêu Cầu:
- Staff chỉ được chat với khách hàng nếu được phân công/chỉ định

### API Cần Sử Dụng:

#### 5.1. Xem Yêu Cầu Hỗ Trợ Đang Chờ ⭐
**API:** `GET /api/Chat/support-requests`  
**Authorization:** `admin,manager,staff`  
**Mô tả:** Lấy danh sách yêu cầu hỗ trợ chưa được nhận (chưa có staff nào nhận)  
**Dùng cho:** 
- Trang **Staff Home** - hiển thị số yêu cầu chờ
- Trang **Staff Center** - danh sách yêu cầu chờ

#### 5.2. Xem Yêu Cầu Hỗ Trợ Của Mình ⭐
**API:** `GET /api/Chat/support-requests/my`  
**Authorization:** `admin,manager,staff`  
**Mô tả:** Lấy danh sách yêu cầu hỗ trợ mà staff đang xử lý  
**Dùng cho:** 
- Trang **Staff Home** - hiển thị các cuộc chat đang xử lý
- Trang **Staff Center** - danh sách conversation đang phụ trách

#### 5.3. Nhận Yêu Cầu Hỗ Trợ (Phân Công/Chỉ Định) ⭐
**API:** `PUT /api/Chat/support-requests/{id}/accept`  
**Authorization:** `admin,manager,staff`  
**Mô tả:** **API BẮT BUỘC** - Staff nhận yêu cầu hỗ trợ  
**Lưu ý:** Chỉ sau khi gọi API này, staff mới được phép chat trong conversation đó  
**Dùng cho:** Nút "Nhận hỗ trợ" trên danh sách yêu cầu chờ

#### 5.4. Xem Danh Sách Cuộc Hội Thoại Của Mình
**API:** `GET /api/Chat/conversations`  
**Authorization:** `[Authorize]`  
**Mô tả:** Lấy danh sách cuộc hội thoại của staff (bao gồm cả conversation đã accept)

#### 5.5. Xem Chi Tiết Cuộc Hội Thoại
**API:** `GET /api/Chat/conversations/{id}`  
**Authorization:** `[Authorize]`  
**Mô tả:** Lấy chi tiết cuộc hội thoại với messages  
**Lưu ý:** Service sẽ kiểm tra xem staff có quyền xem conversation này không (phải đã accept)

#### 5.6. Gửi Tin Nhắn (Sau Khi Đã Accept) ⭐
**API:** `POST /api/Chat/conversations/{id}/staff-message`  
**Authorization:** `admin,manager,staff`  
**Body:** `SendMessageRequest` (chứa `Content`)  
**Mô tả:** **API chính** - Staff gửi tin nhắn vào conversation  
**Lưu ý:** Chỉ được gửi sau khi đã accept support request. Backend sẽ kiểm tra điều kiện này  
**Dùng cho:** Gửi tin nhắn trong trang chat

**Ví dụ Body:**
```json
{
  "content": "Xin chào, tôi có thể giúp gì cho bạn?"
}
```

#### 5.7. Đánh Dấu Đã Giải Quyết
**API:** `PUT /api/Chat/support-requests/{id}/resolve`  
**Authorization:** `admin,manager,staff`  
**Mô tả:** Staff đánh dấu yêu cầu hỗ trợ đã được giải quyết  
**Dùng cho:** Nút "Đánh dấu đã giải quyết"

#### 5.8. Đánh Dấu Đã Đọc
**API:** `PUT /api/Chat/conversations/{id}/messages/read`  
**Authorization:** `[Authorize]`  
**Mô tả:** Đánh dấu tất cả messages trong conversation là đã đọc

---

## 🏠 6. STAFF HOME & CENTER

### Yêu Cầu:
- Gắn API để staff xem Staff Home
- Gắn API để staff xem Center

### API Cần Sử Dụng:

#### 6.1. Xem Lịch Làm Việc Của Mình ⭐
**API:** `GET /api/StaffSchedule/me?from={dateFrom}&to={dateTo}`  
**Authorization:** `staff`  
**Mô tả:** Xem lịch làm việc trong khoảng ngày  
**Dùng cho:** 
- **Staff Home** - lịch hôm nay/tuần này
- **Staff Center** - lịch theo tuần/tháng

**Ví dụ cho hôm nay:**
```
GET /api/StaffSchedule/me?from=2024-01-15&to=2024-01-15
```

#### 6.2. Xem Appointment Được Assign Cho Mình ⭐
**API:** `GET /api/Appointment/my-assigned`  
**Authorization:** `admin,manager,staff`  
**Mô tả:** Xem appointment được phân công cho mình  
**Dùng cho:** 
- **Staff Home** - appointment hôm nay
- **Staff Center** - danh sách appointment

#### 6.3. Xem Yêu Cầu Hỗ Trợ Đang Xử Lý ⭐
**API:** `GET /api/Chat/support-requests/my`  
**Authorization:** `admin,manager,staff`  
**Mô tả:** Xem yêu cầu hỗ trợ mà mình đang xử lý  
**Dùng cho:** 
- **Staff Home** - số lượng yêu cầu đang xử lý
- **Staff Center** - danh sách conversation đang phụ trách

#### 6.4. Xem Tất Cả Booking ⭐
**API:** `GET /api/Booking/all`  
**Authorization:** `admin,manager,staff`  
**Mô tả:** Xem tất cả booking trong hệ thống  
**Dùng cho:** 
- **Staff Home** - booking cần xử lý hôm nay
- **Staff Center** - danh sách booking

#### 6.5. Xem Hợp Đồng Chưa Được Lên Lịch ⭐
**API:** `GET /api/Contract/no-schedule`  
**Authorization:** `admin,manager,staff`  
**Mô tả:** Xem hợp đồng chưa được tạo lịch sinh hoạt gia đình  
**Dùng cho:** 
- **Staff Home** - thông báo hợp đồng cần lên lịch
- **Staff Center** - danh sách hợp đồng chưa lên lịch

#### 6.6. Xem Thông Báo Của Mình
**API:** `GET /api/Notification/me`  
**Authorization:** `[Authorize]`  
**Mô tả:** Xem thông báo của staff đang đăng nhập  
**Dùng cho:** 
- **Staff Home** - thông báo mới
- **Staff Center** - danh sách thông báo

---

## 👤 7. XEM PROFILE KHÁCH HÀNG

### Yêu Cầu:
- Gắn API để staff xem profile khách hàng

### API Cần Sử Dụng:

#### 7.1. Xem Hồ Sơ Gia Đình Của Khách Hàng ⭐
**API:** `GET /api/FamilyProfile/GetByCustomerId/{customerId}`  
**Authorization:** `admin,staff` (AdminOrStaff)  
**Route Parameters:**
- `customerId`: Guid - ID của khách hàng  
**Mô tả:** **API chính** - Lấy danh sách hồ sơ gia đình của một khách hàng  
**Dùng cho:** Trang xem profile khách hàng - tab "Hồ sơ gia đình"

#### 7.2. Xem Menu Record Của Khách Hàng ⭐
**API:** `GET /api/MenuRecord/customer/{customerId}`  
**Authorization:** `staff`  
**Mô tả:** **API chính** - Lấy tất cả menu record của một khách hàng  
**Dùng cho:** Trang xem profile khách hàng - tab "Menu Record"

#### 7.3. Xem Menu Record Theo Ngày
**API:** `GET /api/MenuRecord/customer/{customerId}/date?date={date}`  
**Authorization:** `staff`  
**Mô tả:** Xem menu record của khách hàng theo ngày cụ thể

#### 7.4. Xem Menu Record Theo Khoảng Ngày
**API:** `GET /api/MenuRecord/customer/{customerId}/date-range?from={from}&to={to}`  
**Authorization:** `staff`  
**Mô tả:** Xem menu record của khách hàng trong khoảng ngày

#### 7.5. Xem Hồ Sơ Y Tế Của Khách Hàng ⭐
**API:** `GET /api/MedicalRecord/customer/{customerId}`  
**Authorization:** `admin,manager,staff`  
**Mô tả:** **API chính** - Lấy hồ sơ y tế của một khách hàng  
**Dùng cho:** Trang xem profile khách hàng - tab "Hồ sơ y tế"

#### 7.6. Xem Booking Của Khách Hàng
**API:** `GET /api/Booking/all` (sau đó filter theo customerId ở frontend)  
**Hoặc:** `GET /api/Booking/{id}` nếu biết bookingId  
**Authorization:** `admin,manager,staff`  
**Mô tả:** Xem booking của khách hàng  
**Dùng cho:** Trang xem profile khách hàng - tab "Lịch sử đặt phòng"

#### 7.7. Xem Appointment Của Khách Hàng
**API:** `GET /api/Appointment/all` (sau đó filter theo customerId ở frontend)  
**Hoặc:** `GET /api/Appointment/{id}` nếu biết appointmentId  
**Authorization:** `admin,manager,staff`  
**Mô tả:** Xem appointment của khách hàng  
**Dùng cho:** Trang xem profile khách hàng - tab "Lịch hẹn"

#### 7.8. Xem Giao Dịch Của Khách Hàng
**API:** `GET /api/Transaction/all` (sau đó filter theo customerId ở frontend)  
**Hoặc:** `GET /api/Transaction/{id}` nếu biết transactionId  
**Authorization:** `admin,manager,staff`  
**Mô tả:** Xem giao dịch của khách hàng  
**Dùng cho:** Trang xem profile khách hàng - tab "Lịch sử thanh toán"

#### 7.9. Xem Thông Tin Tài Khoản Khách Hàng
**API:** `GET /api/Account/GetById/{customerId}`  
**Authorization:** `[Authorize]`  
**Mô tả:** Xem thông tin tài khoản của khách hàng  
**Dùng cho:** Trang xem profile khách hàng - phần thông tin cơ bản

---

## 📅 8. TẠO LỊCH CHO GIA ĐÌNH KHI CHECK-IN

### Yêu Cầu:
- Gắn API để tạo lịch cho gia đình nếu gia đình đó tới check-in
- **Điều kiện:** Phải thanh toán đầy đủ

### API Cần Sử Dụng:

#### 8.1. Kiểm Tra Thanh Toán Đầy Đủ ⭐
**API:** `GET /api/Transaction/all`  
**Authorization:** `admin,manager,staff`  
**Mô tả:** Lấy tất cả giao dịch để kiểm tra trạng thái thanh toán  
**Lưu ý:** Cần filter theo `bookingId` hoặc `customerId` và kiểm tra:
- Tổng số tiền đã thanh toán >= Tổng giá trị booking
- Hoặc kiểm tra flag `IsFullyPaid` trong response của Booking/Contract

**Hoặc kiểm tra qua Booking:**
**API:** `GET /api/Booking/{id}`  
**Mô tả:** Response sẽ có thông tin về trạng thái thanh toán (ví dụ: `IsFullyPaid`, `PaymentStatus`, v.v.)

**Hoặc kiểm tra qua Contract:**
**API:** `GET /api/Contract/{id}`  
**Mô tả:** Response có thể có thông tin về trạng thái thanh toán

#### 8.2. Tạo Lịch Sinh Hoạt Gia Đình ⭐
**API:** `POST /api/FamilySchedule`  
**Authorization:** `staff,manager` (StaffOrManager)  
**Body:** `CreateFamilyScheduleRequest`  
**Mô tả:** **API chính** - Tạo lịch sinh hoạt gia đình khi khách check-in  
**Điều kiện nghiệp vụ:** 
- Phải thanh toán đầy đủ (kiểm tra ở bước 8.1)
- Service sẽ tự động dựa trên hợp đồng mới nhất của khách hàng để tạo lịch  
**Dùng cho:** Nút "Tạo lịch sinh hoạt" sau khi khách check-in

**Ví dụ Body:**
```json
{
  "customerId": "guid-customer-id",
  "contractId": 1  // ID hợp đồng mới nhất
}
```

**Lưu ý:** 
- Service sẽ tự động tạo lịch dựa trên gói dịch vụ trong hợp đồng
- Chỉ tạo được khi đã thanh toán đủ (backend sẽ kiểm tra)

#### 8.3. Xem Lịch Sinh Hoạt Đã Tạo
**API:** `GET /api/FamilySchedule/{date}` hoặc `GET /api/FamilySchedule/date-range?dateFrom={dateFrom}&dateTo={dateTo}`  
**Authorization:** `[Authorize]`  
**Mô tả:** Xem lịch sinh hoạt gia đình đã được tạo

---

## 📌 9. BOOKING - Hủy và Hoàn Thành

### Yêu Cầu:
- **Hủy booking** nếu:
  - Chưa hoàn thành đơn
  - Không tới check-in
- **Hoàn thành booking** nếu:
  - Đã thanh toán toàn bộ chi phí
  - Đã check-out (kể cả trường hợp out giữa chừng)

### API Cần Sử Dụng:

#### 9.1. Xem Chi Tiết Booking
**API:** `GET /api/Booking/{id}`  
**Authorization:** `[Authorize]`  
**Mô tả:** Xem chi tiết booking để kiểm tra trạng thái trước khi hủy/hoàn thành

#### 9.2. Hủy Booking ⭐
**API:** `PUT /api/Booking/{id}/cancel`  
**Authorization:** `[Authorize]`  
**Mô tả:** **API chính** - Hủy booking  
**Điều kiện nghiệp vụ:**
- Chưa hoàn thành đơn (Status != Completed)
- Không tới check-in (CheckInDate == null)  
**Lưu ý:** Service sẽ tự động kiểm tra các điều kiện này. Nếu không thỏa mãn sẽ trả về lỗi  
**Dùng cho:** Nút "Hủy booking" trên trang chi tiết booking

**Flow:**
1. Staff xem chi tiết booking (`GET /api/Booking/{id}`)
2. Kiểm tra trạng thái:
   - Nếu `Status != "Completed"` và `CheckInDate == null` → Hiển thị nút "Hủy"
   - Nếu không → Ẩn nút "Hủy"
3. Khi bấm "Hủy" → Gọi `PUT /api/Booking/{id}/cancel`

#### 9.3. Hoàn Thành Booking ⭐
**API:** `PUT /api/Booking/{id}/complete`  
**Authorization:** `admin,manager,staff`  
**Mô tả:** **API chính** - Hoàn thành booking  
**Điều kiện nghiệp vụ:**
- Đã thanh toán toàn bộ chi phí (IsFullyPaid == true)
- Đã check-out (CheckOutDate != null, kể cả out giữa chừng)  
**Lưu ý:** Service sẽ tự động kiểm tra các điều kiện này. Nếu không thỏa mãn sẽ trả về lỗi  
**Dùng cho:** Nút "Hoàn thành booking" trên trang chi tiết booking

**Flow:**
1. Staff xem chi tiết booking (`GET /api/Booking/{id}`)
2. Kiểm tra điều kiện:
   - Kiểm tra thanh toán: `GET /api/Transaction/all` (filter theo bookingId) hoặc kiểm tra `IsFullyPaid` trong response booking
   - Kiểm tra check-out: `CheckOutDate != null` trong response booking
3. Nếu cả 2 điều kiện đều thỏa mãn → Hiển thị nút "Hoàn thành"
4. Khi bấm "Hoàn thành" → Gọi `PUT /api/Booking/{id}/complete`

#### 9.4. Kiểm Tra Thanh Toán
**API:** `GET /api/Transaction/all`  
**Authorization:** `admin,manager,staff`  
**Mô tả:** Lấy tất cả giao dịch để kiểm tra thanh toán  
**Lưu ý:** Cần filter theo `bookingId` hoặc `customerId` và tính tổng số tiền đã thanh toán

**Hoặc kiểm tra qua Booking:**
**API:** `GET /api/Booking/{id}`  
**Mô tả:** Response có thể có field `IsFullyPaid`, `TotalPaid`, `TotalAmount` để so sánh

---

## 📊 TÓM TẮT MAPPING THEO TÍNH NĂNG

### 📄 Hợp Đồng (2 Bảng)
| Tính Năng | API | Method |
|-----------|-----|--------|
| Xem bảng HTML (không chữ ký) | `GET /api/Contract/{id}` | GET |
| Upload bảng hình ảnh có chữ ký | `PUT /api/Contract/{id}/upload-signed` | PUT |
| Xem hợp đồng hoàn thiện (hình ảnh) | `GET /api/Contract/{id}` | GET |
| Gửi hợp đồng cho khách xem/ký | `PUT /api/Contract/{id}/send` | PUT |
| Xuất PDF hợp đồng | `GET /api/Contract/{id}/export-pdf` | GET |
| Cập nhật nội dung hợp đồng | `PUT /api/Contract/{id}/update-content` | PUT |
| Xem danh sách hợp đồng | `GET /api/Contract/all` | GET |

### 👨‍⚕️ Staff Schedule
| Tính Năng | API | Method |
|-----------|-----|--------|
| Xem lịch làm việc | `GET /api/StaffSchedule/me?from={from}&to={to}` | GET |

### 🍽️ Thêm Staff Menu Record
| Tính Năng | API | Method |
|-----------|-----|--------|
| Tạo menu record cho khách | `POST /api/MenuRecord/by-staff?customerId={customerId}` | POST |
| Xem menu record của khách | `GET /api/MenuRecord/customer/{customerId}` | GET |
| Cập nhật menu record | `PUT /api/MenuRecord/by-staff?customerId={customerId}` | PUT |
| Xóa menu record | `DELETE /api/MenuRecord/by-staff/{id}?customerId={customerId}` | DELETE |

### ✅ Staff Confirm
| Tính Năng | API | Method |
|-----------|-----|--------|
| Xem appointment được assign | `GET /api/Appointment/my-assigned` | GET |
| Xác nhận appointment | `PUT /api/Appointment/{id}/confirm` | PUT |
| Hoàn thành appointment | `PUT /api/Appointment/{id}/complete` | PUT |
| Xem booking cần xác nhận | `GET /api/Booking/all` | GET |
| Xác nhận booking | `PUT /api/Booking/{id}/confirm` | PUT |
| Hoàn thành booking | `PUT /api/Booking/{id}/complete` | PUT |

### 💬 Chat (Chỉ Chat Khi Được Phân Công)
| Tính Năng | API | Method |
|-----------|-----|--------|
| Xem yêu cầu hỗ trợ chờ | `GET /api/Chat/support-requests` | GET |
| Xem yêu cầu đang xử lý | `GET /api/Chat/support-requests/my` | GET |
| Nhận yêu cầu hỗ trợ (BẮT BUỘC) | `PUT /api/Chat/support-requests/{id}/accept` | PUT |
| Gửi tin nhắn (sau khi accept) | `POST /api/Chat/conversations/{id}/staff-message` | POST |
| Đánh dấu đã giải quyết | `PUT /api/Chat/support-requests/{id}/resolve` | PUT |

### 🏠 Staff Home & Center
| Tính Năng | API | Method |
|-----------|-----|--------|
| Lịch làm việc | `GET /api/StaffSchedule/me?from={from}&to={to}` | GET |
| Appointment được assign | `GET /api/Appointment/my-assigned` | GET |
| Yêu cầu hỗ trợ đang xử lý | `GET /api/Chat/support-requests/my` | GET |
| Booking cần xử lý | `GET /api/Booking/all` | GET |
| Hợp đồng chưa lên lịch | `GET /api/Contract/no-schedule` | GET |
| Thông báo | `GET /api/Notification/me` | GET |

### 👤 Xem Profile Khách Hàng
| Tính Năng | API | Method |
|-----------|-----|--------|
| Hồ sơ gia đình | `GET /api/FamilyProfile/GetByCustomerId/{customerId}` | GET |
| Menu record | `GET /api/MenuRecord/customer/{customerId}` | GET |
| Hồ sơ y tế | `GET /api/MedicalRecord/customer/{customerId}` | GET |
| Thông tin tài khoản | `GET /api/Account/GetById/{customerId}` | GET |

### 📅 Tạo Lịch Gia Đình Khi Check-in
| Tính Năng | API | Method |
|-----------|-----|--------|
| Kiểm tra thanh toán đủ | `GET /api/Transaction/all` hoặc `GET /api/Booking/{id}` | GET |
| Tạo lịch sinh hoạt | `POST /api/FamilySchedule` | POST |

### 📌 Booking - Hủy & Hoàn Thành
| Tính Năng | API | Method |
|-----------|-----|--------|
| Hủy booking | `PUT /api/Booking/{id}/cancel` | PUT |
| Hoàn thành booking | `PUT /api/Booking/{id}/complete` | PUT |
| Kiểm tra điều kiện | `GET /api/Booking/{id}` | GET |

---

## 🔐 Lưu Ý Về Authorization

Tất cả các API trên đều yêu cầu:
- **Bearer Token** trong header: `Authorization: Bearer {token}`
- Role phù hợp (thường là `admin,manager,staff` hoặc chỉ `staff`)

---

## 📝 Ghi Chú Quan Trọng

1. **Điều kiện nghiệp vụ** được kiểm tra trong **Service Layer**, không phải Controller. Frontend chỉ cần:
   - Gọi API đúng lúc
   - Xử lý response/error từ backend
   - Hiển thị/ẩn nút dựa trên trạng thái từ API

2. **Staff chỉ được chat** sau khi đã **accept support request**. Backend sẽ kiểm tra điều kiện này trong `SendStaffMessageAsync`.

3. **Tạo lịch gia đình** yêu cầu:
   - Role `staff,manager` (StaffOrManager)
   - Đã thanh toán đủ (backend kiểm tra)
   - Service sẽ tự động dựa trên hợp đồng mới nhất của khách hàng

4. **Hoàn thành booking** yêu cầu:
   - Đã thanh toán đủ (backend kiểm tra)
   - Đã check-out (backend kiểm tra)
   - Backend sẽ trả về lỗi nếu không thỏa mãn

5. **Hủy booking** yêu cầu:
   - Chưa hoàn thành đơn (backend kiểm tra)
   - Không tới check-in (backend kiểm tra)
   - Backend sẽ trả về lỗi nếu không thỏa mãn

---

**Cập nhật lần cuối:** Dựa trên code trong thư mục `WebAPI/Controllers`  
**Phiên bản:** 1.0
