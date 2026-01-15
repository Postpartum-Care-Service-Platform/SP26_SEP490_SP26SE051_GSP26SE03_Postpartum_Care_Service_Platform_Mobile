import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/widgets/app_loading.dart';

class Composer extends StatelessWidget {
  final void Function(String text) onSend;
  final bool sending;
  final TextEditingController controller;

  const Composer({
    super.key,
    required this.onSend,
    required this.sending,
    required this.controller,
  });

  void _submit() {
    final text = controller.text.trim();
    if (text.isEmpty || sending) return;
    onSend(text);
    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    return Container(
      padding: EdgeInsets.all(12 * scale),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(18 * scale),
        ),
        border: const Border(
          top: BorderSide(color: AppColors.borderLight),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14 * scale),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 6,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: AppStrings.chatSendPlaceholder,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 14 * scale,
                    vertical: 12 * scale,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          SizedBox(width: 10 * scale),
          SizedBox(
            height: 46 * scale,
            child: ElevatedButton(
              onPressed: sending ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14 * scale),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16 * scale),
              ),
              child: sending
                  ? AppLoadingIndicator(
                      size: 16 * scale,
                      color: AppColors.white,
                    )
                  : const Icon(Icons.send_rounded, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

