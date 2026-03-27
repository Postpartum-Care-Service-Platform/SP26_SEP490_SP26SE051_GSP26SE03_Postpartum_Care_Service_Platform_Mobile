import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/app_responsive.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/widgets/app_app_bar.dart';
import '../../../../../features/employee/shell/presentation/widgets/employee_scaffold.dart';
import '../../../../../features/booking/presentation/bloc/booking_bloc.dart';
import '../../../../../features/booking/presentation/bloc/booking_event.dart';
import '../../../../../features/booking/presentation/bloc/booking_state.dart';
import '../../../../../features/booking/presentation/screens/payment_screen.dart';
import '../../../../../features/employee/account/data/datasources/account_remote_datasource.dart';
import '../../../../../features/employee/account/data/models/account_model.dart';
import '../../../../../features/services/presentation/widgets/services_booking_flow.dart';

class EmployeePackageBookingScreen extends StatefulWidget {
  const EmployeePackageBookingScreen({super.key});

  @override
  State<EmployeePackageBookingScreen> createState() =>
      _EmployeePackageBookingScreenState();
}

class _EmployeePackageBookingScreenState
    extends State<EmployeePackageBookingScreen> {
  AccountModel? _selectedCustomer;
  List<AccountModel> _customers = [];
  List<AccountModel> _filteredCustomers = [];
  bool _isLoadingCustomers = false;

  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCustomers();
    _searchController.addListener(_filterCustomers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomers() async {
    setState(() => _isLoadingCustomers = true);
    try {
      final dataSource = AccountRemoteDataSource();
      final customers = await dataSource.getCustomers();
      setState(() {
        _customers = customers;
        _filteredCustomers = customers;
        _isLoadingCustomers = false;
      });
    } catch (e) {
      setState(() => _isLoadingCustomers = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Lỗi tải danh sách khách hàng: $e',
            style: AppTextStyles.arimo(color: AppColors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _filterCustomers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCustomers = _customers;
      } else {
        _filteredCustomers = _customers.where((customer) {
          return customer.displayName.toLowerCase().contains(query) ||
              customer.email.toLowerCase().contains(query) ||
              (customer.phone?.toLowerCase().contains(query) ?? false);
        }).toList();
      }
    });
  }

  void _selectCustomer(AccountModel customer) {
    setState(() {
      _selectedCustomer = customer;
    });
    Navigator.of(context).pop();
  }

  Future<void> _showCustomerSearchDialog() async {
    final scale = AppResponsive.scaleFactor(context);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: Container(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.82),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(22 * scale)),
            ),
            child: Column(
              children: [
                SizedBox(height: 10 * scale),
                Container(
                  width: 44 * scale,
                  height: 5 * scale,
                  decoration: BoxDecoration(
                    color: AppColors.borderLight,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16 * scale, 14 * scale, 16 * scale, 8 * scale),
                  child: Row(
                    children: [
                      Text(
                        'Chọn khách hàng',
                        style: AppTextStyles.arimo(
                          fontSize: 17 * scale,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16 * scale, 0, 16 * scale, 12 * scale),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Tìm theo tên, email, SĐT',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _searchController.clear();
                              },
                              icon: const Icon(Icons.close_rounded),
                            )
                          : null,
                      filled: true,
                      fillColor: const Color(0xFFF8F7F5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14 * scale),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 14 * scale,
                        vertical: 12 * scale,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _isLoadingCustomers
                      ? const Center(
                          child: CircularProgressIndicator(color: AppColors.primary),
                        )
                      : _filteredCustomers.isEmpty
                          ? Center(
                              child: Text(
                                'Không tìm thấy khách hàng phù hợp',
                                style: AppTextStyles.arimo(
                                  fontSize: 13 * scale,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            )
                          : ListView.separated(
                              padding: EdgeInsets.fromLTRB(12 * scale, 0, 12 * scale, 16 * scale),
                              itemCount: _filteredCustomers.length,
                              separatorBuilder: (_, __) => SizedBox(height: 6 * scale),
                              itemBuilder: (context, index) {
                                final c = _filteredCustomers[index];
                                final isSelected = _selectedCustomer?.id == c.id;
                                return Material(
                                  color: isSelected
                                      ? AppColors.primary.withValues(alpha: 0.08)
                                      : const Color(0xFFFAFAFA),
                                  borderRadius: BorderRadius.circular(12 * scale),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12 * scale),
                                    onTap: () => _selectCustomer(c),
                                    child: Padding(
                                      padding: EdgeInsets.all(12 * scale),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 36 * scale,
                                            height: 36 * scale,
                                            decoration: BoxDecoration(
                                              color: AppColors.primary.withValues(alpha: 0.14),
                                              borderRadius: BorderRadius.circular(10 * scale),
                                            ),
                                            child: const Icon(
                                              Icons.person_rounded,
                                              color: AppColors.primary,
                                              size: 20,
                                            ),
                                          ),
                                          SizedBox(width: 10 * scale),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  c.displayName,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: AppTextStyles.arimo(
                                                    fontSize: 14 * scale,
                                                    fontWeight: FontWeight.w700,
                                                    color: AppColors.textPrimary,
                                                  ),
                                                ),
                                                SizedBox(height: 2 * scale),
                                                Text(
                                                  [
                                                    c.email,
                                                    if (c.phone != null && c.phone!.isNotEmpty) c.phone!,
                                                  ].join(' • '),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: AppTextStyles.arimo(
                                                    fontSize: 12 * scale,
                                                    color: AppColors.textSecondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (isSelected)
                                            const Icon(
                                              Icons.check_circle_rounded,
                                              color: AppColors.primary,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onStaffConfirmBooking(BuildContext context) {
    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Vui lòng chọn khách hàng',
            style: AppTextStyles.arimo(color: AppColors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    context.read<BookingBloc>().add(
          BookingCreateBookingForCustomer(_selectedCustomer!.id),
        );
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return BlocProvider(
      create: (_) => InjectionContainer.bookingBloc,
      child: BlocListener<BookingBloc, BookingState>(
        listener: (context, state) {
          if (state is BookingCreated) {
            final bookingBloc = context.read<BookingBloc>();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: bookingBloc,
                  child: PaymentScreen(booking: state.booking),
                ),
              ),
            );
          } else if (state is BookingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                  style: AppTextStyles.arimo(color: AppColors.white),
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: EmployeeScaffold(
          appBar: const AppAppBar(
            title: 'Đặt gói cho khách hàng',
            centerTitle: true,
          ),
          body: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16 * scale, 12 * scale, 16 * scale, 8 * scale),
                child: _buildCustomerSelector(scale),
              ),
              const Divider(height: 1),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(8 * scale),
                  child: ServicesBookingFlow(
                    onBackToLocationSelection: () {
                      Navigator.of(context).maybePop();
                    },
                    onConfirmOverride: () => _onStaffConfirmBooking(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerSelector(double scale) {
    return InkWell(
      onTap: _showCustomerSearchDialog,
      borderRadius: BorderRadius.circular(12 * scale),
      child: Container(
        padding: EdgeInsets.all(14 * scale),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12 * scale),
          border: Border.all(
            color: _selectedCustomer != null
                ? AppColors.primary
                : AppColors.borderLight,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.person,
              color: _selectedCustomer != null
                  ? AppColors.primary
                  : AppColors.textSecondary,
            ),
            SizedBox(width: 12 * scale),
            Expanded(
              child: _selectedCustomer == null
                  ? Text(
                      'Chọn khách hàng để đặt gói',
                      style: AppTextStyles.arimo(
                        fontSize: 13 * scale,
                        color: AppColors.textSecondary,
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedCustomer!.displayName,
                          style: AppTextStyles.arimo(
                            fontSize: 14 * scale,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2 * scale),
                        Text(
                          _selectedCustomer!.email,
                          style: AppTextStyles.arimo(
                            fontSize: 12 * scale,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

