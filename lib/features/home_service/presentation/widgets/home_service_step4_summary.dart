import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../bloc/home_service_bloc.dart';
import '../bloc/home_service_event.dart';
import '../bloc/home_service_state.dart';

class HomeServiceStep4Summary extends StatelessWidget {
  const HomeServiceStep4Summary({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return BlocConsumer<HomeServiceBloc, HomeServiceState>(
      listener: (context, state) {
        if (state is HomeServiceBookingCreated) {
          context.read<HomeServiceBloc>().add(
                const HomeServiceCreatePaymentLink(type: 'Full'),
              );
        } else if (state is HomeServicePaymentLinkCreated) {
          // TODO: Create payment screen for home service or reuse existing one
        }
      },
      builder: (context, state) {
        if (state is HomeServiceSummaryReady) {
          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.all(16 * scale),
                    children: [
                      Text(
                        'Xác nhận thông tin',
                        style: AppTextStyles.tinos(
                          fontSize: 20 * scale,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16 * scale),
                      Text(
                        'Tổng tiền: ${state.totalPrice.toStringAsFixed(0)} đ',
                        style: AppTextStyles.arimo(
                          fontSize: 16 * scale,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8 * scale),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        if (state is HomeServiceLoading) {
          return const Center(child: AppLoadingIndicator());
        }

        return const SizedBox();
      },
    );
  }
}
