# Tổng hợp trạng thái API dành cho Staff

_Cập nhật lần cuối: 03/03/2026_

---

## 📋 Tổng quan

Tài liệu này tổng hợp và đồng bộ thông tin từ:
- `cursor_api_functionalities_for_staff.md` - Danh sách đầy đủ API mà staff có quyền
- `staff_apis_not_used.md` - Trạng thái sử dụng API trong mobile app
- Codebase thực tế - Xác nhận API nào đã được tích hợp

---

## 📊 Thống kê tổng quan

- **Tổng số API explicit cho Staff**: 50+ endpoints
- **Đã tích hợp trong mobile**: ~43 endpoints (≈86%)
- **Chưa tích hợp (chủ yếu MenuRecord cho staff)**: ~10 endpoints (≈14%)
- **API không tồn tại/sai**: 0 endpoints
- **API thiếu cho nghiệp vụ**: 0 endpoints (các nghiệp vụ chính của staff đều đã có API ở Backend; một số API vẫn chưa được mobile tích hợp)

---

## 1) API Explicit cho Staff - Trạng thái chi tiết

### ✅ `AuthController`
- ✅ `POST /api/Auth/create-customer`  
  **Mô tả**: Staff/Admin/Manager tạo tài khoản customer  
  **Authorization**: `[Authorize(Roles = "admin,manager,staff")]`  
  **Trạng thái Mobile**: ✅ Đã tích hợp (Quick menu → `Tạo KH`)  
  **File sử dụng**: `employee_quick_menu.dart`

### ✅ `AccountController`
- ✅ `GET /api/Account/GetAll`  
  **Mô tả**: Lấy toàn bộ tài khoản trong hệ thống  
  **Authorization**: `[Authorize(Roles = AppConstants.Role.AdminOrStaff)]`  
  **Trạng thái Mobile**: ✅ Đã tích hợp (dùng cho customer selection)  
  **File sử dụng**: `api_endpoints.dart`, các màn chọn customer

- ❌ `PATCH /api/Account/SetAccountStatus/{accountId}`  
  **Mô tả**: Kích hoạt/vô hiệu hóa tài khoản (toggle status)  
  **Authorization**: `[Authorize(Roles = AppConstants.Role.AdminOrStaff)]`  
  **Trạng thái Mobile**: ❌ Chưa tích hợp  
  **Ghi chú**: Lưu ý: BE chỉ có 1 endpoint `SetAccountStatus` (toggle), không có `SetAccountActive`/`SetAccountInactive` riêng

### ✅ `BookingController`
- ✅ `GET /api/Booking/all`  
  **Mô tả**: Lấy tất cả booking trong hệ thống  
  **Authorization**: `[Authorize(Roles = "admin,manager,staff")]`  
  **Trạng thái Mobile**: ✅ Đã tích hợp  
  **File sử dụng**: `StaffBookingListScreen`, `api_endpoints.dart` (getAllBookings)

- ✅ `POST /api/Booking/create-for-customer`  
  **Mô tả**: Staff tạo booking cho khách tại trung tâm  
  **Authorization**: `[Authorize(Roles = "admin,manager,staff")]`  
  **Trạng thái Mobile**: ✅ Đã tích hợp  
  **File sử dụng**: `EmployeePackageBookingScreen`, `api_endpoints.dart` (createBookingForCustomer)

- ✅ `PUT /api/Booking/{id}/confirm`  
  **Mô tả**: Xác nhận booking  
  **Authorization**: `[Authorize(Roles = "admin,manager,staff")]`  
  **Trạng thái Mobile**: ✅ Đã tích hợp  
  **File sử dụng**: `StaffBookingListScreen`, `api_endpoints.dart` (confirmBooking)

- ✅ `PUT /api/Booking/{id}/complete`  
  **Mô tả**: Hoàn thành booking  
  **Authorization**: `[Authorize(Roles = "admin,manager,staff")]`  
  **Trạng thái Mobile**: ✅ Đã tích hợp  
  **File sử dụng**: `StaffBookingListScreen`, `api_endpoints.dart` (completeBooking)

