import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../booking/presentation/bloc/booking_bloc.dart';
import '../../../booking/presentation/bloc/booking_event.dart';
import '../../../booking/presentation/bloc/booking_state.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/routing/app_routes.dart';
import '../widgets/current_package_view.dart';
import '../widgets/service_dashboard.dart';
import '../widgets/services_booking_flow.dart';
import '../widgets/service_location_selection.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  ServiceLocationType? _selectedLocationType;

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
          final authState = context.watch<AuthBloc>().state;

          if (authState is AuthLoading) {
            return const Center(
              child: AppLoadingIndicator(color: AppColors.primary),
            );
          }

          if (authState is AuthCurrentAccountLoaded) {
            final nowPackage = authState.account.nowPackage;

            if (nowPackage != null) {
              if (nowPackage.serviceIsActive) {
                return ServiceDashboard(nowPackage: nowPackage);
              } else {
                return CurrentPackageView(nowPackage: nowPackage);
              }
            }

            // Chưa có gói hiện tại → cho chọn loại dịch vụ trước khi vào flow đặt gói
            if (_selectedLocationType == null) {
              return ServiceLocationSelection(
                onLocationSelected: (locationType) {
                  // Reset booking flow để tránh giữ state cũ
                  context.read<BookingBloc>().add(const BookingReset());
                  setState(() {
                    _selectedLocationType = locationType;
                  });
                },
              );
            }

            return ServicesBookingFlow(
              locationType: _selectedLocationType!,
            );
          }

          // Trường hợp chưa load account hoặc lỗi: fallback hiển thị màn chọn loại dịch vụ
          if (_selectedLocationType == null) {
            return ServiceLocationSelection(
              onLocationSelected: (locationType) {
                context.read<BookingBloc>().add(const BookingReset());
                setState(() {
                  _selectedLocationType = locationType;
                });
              },
            );
          }

          return ServicesBookingFlow(
            locationType: _selectedLocationType!,
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
