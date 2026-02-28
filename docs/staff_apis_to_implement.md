# Danh sách API cần bổ sung/cải thiện cho Staff

_Cập nhật lần cuối: 26/02/2026_

---

## 📋 Tổng quan

Tài liệu này liệt kê các API cần được implement ở **Backend** để hỗ trợ đầy đủ nghiệp vụ của Staff trong hệ thống Postpartum Care Service Platform.

**Lưu ý**: Các API này hiện tại **CHƯA TỒN TẠI** ở Backend và cần được phát triển trước khi tích hợp vào Mobile App.

---

## 🎯 Phân loại theo mức độ ưu tiên

### 🔴 **Cao - Quan trọng cho nghiệp vụ hàng ngày**

#### 1. **MenuRecordController** - Quản lý Menu cho khách hàng

Staff cần xem và chỉnh sửa menu của các gia đình được phân công để phục vụ.

##### ❌ `GET /api/MenuRecord/customer/{customerId}`
- **Mô tả**: Staff xem toàn bộ menu của khách hàng theo customerId
- **Authorization**: `[Authorize(Roles = "admin,manager,staff")]`
- **Query Parameters**: 
  - `from` (DateOnly, optional): Ngày bắt đầu
  - `to` (DateOnly, optional): Ngày kết thúc
- **Response**: `List<MenuRecordResponse>`
- **Nghiệp vụ**: Staff cần xem menu của gia đình được phân để biết khách ăn gì trong ngày/tuần
- **Ưu tiên**: 🔴 **CAO** - Cần thiết cho nghiệp vụ hàng ngày

##### ❌ `GET /api/MenuRecord/customer/{customerId}/date`
- **Mô tả**: Staff xem menu của khách hàng theo customerId và ngày cụ thể
- **Authorization**: `[Authorize(Roles = "admin,manager,staff")]`
- **Query Parameters**: 
  - `date` (DateOnly, required): Ngày cần xem menu
- **Response**: `List<MenuRecordResponse>`
- **Nghiệp vụ**: Xem menu trong ngày cụ thể để chuẩn bị bữa ăn
- **Ưu tiên**: 🔴 **CAO** - Cần thiết cho nghiệp vụ hàng ngày

##### ❌ `GET /api/MenuRecord/customer/{customerId}/date-range`
- **Mô tả**: Staff xem menu của khách hàng trong khoảng thời gian
- **Authorization**: `[Authorize(Roles = "admin,manager,staff")]`
- **Query Parameters**: 
  - `from` (DateOnly, required): Ngày bắt đầu
  - `to` (DateOnly, required): Ngày kết thúc
- **Response**: `List<MenuRecordResponse>`
- **Nghiệp vụ**: Xem menu trong tuần/tháng để lên kế hoạch
- **Ưu tiên**: 🔴 **CAO** - Cần thiết cho nghiệp vụ hàng ngày

##### ❌ `POST /api/MenuRecord/customer/{customerId}`
- **Mô tả**: Staff tạo menu cho khách hàng
- **Authorization**: `[Authorize(Roles = "admin,manager,staff")]`
- **Request Body**: `List<CreateMenuRecordRequest>`
- **Response**: `List<MenuRecordResponse>`
- **Nghiệp vụ**: Staff có thể tạo menu hộ khách hàng khi khách không tự tạo được
- **Ưu tiên**: 🔴 **CAO** - Cần thiết cho nghiệp vụ

##### ❌ `PUT /api/MenuRecord/customer/{customerId}`
- **Mô tả**: Staff chỉnh sửa menu cho khách hàng
- **Authorization**: `[Authorize(Roles = "admin,manager,staff")]`
- **Request Body**: `List<UpdateMenuRecordRequest>`
- **Response**: `List<MenuRecordResponse>`
- **Nghiệp vụ**: Staff chỉnh sửa menu hộ khách hàng (ví dụ: thay đổi món ăn do không có nguyên liệu, khách yêu cầu thay đổi)
- **Ưu tiên**: 🔴 **CAO** - Cần thiết cho nghiệp vụ hàng ngày

##### ❌ `DELETE /api/MenuRecord/customer/{customerId}/{id}`
- **Mô tả**: Staff xóa menu của khách hàng
- **Authorization**: `[Authorize(Roles = "admin,manager,staff")]`
- **Response**: `MenuRecordResponse`
- **Nghiệp vụ**: Xóa menu khi cần thiết (soft delete)
- **Ưu tiên**: 🟡 **TRUNG BÌNH**

