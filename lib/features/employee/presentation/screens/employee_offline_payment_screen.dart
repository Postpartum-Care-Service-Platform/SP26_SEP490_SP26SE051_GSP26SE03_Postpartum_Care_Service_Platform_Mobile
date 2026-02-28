import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/di/injection_container.dart';
import '../../../booking/domain/entities/booking_entity.dart';
import '../../../booking/presentation/bloc/booking_bloc.dart';
import '../../../booking/presentation/bloc/booking_event.dart';
import '../../../booking/presentation/bloc/booking_state.dart';

/// Màn hình staff ghi nhận thanh toán offline (tiền mặt/chuyển khoản đã nhận).
class EmployeeOfflinePaymentScreen extends StatefulWidget {
  final BookingEntity booking;

  const EmployeeOfflinePaymentScreen({
    super.key,
    required this.booking,
  });

  @override
  State<EmployeeOfflinePaymentScreen> createState() =>
      _EmployeeOfflinePaymentScreenState();
}

class _EmployeeOfflinePaymentScreenState
    extends State<EmployeeOfflinePaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String _paymentMethod = 'Cash';

  @override
  void initState() {
    super.initState();
    // Gợi ý số tiền còn lại nếu BE có trả về.
    final remaining = widget.booking.remainingAmount;
    if (remaining > 0) {
      _amountController.text = remaining.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text.replaceAll(',', ''));
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Số tiền không hợp lệ')),
      );
      return;
    }

    final booking = widget.booking;

    context.read<BookingBloc>().add(
          BookingCreateOfflinePayment(
            bookingId: booking.id,
            customerId: booking.customer?.id ?? '',
            amount: amount,
            paymentMethod: _paymentMethod,
            note: _noteController.text.trim().isEmpty
                ? null
                : _noteController.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;

    return BlocProvider.value(
      value: InjectionContainer.bookingBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ghi nhận thanh toán'),
        ),
        body: BlocConsumer<BookingBloc, BookingState>(
          listener: (context, state) {
            if (state is BookingError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            } else if (state is BookingPaymentStatusChecked) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ghi nhận thanh toán thành công'),
                ),
              );
              Navigator.of(context).pop(true);
            }
          },
          builder: (context, state) {
            final isLoading = state is BookingLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Booking #${booking.id}',
                    style: AppTextStyles.arimo(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (booking.package != null)
                    Text(
                      booking.package!.packageName,
                      style: AppTextStyles.arimo(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  const SizedBox(height: 4),
                  if (booking.customer != null)
                    Text(
                      'Khách hàng: ${booking.customer!.username}',
                      style: AppTextStyles.arimo(fontSize: 13),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    'Tổng tiền: ${booking.finalAmount.toStringAsFixed(0)} đ',
                    style: AppTextStyles.arimo(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Đã thanh toán: ${booking.paidAmount.toStringAsFixed(0)} đ',
                    style: AppTextStyles.arimo(
                      fontSize: 13,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Số tiền thanh toán',
                          style: AppTextStyles.arimo(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _amountController,
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            hintText: 'Nhập số tiền (VNĐ)',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Vui lòng nhập số tiền';
                            }
                            final v = double.tryParse(
                                value.trim().replaceAll(',', ''));
                            if (v == null || v <= 0) {
                              return 'Số tiền không hợp lệ';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Hình thức thanh toán',
                          style: AppTextStyles.arimo(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _paymentMethod,
                          items: const [
                            DropdownMenuItem(
                              value: 'Cash',
                              child: Text('Tiền mặt'),
                            ),
                            DropdownMenuItem(
                              value: 'BankTransfer',
                              child: Text('Chuyển khoản'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _paymentMethod = value);
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Ghi chú (tuỳ chọn)',
                          style: AppTextStyles.arimo(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _noteController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            hintText: 'VD: Đã nhận đủ, khách thanh toán tại quầy...',
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : () => _submit(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(
                              isLoading ? 'Đang xử lý...' : 'Ghi nhận thanh toán',
                              style: AppTextStyles.arimo(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

