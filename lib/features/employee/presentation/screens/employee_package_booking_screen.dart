import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../widgets/employee_scaffold.dart';
import '../../../booking/presentation/bloc/booking_bloc.dart';
import '../../../booking/presentation/bloc/booking_event.dart';
import '../../../booking/presentation/bloc/booking_state.dart';
import '../../../booking/presentation/screens/payment_screen.dart';
import '../../../employee/data/datasources/account_remote_datasource.dart';
import '../../../employee/data/models/account_model.dart';
import '../../../services/presentation/widgets/services_booking_flow.dart';

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
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Chọn khách hàng',
            style: AppTextStyles.arimo(
              fontSize: 16 * scale,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Tìm theo tên, email, SĐT',
                  ),
                ),
                const SizedBox(height: 12),
                if (_isLoadingCustomers)
                  const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _filteredCustomers.length,
                      itemBuilder: (context, index) {
                        final c = _filteredCustomers[index];
                        return ListTile(
                          title: Text(c.displayName),
                          subtitle: Text(
                            [
                              c.email,
                              if (c.phone != null && c.phone!.isNotEmpty) c.phone!,
                            ].join(' • '),
                          ),
                          onTap: () => _selectCustomer(c),
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