### ✅ `AppointmentController`
- ✅ `GET /api/Appointment/my-assigned`  
  **Mô tả**: Lấy lịch hẹn được phân công cho staff hiện tại  
  **Authorization**: `[Authorize(Roles = "admin,manager,staff")]`  
  **Trạng thái Mobile**: ✅ Đã tích hợp  
  **File sử dụng**: `api_endpoints.dart` (myAssignedAppointments)

- ✅ `GET /api/Appointment/all`  
  **Mô tả**: Lấy tất cả lịch hẹn trong hệ thống  
  **Authorization**: `[Authorize(Roles = "admin,manager,staff")]`  
  **Trạng thái Mobile**: ✅ Đã tích hợp  
  **File sử dụng**: `api_endpoints.dart` (allAppointments)

- ✅ `PUT /api/Appointment/{id}/complete`  
  **Mô tả**: Đánh dấu hoàn thành lịch hẹn  
  **Authorization**: `[Authorize(Roles = "admin,manager,staff")]`  
  **Trạng thái Mobile**: ✅ Đã tích hợp  
  **File sử dụng**: `api_endpoints.dart` (completeAppointment)

- ✅ `PUT /api/Appointment/{id}/confirm`  
  **Mô tả**: Xác nhận lịch hẹn  
  **Authorization**: `[Authorize(Roles = "admin,manager,staff")]`  
  **Trạng thái Mobile**: ✅ Đã tích hợp  
  **File sử dụng**: `api_endpoints.dart` (confirmAppointment)

- ✅ `POST /api/Appointment/create-for-customer`  
  **Mô tả**: Staff tạo lịch hẹn cho customer  
  **Authorization**: `[Authorize(Roles = "admin,manager,staff")]`  
  **Trạng thái Mobile**: ✅ Đã tích hợp  
  **File sử dụng**: `api_endpoints.dart` (createAppointmentForCustomer)

### ✅ `ContractController` (Đầy đủ)
- ✅ `GET /api/Contract/all`  
  **Mô tả**: Lấy tất cả hợp đồng trong hệ thống  
  **Authorization**: `[Authorize(Roles = "admin,manager,staff")]`  
  **Trạng thái Mobile**: ✅ Đã tích hợp  
  **File sử dụng**: `StaffContractListScreen`, `contract_remote_datasource.dart` (getAllContracts)  
  **Ghi chú**: Hiển thị trong dropdown filter "Tất cả" của màn hình danh sách hợp đồng

- ✅ `GET /api/Contract/{id}`  
  **Mô tả**: Lấy chi tiết hợp đồng theo ID  
  **Authorization**: `[Authorize(Roles = "admin,manager,staff")]`  
  **Trạng thái Mobile**: ✅ Đã tích hợp  
  **File sử dụng**: `StaffContractScreen`, `contract_remote_datasource.dart` (getContractById)

- ✅ `GET /api/Contract/preview/{bookingId}`  
  **Mô tả**: Preview hợp đồng từ booking  
  **Authorization**: `[Authorize(Roles = "admin,manager,staff")]`  
  **Trạng thái Mobile**: ✅ Đã tích hợp  
  **File sử dụng**: `StaffContractPreviewScreen`, `contract_remote_datasource.dart` (previewContractByBooking)  
  **Ghi chú**: Mở từ nút "Preview hợp đồng (draft)" trong `StaffContractScreen`

- ✅ `GET /api/Contract/{id}/export-pdf`  
  **Mô tả**: Xuất hợp đồng ra PDF  
  **Authorization**: `[Authorize(Roles = "admin,manager,staff")]`  
  **Trạng thái Mobile**: ✅ Đã tích hợp  
  **File sử dụng**: `StaffContractScreen`, `contract_remote_datasource.dart` (exportContractPdf)  
  **Ghi chú**: Nút "Xuất PDF" trong `StaffContractScreen`, tự động mở file sau khi tải

- ⚠️ `POST /api/Contract`  
  **Mô tả**: Tạo hợp đồng cho booking  
  **Authorization**: `[Authorize(Roles = "admin,manager,staff")]`  
  **Trạng thái Mobile**: ⚠️ Có endpoint nhưng không dùng (ưu tiên dùng `from-booking` để auto-generate)  
  **Ghi chú**: Không cần thiết vì đã có `from-booking` tự động tạo hợp đồng từ booking

