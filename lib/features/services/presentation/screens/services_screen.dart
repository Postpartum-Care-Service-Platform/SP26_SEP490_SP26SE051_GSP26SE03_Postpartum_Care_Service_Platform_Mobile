import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/apis/api_client.dart';
import '../../../../core/apis/api_endpoints.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../auth/data/models/current_account_model.dart';
import '../../../booking/presentation/bloc/booking_bloc.dart';
import '../../../booking/presentation/bloc/booking_event.dart';
import '../../../booking/presentation/bloc/booking_state.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/routing/app_routes.dart';
import '../widgets/current_package_view.dart';
import '../widgets/service_dashboard.dart';
import '../widgets/services_booking_flow.dart';
import '../widgets/service_location_selection.dart';
import '../../../home_service/presentation/screens/home_service_booking_screen.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  ServiceLocationType? _selectedLocationType;
  Future<NowPackageModel>? _nowPackageFuture;

  @override
  void initState() {
    super.initState();
    _nowPackageFuture = _loadNowPackage();
  }

  Future<NowPackageModel> _loadNowPackage() async {
    final response = await ApiClient.dio.get(ApiEndpoints.nowPackage);
    return NowPackageModel.fromJson(response.data as Map<String, dynamic>);
  }

  void _refreshNowPackage() {
    setState(() {
      _nowPackageFuture = _loadNowPackage();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Check if BookingBloc already exists to avoid creating duplicate
    BookingBloc? existingBookingBloc;
    try {
      existingBookingBloc = context.read<BookingBloc>();
    } catch (_) {
      // BookingBloc not found, will create new one
    }

    return (existingBookingBloc != null
            ? BlocProvider.value(
                value: existingBookingBloc,
                child: _buildContent(),
              )
            : BlocProvider(
                create: (context) {
                  // Create new bloc but DON'T load packages here
                  // Let ServicesBookingFlow handle loading when needed
                  return InjectionContainer.bookingBloc;
                },
                child: _buildContent(),
              ));
  }

  Widget _buildContent() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<BookingBloc, BookingState>(
        listener: _handleBookingSideEffects,
        builder: (context, _) {
          return FutureBuilder<NowPackageModel>(
            future: _nowPackageFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: AppLoadingIndicator(color: AppColors.primary),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(height: 12),
                        const Text('Không thể tải gói dịch vụ hiện tại'),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _refreshNowPackage,
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final nowPackage = snapshot.data;

              if (nowPackage != null) {
                final isFullyPaid = nowPackage.remainingAmount <= 0;

                if (nowPackage.isServiceUnlocked && isFullyPaid) {
                  return ServiceDashboard(nowPackage: nowPackage);
                } else {
                  return CurrentPackageView(nowPackage: nowPackage);
                }
              }

              // Chưa có gói hiện tại → cho chọn loại dịch vụ trước khi vào flow đặt gói
              if (_selectedLocationType == null) {
                return ServiceLocationSelection(
                  onLocationSelected: (locationType) {
                    if (locationType == ServiceLocationType.center) {
                      context.read<BookingBloc>().add(const BookingReset());
                    }
                    setState(() {
                      _selectedLocationType = locationType;
                    });
                  },
                );
              }

              if (_selectedLocationType == ServiceLocationType.home) {
                return HomeServiceBookingScreen(
                  onBackToLocationSelection: () {
                    setState(() {
                      _selectedLocationType = null;
                    });
                  },
                );
              }

              return ServicesBookingFlow(
                locationType: _selectedLocationType!,
                onBackToLocationSelection: () {
                  context.read<BookingBloc>().add(const BookingReset());
                  setState(() {
                    _selectedLocationType = null;
                  });
                },
              );
            },
          );
        },
      ),
    );
  }

  void _handleBookingSideEffects(BuildContext context, BookingState state) {
    if (state is BookingCreated) {
      final bookingBloc = context.read<BookingBloc>();
      AppRouter.push(
        context,
        AppRoutes.payment,
        arguments: {
          'booking': state.booking,
          'bookingBloc': bookingBloc,
          'paymentType': 'Deposit',
        },
      );
    } else if (state is BookingError) {
      AppToast.showError(
        context,
        message: state.message,
      );
    }
  }
}
