import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/contract_bloc.dart';
import '../bloc/contract_event.dart';
import '../bloc/contract_state.dart';

class ContractScreen extends StatefulWidget {
  final int bookingId;

  const ContractScreen({
    super.key,
    required this.bookingId,
  });

  @override
  State<ContractScreen> createState() => _ContractScreenState();
}

class _ContractScreenState extends State<ContractScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ContractBloc>().add(
              ContractLoadByBookingId(widget.bookingId),
            );
      }
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'Draft':
        return AppStrings.contractStatusDraft;
      case 'Signed':
        return AppStrings.contractStatusSigned;
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Draft':
        return AppColors.textSecondary;
      case 'Signed':
        return AppColors.verified;
      default:
        return AppColors.textSecondary;
    }
  }

  Future<void> _downloadContractPdf(int contractId) async {
    final contractBloc = context.read<ContractBloc>();
    contractBloc.add(ContractExportPdf(contractId));
  }

  Future<void> _saveAndOpenPdf(List<int> pdfBytes, int contractId) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/contract_$contractId.pdf');
      await file.writeAsBytes(pdfBytes);
      
      // Try to open the file using url_launcher
      final uri = Uri.file(file.path);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      
      if (mounted) {
        AppToast.showSuccess(
          context,
          message: 'Đã tải hợp đồng thành công',
        );
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(
          context,
          message: 'Không thể lưu file PDF: $e',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return BlocProvider(
      create: (context) => InjectionContainer.contractBloc,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppAppBar(
          title: AppStrings.contractTitle,
          centerTitle: true,
          titleFontSize: 20 * scale,
          titleFontWeight: FontWeight.w700,
        ),
        body: BlocConsumer<ContractBloc, ContractState>(
          listener: (context, state) {
            if (state is ContractPdfExported) {
              _saveAndOpenPdf(state.pdfBytes, state.contractId);
            } else if (state is ContractError) {
              AppToast.showError(
                context,
                message: state.message,
              );
            }
          },
          builder: (context, state) {
            if (state is ContractLoading) {
              return const Center(child: AppLoadingIndicator());
            }

            if (state is ContractError) {
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
                      style: AppTextStyles.arimo(
                        fontSize: 16 * scale,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24 * scale),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ContractBloc>().add(
                              ContractLoadByBookingId(widget.bookingId),
                            );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                      ),
                      child: Text(AppStrings.retry),
                    ),
                  ],
                ),
              );
            }

            if (state is ContractLoaded) {
              final contract = state.contract;
              return SingleChildScrollView(
                padding: EdgeInsets.all(16 * scale),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Contract Card
                    Container(
                      padding: EdgeInsets.all(20 * scale),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16 * scale),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8 * scale,
                            offset: Offset(0, 2 * scale),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Contract Code and Status
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppStrings.contractCode,
                                      style: AppTextStyles.arimo(
                                        fontSize: 12 * scale,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    SizedBox(height: 4 * scale),
                                    Text(
                                      contract.contractCode,
                                      style: AppTextStyles.tinos(
                                        fontSize: 20 * scale,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12 * scale,
                                  vertical: 6 * scale,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(contract.status)
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8 * scale),
                                ),
                                child: Text(
                                  _getStatusLabel(contract.status),
                                  style: AppTextStyles.arimo(
                                    fontSize: 12 * scale,
                                    fontWeight: FontWeight.w600,
                                    color: _getStatusColor(contract.status),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20 * scale),
                          Divider(height: 1, color: AppColors.borderLight),
                          SizedBox(height: 20 * scale),
                          // Contract Details
                          _InfoRow(
                            icon: Icons.calendar_today_rounded,
                            label: AppStrings.contractDate,
                            value: _formatDate(contract.contractDate),
                            scale: scale,
                          ),
                          SizedBox(height: 16 * scale),
                          _InfoRow(
                            icon: Icons.event_available_rounded,
                            label: AppStrings.contractEffectiveFrom,
                            value: _formatDate(contract.effectiveFrom),
                            scale: scale,
                          ),
                          SizedBox(height: 16 * scale),
                          _InfoRow(
                            icon: Icons.event_busy_rounded,
                            label: AppStrings.contractEffectiveTo,
                            value: _formatDate(contract.effectiveTo),
                            scale: scale,
                          ),
                          if (contract.signedDate != null) ...[
                            SizedBox(height: 16 * scale),
                            _InfoRow(
                              icon: Icons.edit_calendar_rounded,
                              label: AppStrings.contractSignedDate,
                              value: _formatDate(contract.signedDate!),
                              scale: scale,
                            ),
                          ],
                          if (contract.checkinDate != null) ...[
                            SizedBox(height: 16 * scale),
                            _InfoRow(
                              icon: Icons.login_rounded,
                              label: AppStrings.contractCheckinDate,
                              value: _formatDate(contract.checkinDate!),
                              scale: scale,
                            ),
                          ],
                          if (contract.checkoutDate != null) ...[
                            SizedBox(height: 16 * scale),
                            _InfoRow(
                              icon: Icons.logout_rounded,
                              label: AppStrings.contractCheckoutDate,
                              value: _formatDate(contract.checkoutDate!),
                              scale: scale,
                            ),
                          ],
                          if (contract.customer != null) ...[
                            SizedBox(height: 20 * scale),
                            Divider(height: 1, color: AppColors.borderLight),
                            SizedBox(height: 20 * scale),
                            Text(
                              AppStrings.contractCustomer,
                              style: AppTextStyles.tinos(
                                fontSize: 16 * scale,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 12 * scale),
                            _InfoRow(
                              icon: Icons.person_rounded,
                              label: 'Tên',
                              value: contract.customer!.username,
                              scale: scale,
                            ),
                            SizedBox(height: 12 * scale),
                            _InfoRow(
                              icon: Icons.email_rounded,
                              label: 'Email',
                              value: contract.customer!.email,
                              scale: scale,
                            ),
                            if (contract.customer!.phone != null) ...[
                              SizedBox(height: 12 * scale),
                              _InfoRow(
                                icon: Icons.phone_rounded,
                                label: 'Số điện thoại',
                                value: contract.customer!.phone!,
                                scale: scale,
                              ),
                            ],
                          ],
                          SizedBox(height: 24 * scale),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => _downloadContractPdf(contract.id),
                              icon: Icon(Icons.download_rounded, size: 20 * scale),
                              label: Text(AppStrings.contractDownloadPdf),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.white,
                                padding: EdgeInsets.symmetric(vertical: 14 * scale),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12 * scale),
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
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final double scale;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20 * scale,
          color: AppColors.textSecondary,
        ),
        SizedBox(width: 12 * scale),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.arimo(
                  fontSize: 12 * scale,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 4 * scale),
              Text(
                value,
                style: AppTextStyles.arimo(
                  fontSize: 14 * scale,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
