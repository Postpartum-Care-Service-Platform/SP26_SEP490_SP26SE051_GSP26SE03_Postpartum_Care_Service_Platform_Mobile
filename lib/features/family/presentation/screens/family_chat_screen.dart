// lib/features/family/presentation/screens/family_chat_screen.dart
// NOTE: Ported from ChatView in Familystay FamilyPortal.tsx
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';

class FamilyChatScreen extends StatefulWidget {
  const FamilyChatScreen({super.key});

  @override
  State<FamilyChatScreen> createState() => _FamilyChatScreenState();
}

class _FamilyChatScreenState extends State<FamilyChatScreen> {
  // Controller for the input.
  final TextEditingController _controller = TextEditingController();

  // Ported mock messages.
  final List<_ChatMessage> _messages = [
    const _ChatMessage(sender: 'Điều dưỡng Mai', time: '09:30', message: 'Chào chị, hôm nay chị có cảm thấy khỏe hơn không ạ?'),
    const _ChatMessage(sender: 'Tôi', time: '09:32', message: 'Dạ em cảm thấy tốt hơn nhiều ạ. Cảm ơn chị đã chăm sóc tận tình!'),
    const _ChatMessage(sender: 'Điều dưỡng Mai', time: '09:35', message: 'Tuyệt vời ạ! Chiều nay em sẽ qua massage phục hồi cho chị nhé.'),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      return;
    }

    setState(() {
      _messages.add(_ChatMessage(sender: 'Tôi', time: _nowHHmm(), message: text));
      _controller.clear();
    });
  }

  String _nowHHmm() {
    final now = TimeOfDay.now();
    final hh = now.hour.toString().padLeft(2, '0');
    final mm = now.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    final padding = AppResponsive.pagePadding(context);

    return Scaffold(
      backgroundColor: AppColors.familyBackground,
      appBar: AppBar(
        backgroundColor: AppColors.white.withValues(alpha: 0.95),
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: Text(
          'Nhắn tin',
          style: AppTextStyles.arimo(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
      ),
      body: Column(
        children: [
          // Messages.
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(padding.left, 16, padding.right, 16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isMe = msg.sender == 'Tôi';

                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.sizeOf(context).width * 0.75,
                    ),
                    child: _ChatBubble(message: msg, isMe: isMe),
                  ),
                );
              },
            ),
          ),

          // Input.
          Container(
            padding: EdgeInsets.fromLTRB(padding.left, 10, padding.right, 10),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.90),
              border: Border(top: BorderSide(color: AppColors.borderLight)),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'iMessage',
                        filled: true,
                        fillColor: const Color(0xFFF3F4F6),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(999),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _send,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: AppColors.familyPrimary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_upward, color: AppColors.white, size: 20),
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

class _ChatBubble extends StatelessWidget {
  final _ChatMessage message;
  final bool isMe;

  const _ChatBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final bg = isMe ? AppColors.familyPrimary : AppColors.white;
    final fg = isMe ? AppColors.white : AppColors.textPrimary;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomLeft: Radius.circular(isMe ? 20 : 6),
          bottomRight: Radius.circular(isMe ? 6 : 20),
        ),
        boxShadow: isMe
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) ...[
            Text(
              message.sender,
              style: AppTextStyles.arimo(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 6),
          ],
          Text(
            message.message,
            style: AppTextStyles.arimo(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: fg,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message.time,
            style: AppTextStyles.arimo(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isMe ? AppColors.white.withValues(alpha: 0.7) : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String sender;
  final String time;
  final String message;

  const _ChatMessage({
    required this.sender,
    required this.time,
    required this.message,
  });
}
