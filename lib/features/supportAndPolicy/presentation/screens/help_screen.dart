import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/routing/app_routes.dart';

/// Help Screen - FAQ and support information
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppAppBar(
        title: AppStrings.helpTitle,
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(16 * scale),
          children: [
            // FAQ Section
            _buildSection(
              context,
              title: AppStrings.helpFaq,
              icon: Icons.question_answer_outlined,
              children: [
                _buildFAQItem(
                  context,
                  question: 'Làm thế nào để đặt gói dịch vụ?',
                  answer:
                      'Bạn có thể đặt gói dịch vụ bằng cách vào mục "Dịch vụ" trên thanh điều hướng, chọn gói phù hợp và làm theo hướng dẫn đặt phòng.',
                ),
                SizedBox(height: 12 * scale),
                _buildFAQItem(
                  context,
                  question: 'Làm thế nào để thanh toán?',
                  answer:
                      'Sau khi đặt phòng, bạn sẽ được chuyển đến màn hình thanh toán. Chúng tôi hỗ trợ thanh toán qua PayOS bằng mã QR hoặc link thanh toán.',
                ),
                SizedBox(height: 12 * scale),
                _buildFAQItem(
                  context,
                  question: 'Làm thế nào để hủy đặt phòng?',
                  answer:
                      'Bạn có thể hủy đặt phòng trong mục "Lịch hẹn". Vui lòng kiểm tra chính sách hủy bỏ trong hợp đồng dịch vụ của bạn.',
                ),
                SizedBox(height: 12 * scale),
                _buildFAQItem(
                  context,
                  question: 'Làm thế nào để xem lịch trình nghỉ dưỡng?',
                  answer:
                      'Sau khi đặt phòng thành công, bạn có thể xem lịch trình nghỉ dưỡng trong mục "Dịch vụ" > "Lịch trình mỗi ngày".',
                ),
              ],
            ),

            SizedBox(height: 24 * scale),

            // How to Use Section
            _buildSection(
              context,
              title: AppStrings.helpHowToUse,
              icon: Icons.book_outlined,
              children: [
                _buildInfoCard(
                  context,
                  title: 'Đăng ký tài khoản',
                  content:
                      'Tạo tài khoản bằng email hoặc đăng nhập bằng Google để bắt đầu sử dụng dịch vụ.',
                ),
                SizedBox(height: 12 * scale),
                _buildInfoCard(
                  context,
                  title: 'Đặt gói dịch vụ',
                  content:
                      'Chọn gói dịch vụ phù hợp, chọn phòng và ngày check-in, sau đó xác nhận đặt phòng.',
                ),
                SizedBox(height: 12 * scale),
                _buildInfoCard(
                  context,
                  title: 'Thanh toán',
                  content:
                      'Thanh toán đặt cọc để hoàn tất đặt phòng. Phần thanh toán còn lại sẽ được mở sau khi hợp đồng được ký.',
                ),
                SizedBox(height: 12 * scale),
                _buildInfoCard(
                  context,
                  title: 'Sử dụng dịch vụ',
                  content:
                      'Xem lịch trình nghỉ dưỡng, thực đơn mỗi ngày, đăng ký dịch vụ spa và yêu cầu tiện ích trong ứng dụng.',
                ),
              ],
            ),

            SizedBox(height: 24 * scale),

            // Troubleshooting Section
            _buildSection(
              context,
              title: AppStrings.helpTroubleshooting,
              icon: Icons.build_outlined,
              children: [
                _buildInfoCard(
                  context,
                  title: 'Không thể đăng nhập',
                  content:
                      'Kiểm tra lại email và mật khẩu. Nếu quên mật khẩu, sử dụng tính năng "Quên mật khẩu" để đặt lại.',
                ),
                SizedBox(height: 12 * scale),
                _buildInfoCard(
                  context,
                  title: 'Thanh toán không thành công',
                  content:
                      'Kiểm tra kết nối internet và thông tin thanh toán. Nếu vấn đề vẫn tiếp tục, vui lòng liên hệ hỗ trợ.',
                ),
                SizedBox(height: 12 * scale),
                _buildInfoCard(
                  context,
                  title: 'Không nhận được thông báo',
                  content:
                      'Kiểm tra cài đặt thông báo trong ứng dụng và trên thiết bị của bạn.',
                ),
              ],
            ),

            SizedBox(height: 24 * scale),

            // Contact Support Button
            AppWidgets.primaryButton(
              text: AppStrings.helpContactSupport,
              onPressed: () => AppRouter.push(context, AppRoutes.contact),
            ),

            SizedBox(height: 24 * scale),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final scale = AppResponsive.scaleFactor(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 24 * scale,
              color: AppColors.primary,
            ),
            SizedBox(width: 8 * scale),
            Text(
              title,
              style: AppTextStyles.tinos(
                fontSize: 20 * scale,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        SizedBox(height: 16 * scale),
        ...children,
      ],
    );
  }

  Widget _buildFAQItem(
    BuildContext context, {
    required String question,
    required String answer,
  }) {
    final scale = AppResponsive.scaleFactor(context);

    return AppWidgets.sectionContainer(
      context,
      padding: EdgeInsets.all(16 * scale),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.help_outline_rounded,
              size: 20 * scale,
              color: AppColors.primary,
            ),
            SizedBox(width: 12 * scale),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question,
                    style: AppTextStyles.arimo(
                      fontSize: 15 * scale,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8 * scale),
                  Text(
                    answer,
                    style: AppTextStyles.arimo(
                      fontSize: 14 * scale,
                      fontWeight: FontWeight.normal,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    final scale = AppResponsive.scaleFactor(context);

    return AppWidgets.sectionContainer(
      context,
      padding: EdgeInsets.all(16 * scale),
      children: [
        Text(
          title,
          style: AppTextStyles.arimo(
            fontSize: 15 * scale,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8 * scale),
        Text(
          content,
          style: AppTextStyles.arimo(
            fontSize: 14 * scale,
            fontWeight: FontWeight.normal,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