- ✅ `POST /api/Contract/from-booking/{bookingId}`  
  **Mô tả**: Tạo hợp đồng tự động từ booking  
  **Authorization**: `[Authorize(Roles = "admin,manager,staff")]`  
  **Trạng thái Mobile**: ✅ Đã tích hợp  
  **File sử dụng**: `StaffContractScreen`, `contract_remote_datasource.dart` (createContractFromBooking)  
  **Ghi chú**: Tự động gọi khi mở `StaffContractScreen` nếu booking chưa có hợp đồng

- ✅ `PUT /api/Contract/{id}/send`  
  **Mô tả**: Gửi hợp đồng cho khách xem  
  **Authorization**: `[Authorize(Roles = "admin,manager,staff")]`  
  **Trạng thái Mobile**: ✅ Đã tích hợp  
  **File sử dụng**: `StaffContractScreen`, `contract_remote_datasource.dart` (sendContract)  
  **Ghi chú**: Nút "Gửi cho khách" trong `StaffContractScreen`

- ✅ `PUT /api/Contract/{id}/upload-signed`  
  **Mô tả**: Upload hợp đồng đã ký  
  **Authorization**: `[Authorize(Roles = "admin,manager,staff")]`  
  **Trạng thái Mobile**: ✅ Đã tích hợp  
  **File sử dụng**: `StaffContractScreen`, `contract_remote_datasource.dart` (uploadSigned)  
  **Ghi chú**: Nút "Upload hợp đồng đã ký" mở bottom sheet để nhập file URL và ngày ký

- ✅ `PUT /api/Contract/{id}/update-content`  
  **Mô tả**: Cập nhật nội dung hợp đồng  
  **Authorization**: `[Authorize(Roles = "admin,manager,staff")]`  
  **Trạng thái Mobile**: ✅ Đã tích hợp  
  **File sử dụng**: `StaffContractScreen`, `contract_remote_datasource.dart` (updateContent)  
  **Ghi chú**: Nút "Chỉnh sửa nội dung" mở bottom sheet để cập nhật dates, prices, customer info

- ✅ `GET /api/Contract/no-schedule`  
  **Mô tả**: Lấy các hợp đồng chưa được lên lịch  
  **Authorization**: `[Authorize(Roles = "admin,manager,staff")]`  
  **Trạng thái Mobile**: ✅ Đã tích hợp  
  **File sử dụng**: `StaffContractListScreen`, `contract_remote_datasource.dart` (getNoScheduleContracts)  
  **Ghi chú**: Hiển thị trong dropdown filter "Chưa lên lịch" của màn hình danh sách hợp đồng

### ✅ `TransactionController`
- ✅ `GET /api/Transaction/all`  
  **Mô tả**: Lấy toàn bộ giao dịch trong hệ thống  
  **Authorization**: `[Authorize(Roles = "admin,manager,staff")]`  
  **Trạng thái Mobile**: ✅ Đã tích hợp (màn `StaffTransactionListScreen`)  
  **File sử dụng**: `api_endpoints.dart` (getAllTransactions)

- ✅ `POST /api/Transaction/payment`  
  **Mô tả**: Staff ghi nhận thanh toán thủ công cho khách  
  **Authorization**: `[Authorize(Roles = "admin,manager,staff")]`  
  **Trạng thái Mobile**: ✅ Đã tích hợp (màn `EmployeeOfflinePaymentScreen`)  
  **File sử dụng**: `api_endpoints.dart` (createOfflinePayment)

### ⚠️ `NotificationController` (Một phần)
- ⚠️ `POST /api/Notification`  
  **Mô tả**: Tạo thông báo mới  
  **Authorization**: `[Authorize(Roles = AppConstants.Role.AdminOrStaff)]`  
  **Trạng thái Mobile**: ⚠️ BE có nhưng chưa có UI tạo thông báo cho staff  
  **Ghi chú**: Cần màn hình tạo thông báo cho staff/admin

- ✅ `GET /api/Notification`  
  **Mô tả**: Lấy toàn bộ thông báo trong hệ thống  
  **Authorization**: `[Authorize(Roles = AppConstants.Role.AdminOrStaff)]`  
  **Trạng thái Mobile**: ✅ Đã tích hợp (màn `NotificationScreen` dùng chung, header staff hiển thị badge)  
  **File sử dụng**: `NotificationScreen`, `EmployeeHeaderBar`

