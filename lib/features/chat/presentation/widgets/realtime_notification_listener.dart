import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/utils/app_responsive.dart';
import 'package:flutter/services.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';

class RealtimeNotificationListener extends StatefulWidget {
  final Widget child;

  const RealtimeNotificationListener({super.key, required this.child});

  @override
  State<RealtimeNotificationListener> createState() =>
      _RealtimeNotificationListenerState();
}

class _RealtimeNotificationListenerState
    extends State<RealtimeNotificationListener> {
  StreamSubscription? _messageSubscription;
  StreamSubscription? _staffJoinedSubscription;
  StreamSubscription? _supportResolvedSubscription;
  OverlayEntry? _overlayEntry;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    final hub = InjectionContainer.chatHubService;
    _messageSubscription = hub.messages.listen(_handleNewMessage);
    _staffJoinedSubscription = hub.staffJoined.listen(_handleStaffJoined);
    _supportResolvedSubscription = hub.supportResolved.listen(
      _handleSupportResolved,
    );
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _staffJoinedSubscription?.cancel();
    _supportResolvedSubscription?.cancel();
    _dismissTimer?.cancel();
    _removeOverlay();
    super.dispose();
  }

  void _handleStaffJoined(dynamic data) {
    if (!mounted) return;
    _showNotification(
      title: 'Nhân viên hỗ trợ',
      message: '${data.staffName} đã tham gia cuộc hội thoại',
      conversationId: data.conversationId,
      icon: Icons.person_add_outlined,
    );
  }

  void _handleSupportResolved(dynamic data) {
    if (!mounted) return;
    _showNotification(
      title: 'Hỗ trợ hoàn tất',
      message: 'Yêu cầu hỗ trợ của bạn đã được giải quyết',
      conversationId: data.conversationId,
      icon: Icons.check_circle_outline,
      color: Colors.green,
    );
  }

  void _handleNewMessage(dynamic data) {
    if (!mounted) return;

    final chatState = context.read<ChatBloc>().state;

    // Don't show notification if user is already in the conversation
    if (chatState.selectedConversation?.id == data.conversationId) {
      return;
    }

    // Don't show if it's our own message (though SignalR usually doesn't echo back
    // unless configured, but better safe)
    // Here we assume senderType 'customer' is the current user for customer app
    if (data.message.senderType.toLowerCase() == 'customer') {
      return;
    }

    _showNotification(
      title: data.message.senderName ?? 'Tin nhắn mới',
      message: data.message.content,
      conversationId: data.conversationId,
      avatarUrl: data.message.senderId != null
          ? null
          : null, // Future: fetch avatar if needed
    );
  }

  void _showNotification({
    required String title,
    required String message,
    required int conversationId,
    IconData? icon,
    Color? color,
    String? avatarUrl,
  }) {
    _removeOverlay();

    // Add haptic feedback for a "push" feel
    HapticFeedback.vibrate();

    _overlayEntry = OverlayEntry(
      builder: (context) => _NotificationBanner(
        title: title,
        message: message,
        icon: icon,
        iconColor: color,
        avatarUrl: avatarUrl,
        onTap: () {
          _removeOverlay();
          context.read<ChatBloc>().add(
            ChatConversationSelected(conversationId),
          );
        },
        onDismiss: _removeOverlay,
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);

    _dismissTimer = Timer(const Duration(seconds: 4), () {
      _removeOverlay();
    });
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _dismissTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _NotificationBanner extends StatefulWidget {
  final String title;
  final String message;
  final IconData? icon;
  final Color? iconColor;
  final String? avatarUrl;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotificationBanner({
    required this.title,
    required this.message,
    this.icon,
    this.iconColor,
    this.avatarUrl,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  State<_NotificationBanner> createState() => _NotificationBannerState();
}

class _NotificationBannerState extends State<_NotificationBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    final topPadding = MediaQuery.of(context).padding.top + 10 * scale;

    return Positioned(
      top: topPadding,
      left: 12 * scale,
      right: 12 * scale,
      child: SlideTransition(
        position: _offsetAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: widget.onTap,
              onVerticalDragUpdate: (details) {
                if (details.delta.dy < -5) widget.onDismiss();
              },
              child: Container(
                padding: EdgeInsets.all(12 * scale),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.98),
                  borderRadius: BorderRadius.circular(20 * scale),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 20 * scale,
                      offset: const Offset(0, 8),
                      spreadRadius: 2,
                    ),
                  ],
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    _buildLeading(scale),
                    SizedBox(width: 12 * scale),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.title,
                            style: AppTextStyles.arimo(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2 * scale),
                          Text(
                            widget.message,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.arimo(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        size: 20 * scale,
                        color: AppColors.third,
                      ),
                      onPressed: widget.onDismiss,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeading(double scale) {
    if (widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty) {
      return Container(
        width: 44 * scale,
        height: 44 * scale,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: NetworkImage(widget.avatarUrl!),
            fit: BoxFit.cover,
          ),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      );
    }

    return Container(
      width: 44 * scale,
      height: 44 * scale,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.iconColor ?? AppColors.primary,
            (widget.iconColor ?? AppColors.primary).withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: (widget.iconColor ?? AppColors.primary).withValues(
              alpha: 0.3,
            ),
            blurRadius: 8 * scale,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(
        widget.icon ?? Icons.chat_bubble_rounded,
        color: Colors.white,
        size: 22 * scale,
      ),
    );
  }
}