---

#### 2. **FamilyScheduleController** - Xem lịch sinh hoạt của khách hàng

Staff cần xem lịch sinh hoạt của các gia đình được phân công để hỗ trợ và theo dõi.

##### ❌ `GET /api/FamilySchedule/customer/{customerId}`
- **Mô tả**: Staff xem lịch sinh hoạt của khách hàng
- **Authorization**: `[Authorize(Roles = "admin,manager,staff")]`
- **Response**: `List<FamilyScheduleResponse>`
- **Nghiệp vụ**: Staff xem lịch sinh hoạt của gia đình được phân để biết lịch trình trong ngày
- **Ghi chú**: Hiện tại chỉ có API cho Admin (`/admin`) và Customer (`/my-schedules`)
- **Ưu tiên**: 🔴 **CAO** - Cần thiết để staff biết lịch trình của khách

##### ❌ `GET /api/FamilySchedule/customer/{customerId}/date`
- **Mô tả**: Staff xem lịch sinh hoạt của khách hàng theo ngày
- **Authorization**: `[Authorize(Roles = "admin,manager,staff")]`
- **Query Parameters**: 
  - `date` (DateOnly, required): Ngày cần xem
- **Response**: `List<FamilyScheduleResponse>`
- **Nghiệp vụ**: Xem lịch trong ngày cụ thể
- **Ưu tiên**: 🔴 **CAO**

##### ❌ `GET /api/FamilySchedule/customer/{customerId}/date-range`
- **Mô tả**: Staff xem lịch sinh hoạt của khách hàng trong khoảng thời gian
- **Authorization**: `[Authorize(Roles = "admin,manager,staff")]`
- **Query Parameters**: 
  - `from` (DateOnly, required): Ngày bắt đầu
  - `to` (DateOnly, required): Ngày kết thúc
- **Response**: `List<FamilyScheduleResponse>`
- **Nghiệp vụ**: Xem lịch trong tuần/tháng
- **Ưu tiên**: 🔴 **CAO**

##### ❌ `PUT /api/FamilySchedule/customer/{customerId}/{scheduleId}`
- **Mô tả**: Staff cập nhật lịch sinh hoạt của khách hàng
- **Authorization**: `[Authorize(Roles = "admin,manager,staff")]`
- **Request Body**: `UpdateFamilyScheduleRequest`
- **Response**: `FamilyScheduleResponse`
- **Nghiệp vụ**: Staff điều chỉnh lịch khi cần thiết (ví dụ: hoãn hoạt động, thay đổi thời gian)
- **Ưu tiên**: 🟡 **TRUNG BÌNH**



### 🟢 **Thấp - Nice to have**

#### 8. **RoomController** - Quản lý phòng cho staff

##### ❌ `GET /api/Room/assigned-customers`
- **Mô tả**: Staff xem danh sách phòng và khách hàng đang ở
- **Authorization**: `[Authorize(Roles = "admin,manager,staff")]`
- **Response**: `List<RoomWithCustomerResponse>`
- **Nghiệp vụ**: Staff xem phòng nào đang có khách để phục vụ
- **Ưu tiên**: 🟢 **THẤP**

##### ❌ `GET /api/Room/{id}/current-booking`
- **Mô tả**: Staff xem booking hiện tại của phòng
- **Authorization**: `[Authorize(Roles = "admin,manager,staff")]`
- **Response**: `BookingResponse`
- **Nghiệp vụ**: Xem thông tin khách đang ở phòng
- **Ưu tiên**: 🟢 **THẤP**

## 📝 Ghi chú quan trọng

1. **Bảo mật**: Cần kiểm tra quyền truy cập ở service layer để đảm bảo staff chỉ truy cập được dữ liệu phù hợp
2. **Validation**: Validate `customerId` tồn tại và hợp lệ
3. **Error Handling**: Xử lý các trường hợp:
   - Customer không tồn tại
   - Staff không có quyền truy cập
   - Dữ liệu không tìm thấy
4. **Performance**: Cân nhắc thêm pagination cho các API trả về danh sách lớn

---

## 🔗 Tham khảo

- File API list hiện tại: `cursor_api_functionalities_for_staff.md`
- File trạng thái tích hợp: `staff_api_status_summary.md`
- Backend Controllers: `WebAPI/Controllers/`
- Ngày tạo: 26/02/2026
- Ngày cập nhật: 26/02/2026