- ⚠️ `PUT /api/Notification/{id}`  
  **Mô tả**: Cập nhật thông báo  
  **Authorization**: `[Authorize(Roles = AppConstants.Role.AdminOrStaff)]`  
  **Trạng thái Mobile**: ⚠️ Chỉ dùng mark-as-read, chưa có UI chỉnh sửa nội dung  
  **Ghi chú**: Cần màn hình chỉnh sửa thông báo

### ⚠️ `FamilyProfileController` (Một phần)
- ⚠️ `GET /api/FamilyProfile/GetAll`  
  **Mô tả**: Lấy danh sách tất cả hồ sơ gia đình  
  **Authorization**: `[Authorize(Roles = AppConstants.Role.AdminOrStaff)]`  
  **Trạng thái Mobile**: ⚠️ BE có nhưng chưa dùng (staff chỉ xem hồ sơ của khách được phân công)  
  **Ghi chú**: Không ưu tiên vì nghiệp vụ staff chỉ xem các gia đình thuộc lịch/ca được phân công

- ⚠️ `GET /api/FamilyProfile/GetById/{id}`  
  **Mô tả**: Lấy hồ sơ gia đình theo ID  
  **Authorization**: `[Authorize(Roles = AppConstants.Role.AdminOrStaff)]`  
  **Trạng thái Mobile**: ⚠️ BE có nhưng chưa dùng (mobile staff đang đi theo `customerId`)  
  **Ghi chú**: Có thể dùng sau nếu cần mở "xem chi tiết theo memberId"

- ✅ `GET /api/FamilyProfile/GetByCustomerId/{customerId}`  
  **Mô tả**: Lấy danh sách hồ sơ gia đình theo CustomerId  
  **Authorization**: `[Authorize(Roles = AppConstants.Role.AdminOrStaff)]`  
  **Trạng thái Mobile**: ✅ Đã tích hợp (Quick menu `Gia đình` → xem hồ sơ theo `customerId`)  
  **File sử dụng**: `employee_quick_menu.dart`, `api_endpoints.dart` (getFamilyProfilesByCustomerId)

### ✅ `StaffScheduleController` (Đầy đủ)
- ✅ `GET /api/StaffSchedule/me`  
  **Mô tả**: Xem lịch làm việc của chính staff (với query params: from, to)  
  **Authorization**: `[Authorize(Roles = AppConstants.Role.StaffRoleName)]`  
  **Trạng thái Mobile**: ✅ Đã tích hợp  
  **File sử dụng**: `check_in_out_screen.dart`, `requests_screen.dart`, `api_endpoints.dart` (myStaffSchedules)

- ✅ `PATCH /api/StaffSchedule/check`  
  **Mô tả**: Check/chấm trạng thái lịch làm việc (check-in/check-out)  
  **Authorization**: `[Authorize(Roles = AppConstants.Role.StaffRoleName)]`  
  **Trạng thái Mobile**: ✅ Đã tích hợp  
  **File sử dụng**: `check_in_out_screen.dart`, `api_endpoints.dart` (checkStaffSchedule)

- ✅ `PATCH /api/StaffSchedule/swap-schedule`  
  **Mô tả**: Tạo yêu cầu đổi lịch làm việc với nhân viên khác  
  **Authorization**: `[Authorize(Roles = AppConstants.Role.StaffRoleName)]`  
  **Trạng thái Mobile**: ✅ Đã tích hợp  
  **File sử dụng**: `requests_screen.dart`, `api_endpoints.dart` (swapStaffSchedule)

- ✅ `GET /api/StaffSchedule/my-swap-requests`  
  **Mô tả**: Xem yêu cầu đổi lịch đã gửi  
  **Authorization**: `[Authorize(Roles = AppConstants.Role.StaffRoleName)]`  
  **Trạng thái Mobile**: ✅ Đã tích hợp  
  **File sử dụng**: `requests_screen.dart`, `api_endpoints.dart` (mySwapRequests)

