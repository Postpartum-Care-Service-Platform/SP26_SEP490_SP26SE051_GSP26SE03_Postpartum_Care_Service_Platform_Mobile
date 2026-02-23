import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../bloc/amenity_bloc.dart';
import '../bloc/amenity_event.dart';
import '../bloc/amenity_state.dart';
import '../widgets/amenity_ticket_card.dart';
import '../widgets/create_amenity_ticket_sheet.dart';
import '../widgets/amenity_service_card.dart';

/// Amenity Screen
/// Displays user's amenity tickets and allows creating new tickets
class AmenityScreen extends StatefulWidget {
  const AmenityScreen({super.key});

  @override
  State<AmenityScreen> createState() => _AmenityScreenState();
}

class _AmenityScreenState extends State<AmenityScreen> {
  @override
  void initState() {
    super.initState();
    // Load services and tickets on init
    context.read<AmenityBloc>()
      ..add(const AmenityServicesLoadRequested())
      ..add(const MyAmenityTicketsLoadRequested());
  }

  void _handleCreateTicket() {
    final state = context.read<AmenityBloc>().state;
    if (state is AmenityLoaded) {
      CreateAmenityTicketSheet.show(context, state.services);
    } else {
      // Load services first
      context.read<AmenityBloc>().add(const AmenityServicesLoadRequested());
      // Wait a bit then show sheet
      Future.delayed(const Duration(milliseconds: 500), () {
        final newState = context.read<AmenityBloc>().state;
        if (newState is AmenityLoaded && mounted) {
          CreateAmenityTicketSheet.show(context, newState.services);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return BlocListener<AmenityBloc, AmenityState>(
      listener: (context, state) {
        if (state is AmenityError) {
          AppLoading.hide(context);
          AppToast.showError(context, message: state.message);
        } else if (state is AmenityLoaded) {
          AppLoading.hide(context);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppAppBar(
          title: AppStrings.amenityTitle,
          showBackButton: true,
          centerTitle: true,
        ),
        body: BlocBuilder<AmenityBloc, AmenityState>(
          builder: (context, state) {
            if (state is AmenityLoading) {
              return Center(
                child: AppLoadingIndicator(
                  color: AppColors.primary,
                ),
              );
            }

            if (state is AmenityLoaded) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<AmenityBloc>().add(const AmenityRefresh());
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(20 * scale),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Available Services Section
                      if (state.services.isNotEmpty) ...[
                        _buildSectionHeader(
                          context,
                          scale,
                          AppStrings.amenityAvailableServices,
                        ),
                        SizedBox(height: 12 * scale),
                        _buildServicesGrid(context, scale, state.services),
                        SizedBox(height: 24 * scale),
                      ],

                      // My Tickets Section
                      _buildSectionHeader(
                        context,
                        scale,
                        AppStrings.amenityMyTickets,
                      ),
                      SizedBox(height: 12 * scale),
                      if (state.tickets.isEmpty)
                        _buildEmptyState(context, scale)
                      else
                        _buildTicketsList(context, scale, state.tickets),
                    ],
                  ),
                ),
              );
            }

            if (state is AmenityError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64 * scale,
                      color: AppColors.red,
                    ),
                    SizedBox(height: 16 * scale),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.arimo(
                        fontSize: 14 * scale,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 24 * scale),
                    AppWidgets.primaryButton(
                      text: AppStrings.retry,
                      onPressed: () {
                        context.read<AmenityBloc>().add(const AmenityRefresh());
                      },
                      width: 200 * scale,
                    ),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: AppWidgets.primaryFabIcon(
          context: context,
          iconSvg: AppAssets.serviceAmenity,
          onPressed: _handleCreateTicket,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, double scale, String title) {
    return Text(
      title,
      style: AppTextStyles.tinos(
        fontSize: 20 * scale,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildServicesGrid(
    BuildContext context,
    double scale,
    List services,
  ) {
    // Filter only active services
    final activeServices = services.where((s) => s.isActive).toList();
    
    if (activeServices.isEmpty) {
      return Container(
        padding: EdgeInsets.all(24 * scale),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16 * scale),
          border: Border.all(
            color: AppColors.borderLight,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            'Không có dịch vụ tiện ích nào',
            style: AppTextStyles.arimo(
              fontSize: 14 * scale,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 240 * scale, // Fixed height for horizontal scroll
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(vertical: 4 * scale),
        itemCount: activeServices.length,
        separatorBuilder: (context, index) => SizedBox(width: 12 * scale),
        itemBuilder: (context, index) {
          return SizedBox(
            width: 180 * scale, // Fixed width for each card
            child: AmenityServiceCard(
              service: activeServices[index],
              onTap: () {
                // Show service details or create ticket with this service
                final state = context.read<AmenityBloc>().state;
                if (state is AmenityLoaded) {
                  CreateAmenityTicketSheet.show(
                    context,
                    state.services,
                    preselectedService: activeServices[index],
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildTicketsList(
    BuildContext context,
    double scale,
    List tickets,
  ) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tickets.length,
      separatorBuilder: (context, index) => SizedBox(height: 12 * scale),
      itemBuilder: (context, index) {
        return AmenityTicketCard(ticket: tickets[index]);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, double scale) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(32 * scale),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12 * scale,
            offset: Offset(0, 4 * scale),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.room_service_outlined,
            size: 64 * scale,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 16 * scale),
          Text(
            AppStrings.amenityNoTickets,
            style: AppTextStyles.arimo(
              fontSize: 16 * scale,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8 * scale),
          Text(
            AppStrings.amenityCreateFirst,
            style: AppTextStyles.arimo(
              fontSize: 14 * scale,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
