import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_strings.dart';
import 'package:dio/dio.dart';
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
  Future<NowPackageModel?>? _nowPackageFuture;

  @override
  void initState() {
    super.initState();
    _nowPackageFuture = _loadNowPackage();
  }

  Future<NowPackageModel?> _loadNowPackage() async {
    try {
      final response = await ApiClient.dio.get(ApiEndpoints.nowPackage);
      
      final data = response.data;
      if (data is List) {
        if (data.isNotEmpty && data.first != null) {
          return NowPackageModel.fromJson(data.first as Map<String, dynamic>);
        }
        return null;
      } else if (data is Map<String, dynamic>) {
        return NowPackageModel.fromJson(data);
      }
      return null;
    } catch (e) {
      if (e is DioException) {
        // If it's a 400 or 404, it might mean the user has no package
        if (e.response?.statusCode == 404 || e.response?.statusCode == 400) {
          return null;
        }
      }
      rethrow;
    }
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
      body: FutureBuilder<NowPackageModel?>(
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
                        Text(AppStrings.loadPackagesError),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _refreshNowPackage,
                          child: Text(AppStrings.retry),
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
                  return ServiceDashboard(
                    nowPackage: nowPackage,
                    onRefresh: _refreshNowPackage,
                  );
                } else {
                  return CurrentPackageView(
                    nowPackage: nowPackage,
                    onRefresh: _refreshNowPackage,
                  );
                }
              }

              return ServiceLocationSelection(
                onLocationSelected: (locationType) {
                  if (locationType == ServiceLocationType.center) {
                    context.read<BookingBloc>().add(const BookingReset());
                  }

                  final bookingBloc = context.read<BookingBloc>();

                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                      builder: (routeContext) {
                        return BlocProvider.value(
                          value: bookingBloc,
                          child: locationType == ServiceLocationType.home
                              ? HomeServiceBookingScreen(
                                  onBackToLocationSelection: () {
                                    Navigator.of(routeContext).pop();
                                  },
                                )
                              : Scaffold(
                                  backgroundColor: AppColors.background,
                                  body: BlocConsumer<BookingBloc, BookingState>(
                                    listener: (consumerContext, bookingState) {
                                      if (bookingState is BookingCreated) {
                                        AppRouter.pushReplacement(
                                          consumerContext,
                                          AppRoutes.payment,
                                          arguments: {
                                            'booking': bookingState.booking,
                                            'bookingBloc': bookingBloc,
                                            'paymentType': 'Deposit',
                                          },
                                        );
                                      } else if (bookingState is BookingError) {
                                        AppToast.showError(
                                          consumerContext,
                                          message: bookingState.message,
                                        );
                                      }
                                    },
                                    builder: (consumerContext, _) {
                                      return ServicesBookingFlow(
                                        locationType: locationType,
                                        onBackToLocationSelection: () {
                                          bookingBloc.add(const BookingReset());
                                          Navigator.of(routeContext).pop();
                                        },
                                      );
                                    },
                                  ),
                                ),
                        );
                      },
                    ),
                  ).then((_) {
                    if (context.mounted && locationType == ServiceLocationType.center) {
                      bookingBloc.add(const BookingReset());
                    }
                  });
                },
              );
        },
      ),
    );
  }
}