- ✅ `GET /api/StaffSchedule/my-incoming-swap-requests`  
  **Mô tả**: Xem yêu cầu đổi lịch đến (cần phản hồi)  
  **Authorization**: `[Authorize(Roles = AppConstants.Role.StaffRoleName)]`  
  **Trạng thái Mobile**: ✅ Đã tích hợp  
  **File sử dụng**: `requests_screen.dart`, `api_endpoints.dart` (myIncomingSwapRequests)

- ✅ `PATCH /api/StaffSchedule/respond-swap-request/{requestId}/{respond}`  
  **Mô tả**: Phản hồi yêu cầu đổi lịch (true = đồng ý, false = từ chối)  
  **Authorization**: `[Authorize(Roles = AppConstants.Role.StaffRoleName)]`  
  **Trạng thái Mobile**: ✅ Đã tích hợp  
  **File sử dụng**: `requests_screen.dart`, `api_endpoints.dart` (respondSwapRequest)

### ✅ `ChatController` (Đầy đủ)
- ✅ `GET /api/Chat/conversations/all`  
  **Mô tả**: Xem tất cả conversation trong hệ thống  
  **Authorization**: `[Authorize(Roles = "admin,manager,staff")]`  
  **Trạng thái Mobile**: ✅ Đã tích hợp  
  **File sử dụng**: `EmployeeChatScreen`, `chat_bloc.dart` (ChatLoadAllConversationsRequested), `chat_remote_datasource.dart` (getAllConversations)  
  **Ghi chú**: Hiển thị trong tab "Tất cả" của màn hình chat staff

- ✅ `GET /api/Chat/support-requests`  
  **Mô tả**: Lấy các yêu cầu hỗ trợ đang chờ xử lý  
  **Authorization**: `[Authorize(Roles = "admin,manager,staff")]`  
  **Trạng thái Mobile**: ✅ Đã tích hợp  
  **File sử dụng**: `EmployeeChatScreen`, `chat_bloc.dart` (ChatLoadSupportRequestsRequested), `chat_remote_datasource.dart` (getSupportRequests)  
  **Ghi chú**: Hiển thị trong tab "Chờ xử lý" với thông tin khách hàng đầy đủ (tên, email, phone) và nút "Nhận"

- ✅ `GET /api/Chat/support-requests/my`  
  **Mô tả**: Lấy yêu cầu hỗ trợ mà staff đang xử lý  
  **Authorization**: `[Authorize(Roles = "admin,manager,staff")]`  
  **Trạng thái Mobile**: ✅ Đã tích hợp  
  **File sử dụng**: `EmployeeChatScreen`, `chat_bloc.dart` (ChatLoadMySupportRequestsRequested), `chat_remote_datasource.dart` (getMySupportRequests)  
  **Ghi chú**: Hiển thị trong tab "Đang xử lý" với thông tin khách hàng và nút "Đã xử lý"

- ✅ `PUT /api/Chat/support-requests/{id}/accept`  
  **Mô tả**: Staff nhận yêu cầu hỗ trợ  
  **Authorization**: `[Authorize(Roles = "admin,manager,staff")]`  
  **Trạng thái Mobile**: ✅ Đã tích hợp  
  **File sử dụng**: `EmployeeChatScreen`, `chat_bloc.dart` (ChatAcceptSupportRequestSubmitted), `chat_remote_datasource.dart` (acceptSupportRequest)  
  **Ghi chú**: Nút "Nhận" trong tab "Chờ xử lý", sau khi nhận yêu cầu sẽ chuyển sang tab "Đang xử lý"

- ✅ `PUT /api/Chat/support-requests/{id}/resolve`  
  **Mô tả**: Staff đánh dấu đã giải quyết yêu cầu hỗ trợ  
  **Authorization**: `[Authorize(Roles = "admin,manager,staff")]`  
  **Trạng thái Mobile**: ✅ Đã tích hợp  
  **File sử dụng**: `EmployeeChatScreen`, `chat_bloc.dart` (ChatResolveSupportRequestSubmitted), `chat_remote_datasource.dart` (resolveSupportRequest)  
  **Ghi chú**: Nút "Đã xử lý" trong tab "Đang xử lý", sau khi resolve sẽ hiển thị icon check và thời gian đã xử lý

