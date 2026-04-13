import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/utils/app_responsive.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../services/domain/entities/vietqr_bank.dart';
import '../../../domain/entities/payment_link_entity.dart';
import '../../../../../core/utils/vietqr_parser.dart';

class QRCodeSection extends StatefulWidget {
  final PaymentLinkEntity paymentLink;

  const QRCodeSection({
    super.key,
    required this.paymentLink,
  });

  @override
  State<QRCodeSection> createState() => _QRCodeSectionState();
}

class _QRCodeSectionState extends State<QRCodeSection> {
  List<VietQrBank>? _bankApps;
  List<VietQrBank>? _allBanks;
  bool _isLoadingApps = false;

  Future<void> _loadBankApps() async {
    if (_bankApps != null) return;

    setState(() {
      _isLoadingApps = true;
    });

    try {
      final appUseCase = InjectionContainer.getVietQrDeeplinkApps;
      final bankUseCase = InjectionContainer.getVietQrBanks;
      
      final results = await Future.wait([
        appUseCase.execute(),
        bankUseCase.execute(),
      ]);

      if (mounted) {
        setState(() {
          _bankApps = results[0] as List<VietQrBank>;
          _allBanks = results[1] as List<VietQrBank>;
          _isLoadingApps = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingApps = false;
        });
      }
    }
  }

