import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';

class MessengerComposer extends StatelessWidget {
  final bool sending;
  final TextEditingController controller;
  final void Function(String text) onSend;

  const MessengerComposer({
    super.key,
    required this.sending,
    required this.controller,
    required this.onSend,
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
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(
        12 * scale,
        8 * scale,
        12 * scale,
        bottomPadding + 10 * scale,
      ),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.7),
        border: Border(
          top: BorderSide(
            color: Colors.black.withValues(alpha: 0.06),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(18 * scale),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      minLines: 1,
                      maxLines: 6,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      decoration: InputDecoration(
                        hintText: AppStrings.chatInputHintShort,
                        hintStyle: TextStyle(
                          color: AppColors.third,
                          fontSize: 16 * scale,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 14 * scale,
                          vertical: 8 * scale,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 4 * scale),
                  IconButton(
                    onPressed: sending ? null : _submit,
                    icon: Icon(
                      Icons.send_rounded,
                      size: 20 * scale,
                      color: sending ? AppColors.third : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