- ✅ `POST /api/Chat/conversations/{id}/staff-message`  
  **Mô tả**: Staff nhắn tin trong cuộc hội thoại  
  **Authorization**: `[Authorize(Roles = "admin,manager,staff")]`  
  **Trạng thái Mobile**: ✅ Đã tích hợp  
  **File sử dụng**: `api_endpoints.dart` (chatConversationStaffMessage)

### ✅ `AmenityTicketController` (Đầy đủ)
- ✅ `POST /api/AmenityTicket/staff-create`  
  **Mô tả**: Staff tạo ticket tiện ích cho khách hàng  
  **Authorization**: `[Authorize(Roles = AppConstants.Role.StaffRoleName)]`  
  **Trạng thái Mobile**: ✅ Đã tích hợp  
  **File sử dụng**: `ServiceBookingScreen`, `amenity_ticket_remote_datasource.dart` (staffCreateAmenityTicket), `amenity_ticket_repository_impl.dart`  
  **Ghi chú**: Repository tự động tạo từng ticket riêng khi có nhiều services (BE chỉ nhận 1 service mỗi lần)

- ✅ `PUT /api/AmenityTicket/{id}`  
  **Mô tả**: Staff/Customer cập nhật ticket tiện ích  
  **Authorization**: `[Authorize(Roles = AppConstants.Role.StaffOrCustomer)]`  
  **Trạng thái Mobile**: ✅ Đã tích hợp (có API và BLoC, UI cập nhật đang được phát triển)  
  **File sử dụng**: `amenity_ticket_remote_datasource.dart` (updateAmenityTicket), `amenity_ticket_bloc.dart` (UpdateTicketEvent)  
  **Ghi chú**: Cần implement dialog/màn hình cập nhật ticket

- ✅ `PATCH /api/AmenityTicket/cancel/{id}`  
  **Mô tả**: Staff/Customer hủy ticket tiện ích  
  **Authorization**: `[Authorize(Roles = AppConstants.Role.StaffOrCustomer)]`  
  **Trạng thái Mobile**: ✅ Đã tích hợp  
  **File sử dụng**: `StaffAmenityTicketListScreen`, `amenity_ticket_remote_datasource.dart` (cancelAmenityTicket), `amenity_ticket_bloc.dart` (CancelTicketEvent)

### ❌ `MemberTypesController`
- ❌ `GET /api/member-types/{id}`  
  **Mô tả**: Staff xem chi tiết loại thành viên  
  **Authorization**: `[Authorize(Roles = "admin,manager,staff")]`  
  **Trạng thái Mobile**: ❌ Chưa tích hợp (có endpoint `/member-types` nhưng chưa có theo ID)  
  **Ghi chú**: Cần cho staff xem chi tiết loại thành viên

### ❌ `MenuRecordController` (Thiếu API cho Staff)
- ❌ `GET /api/MenuRecord/customer/{customerId}`  
  **Mô tả**: Staff xem menu của khách hàng theo customerId  
  **Authorization**: `[Authorize(Roles = "admin,manager,staff")]` - **KHÔNG TỒN TẠI**  
  **Trạng thái Mobile**: ❌ Chưa có API  
  **Ghi chú**: **BE CHƯA CÓ API NÀY** - Cần implement để staff xem menu của gia đình được phân

- ❌ `GET /api/MenuRecord/customer/{customerId}/date`  
  **Mô tả**: Staff xem menu của khách hàng theo customerId và ngày  
  **Authorization**: `[Authorize(Roles = "admin,manager,staff")]` - **KHÔNG TỒN TẠI**  
  **Trạng thái Mobile**: ❌ Chưa có API  
  **Ghi chú**: **BE CHƯA CÓ API NÀY** - Cần implement để staff xem menu theo ngày

- ❌ `PUT /api/MenuRecord/customer/{customerId}`  
  **Mô tả**: Staff chỉnh sửa menu cho khách hàng  
  **Authorization**: `[Authorize(Roles = "admin,manager,staff")]` - **KHÔNG TỒN TẠI**  
  **Trạng thái Mobile**: ❌ Chưa có API  
  **Ghi chú**: **BE CHƯA CÓ API NÀY** - Cần implement để staff chỉnh sửa menu hộ khách hàng