  Future<void> _openBankApp(VietQrBank app) async {
    final qrData = widget.paymentLink.qrCode;
    
    // 1. Parse QR data to get account and bank info for the requested parameters
    final parsed = VietQrParser.parse(qrData);
    final recipient = VietQrParser.getRecipientInfo(parsed);
    final account = recipient?['account'] ?? '';
    final bin = recipient?['bin'] ?? '';
    
    // Look up short code (e.g. mb, vcb) from BIN (970422, 970436)
    String bankShortCode = bin; // Fallback to BIN if not found
    if (_allBanks != null) {
      try {
        final bank = _allBanks!.firstWhere((b) => b.bin == bin);
        bankShortCode = bank.code.toLowerCase();
      } catch (_) {}
    }

    final name = VietQrParser.getBeneficiaryName(parsed) ?? 'VO MINH TIEN';
    final amount = widget.paymentLink.amount.toInt();
    final description = widget.paymentLink.orderCode;
    
    // Use a standard HTTPS URL for the return path to ensure compatibility with all bank apps
    final returnUrl = 'https://payos.vn';
    
    // 2. Construct the Smart URL Bridge with exactly 6 parameters
    // Fully encode the 'ba' parameter (especially the @ symbol) for standard compliance
    final encodedBa = Uri.encodeComponent('$account@$bankShortCode');
    
    final smartUrl = 'https://dl.vietqr.io/pay?app=${app.appId}' 
                    '&ba=$encodedBa'
                    '&am=$amount'
                    '&tn=${Uri.encodeComponent(description)}'
                    '&bn=${Uri.encodeComponent(name)}'
                    '&url=${Uri.encodeComponent(returnUrl)}';
    
    final uri = Uri.parse(smartUrl);

    // Debug logging
    debugPrint('--- VIETQR DEEPLINK (6 PARAMETERS) ---');
    debugPrint('ba: $account@$bin');
    debugPrint('am: $amount');
    debugPrint('tn: $description');
    debugPrint('app: ${app.appId}');
    debugPrint('bn: $name');
    debugPrint('url: $returnUrl');
    debugPrint('---------------------------------------');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // Final fallback to the web payment URL
      final fallbackUri = Uri.parse(widget.paymentLink.paymentUrl);
      if (await canLaunchUrl(fallbackUri)) {
        await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
      }
    }
  }

  void _showBankPicker(BuildContext context) {
    _loadBankApps();
    final scale = AppResponsive.scaleFactor(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24 * scale)),
            ),
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 12 * scale),
                  width: 40 * scale,
                  height: 4 * scale,
                  decoration: BoxDecoration(
                    color: AppColors.borderLight,
                    borderRadius: BorderRadius.circular(2 * scale),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(20 * scale),
                  child: Row(
                    children: [
                      Text(
                        AppStrings.paymentSelectBankTitle,
                        style: AppTextStyles.arimo(
                          fontSize: 18 * scale,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: _isLoadingApps
                      ? const Center(child: CircularProgressIndicator())
                      : (_bankApps == null || _bankApps!.isEmpty)
                          ? Center(child: Text(AppStrings.paymentNoBankApps))
                          : GridView.builder(
                              padding: EdgeInsets.all(20 * scale),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 20 * scale,
                                crossAxisSpacing: 16 * scale,
                                childAspectRatio: 0.8,
                              ),
                              itemCount: _bankApps!.length,
                              itemBuilder: (context, index) {
                                final app = _bankApps![index];
                                return InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                    _openBankApp(app);
                                  },
                                  borderRadius: BorderRadius.circular(12 * scale),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 60 * scale,
                                        height: 60 * scale,
                                        padding: EdgeInsets.all(8 * scale),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(16 * scale),
                                          border: Border.all(color: AppColors.borderLight),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.05),
                                              blurRadius: 5,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(8 * scale),
                                          child: Image.network(
                                            app.logo,
                                            fit: BoxFit.contain,
                                            errorBuilder: (_, __, ___) => const Icon(Icons.account_balance),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 10 * scale),
                                      Text(
                                        app.displayName,
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyles.arimo(
                                          fontSize: 12 * scale,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Container(
      padding: EdgeInsets.all(24 * scale),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20 * scale),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 20 * scale,
            offset: Offset(0, 4 * scale),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10 * scale,
            offset: Offset(0, 2 * scale),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.qr_code_2_rounded,
                size: 20 * scale,
                color: AppColors.primary,
              ),
              SizedBox(width: 8 * scale),
              Text(
                AppStrings.paymentQRCode,
                style: AppTextStyles.arimo(
                  fontSize: 18 * scale,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ).copyWith(letterSpacing: 0.3),
              ),
            ],
          ),
          SizedBox(height: 24 * scale),
          Container(
            padding: EdgeInsets.all(20 * scale),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.white,
                  AppColors.background,
                ],
              ),
              borderRadius: BorderRadius.circular(16 * scale),
              border: Border.all(
                color: AppColors.borderLight,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8 * scale,
                  offset: Offset(0, 2 * scale),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(12 * scale),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12 * scale),
                  ),
                  child: QrImageView(
                    data: widget.paymentLink.qrCode,
                    version: QrVersions.auto,
                    size: 220 * scale,
                    padding: EdgeInsets.zero,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: AppColors.textPrimary,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                IgnorePointer(
                  child: Container(
                    width: 55 * scale,
                    height: 55 * scale,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16 * scale),
                    ),
                    child: SvgPicture.asset(
                      AppAssets.appIconThird,
                      fit: BoxFit.contain,
                      colorFilter: const ColorFilter.mode(
                        AppColors.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16 * scale),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 10 * scale),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10 * scale),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 16 * scale,
                  color: AppColors.primary,
                ),
                SizedBox(width: 6 * scale),
                Flexible(
                  child: Text(
                    AppStrings.paymentScanQR,
                    style: AppTextStyles.arimo(
                      fontSize: 13 * scale,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24 * scale),
          Row(
            children: [
              Expanded(
                child: Divider(color: AppColors.borderLight, thickness: 1),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16 * scale),
                child: Text(
                  AppStrings.paymentOr,
                  style: AppTextStyles.arimo(
                    fontSize: 14 * scale,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: Divider(color: AppColors.borderLight, thickness: 1),
              ),
            ],
          ),
          SizedBox(height: 20 * scale),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showBankPicker(context),
              icon: Icon(Icons.account_balance_rounded, size: 20 * scale),
              label: Text(
                AppStrings.paymentOpenBankApp,
                style: AppTextStyles.arimo(
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: EdgeInsets.symmetric(vertical: 14 * scale),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12 * scale),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