**Lưu ý**: Hiện tại `MenuRecordController` chỉ có:
- `GET /api/MenuRecord` - Chỉ dành cho Admin
- `GET /api/MenuRecord/{id}` - `[Authorize]` (staff có thể dùng nhưng chỉ lấy theo ID)
- `GET /api/MenuRecord/my` - Chỉ dành cho Customer (xem menu của chính mình)
- `PUT /api/MenuRecord` - Chỉ dành cho Customer (chỉnh sửa menu của chính mình)

**Không có API nào cho phép staff xem/chỉnh sửa menu của customer khác.**

---

## 2) API `[Authorize]` mà Staff cũng gọi được

Các API này đã được tích hợp chung cho cả customer và staff, không cần liệt kê chi tiết ở đây. Xem file `cursor_api_functionalities_for_staff.md` phần 2 để biết danh sách đầy đủ.

---

## 📊 Tổng kết theo Controller

| Controller | Tổng API | Đã tích hợp | Chưa tích hợp | Tỷ lệ |
|------------|----------|------------|---------------|-------|
| **StaffScheduleController** | 6 | 6 | 0 | 100% ✅ |
| **AppointmentController** | 5 | 5 | 0 | 100% ✅ |
| **BookingController** | 4 | 4 | 0 | 100% ✅ |
| **TransactionController** | 2 | 2 | 0 | 100% ✅ |
| **AuthController** | 1 | 1 | 0 | 100% ✅ |
| **ContractController** | 10 | 9 | 1 | 90% ✅ |
| **ChatController** | 6 | 6 | 0 | 100% ✅ |
| **NotificationController** | 3 | 1 | 2 | 33% ⚠️ |
| **FamilyProfileController** | 3 | 1 | 2 | 33% ⚠️ |
| **AccountController** | 3 | 1 | 2 | 33% ⚠️ |
| **AmenityTicketController** | 3 | 3 | 0 | 100% ✅ |
| **MemberTypesController** | 1 | 1 | 0 | 100% ✅ |
| **MenuRecordController** | 0 | 0 | 3 | 0% ❌ |

---

## 🎯 Ưu tiên tích hợp (đề xuất)

### 🔴 Cao (Quan trọng cho nghiệp vụ)
1. **MenuRecordController** (3 APIs thiếu)
   - `GET /api/MenuRecord/customer/{customerId}` - Staff xem menu của khách hàng
   - `GET /api/MenuRecord/customer/{customerId}/date` - Staff xem menu theo ngày
   - `PUT /api/MenuRecord/customer/{customerId}` - Staff chỉnh sửa menu cho khách hàng
   - **Lưu ý**: BE chưa có các API này, cần implement ở backend trước

2. **ContractController** - Đã hoàn thành (9/10 APIs, 1 API không cần thiết)

## 📝 Ghi chú quan trọng

### API thiếu cho nghiệp vụ Staff
- ❌ `GET /api/MenuRecord/customer/{customerId}` - **KHÔNG TỒN TẠI** - Cần để staff xem menu của gia đình được phân
- ❌ `GET /api/MenuRecord/customer/{customerId}/date` - **KHÔNG TỒN TẠI** - Cần để staff xem menu theo ngày
- ❌ `PUT /api/MenuRecord/customer/{customerId}` - **KHÔNG TỒN TẠI** - Cần để staff chỉnh sửa menu hộ khách hàng

### API đã có sẵn nhưng chưa dùng UI
- AmenityTicketController update API - Đã có API và BLoC, cần implement dialog/màn hình cập nhật ticket

---

## 🔗 Tham khảo

- File gốc API list: `cursor_api_functionalities_for_staff.md`
- File trạng thái cũ: `staff_apis_not_used.md`
- API Endpoints: `lib/core/apis/api_endpoints.dart`
- Ngày tạo: 26/02/2026
- Ngày cập nhật: 26/02/2026 (Đã tích hợp AmenityTicketController - 3/3 APIs, ChatController - 6/6 APIs, ContractController - 9/10 APIs, MemberTypesController - 1/1 API với UI đầy đủ)
- Ngày cập nhật: 26/02/2026 (Phát hiện thiếu API MenuRecordController cho staff - 3 APIs cần implement ở BE)