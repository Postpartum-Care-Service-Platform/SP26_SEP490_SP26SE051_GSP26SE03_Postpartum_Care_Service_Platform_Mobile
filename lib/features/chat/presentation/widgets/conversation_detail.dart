import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/services/current_account_cache_service.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/constants/app_assets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/chat_conversation.dart';
import '../../domain/entities/support_request.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import 'chat_app_bar.dart';
import 'composer.dart';
import 'empty_placeholder.dart';
import 'message_bubble.dart';
import 'messenger_composer.dart';
import 'messenger_top_bar.dart';

class ConversationDetail extends StatelessWidget {
  /// null nếu không cho phép gửi yêu cầu hỗ trợ (staff mode).
  final VoidCallback? onSupport;
  final VoidCallback? onBack;
  final TextEditingController controller;
  final ScrollController scrollController;

  /// true nếu đây là staff mode (sẽ dùng staff-message endpoint)
  final bool isStaff;

  const ConversationDetail({
    super.key,
    required this.onSupport,
    this.onBack,
    required this.controller,
    required this.scrollController,
    this.isStaff = false,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    final messengerStyle = onBack != null;
    return FutureBuilder(
      future: CurrentAccountCacheService.getCurrentAccount(),
      builder: (context, snapshot) {
        final currentAccount = snapshot.data;

        return BlocConsumer<ChatBloc, ChatState>(
          listenWhen: (p, c) =>
              p.supportStatus != c.supportStatus ||
              p.sendStatus != c.sendStatus ||
              p.errorMessage != c.errorMessage,
          listener: (context, state) {
            if (state.supportStatus == ChatSupportStatus.success) {
              AppToast.showSuccess(
                context,
                message: AppStrings.chatRequestSupportSuccess,
              );
            }
            if (state.errorMessage != null &&
                (state.sendStatus == ChatSendStatus.failure ||
                    state.supportStatus == ChatSupportStatus.failure ||
                    state.conversationDetailStatus == ChatStatus.failure)) {
              AppToast.showError(context, message: state.errorMessage!);
            }
          },
          builder: (context, state) {
            final conversation = state.selectedConversation;
            if (state.conversationDetailStatus == ChatStatus.loading) {
              return const Center(
                child: AppLoadingIndicator(color: AppColors.primary),
              );
            }
            if (conversation == null) {
              return EmptyPlaceholder(
                icon: Icons.chat_bubble_outline_rounded,
                title: AppStrings.chatEmptyMessage,
                subtitle: isStaff 
                  ? 'Hãy chọn một cuộc hội thoại để bắt đầu hỗ trợ'
                  : AppStrings.chatTypingHint,
              );
            }

            final messages = List<ChatMessage>.from(conversation.messages)
              ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
            final showTyping = state.isAiTyping && !conversation.hasActiveSupport;

            final content = Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (messengerStyle)
                  MessengerTopBar(
                    title: conversation.name,
                    subtitle: AppStrings.chatMessengerLabel,
                    onBack: onBack!,
                    onSupport: onSupport,
                  )
                else
                  ChatAppBar(
                    title: conversation.name,
                    customerInfo: conversation.customerInfo,
                    onSupport: onSupport,
                    onBack: onBack,
                    isStaff: isStaff,
                  ),
                if (!messengerStyle)
                  const Divider(height: 1, color: AppColors.borderLight),
                if (isStaff) _buildSupportBanner(context, state, conversation, scale),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16 * scale,
                      vertical: 12 * scale,
                    ),
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: (isStaff ? 0 : 1) + messages.length + (showTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        // Intro banner (scrolls with messages) - Hide for staff
                        if (!isStaff && index == 0) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: 12 * scale),
                            child: const _AiIntroBanner(),
                          );
                        }

                        final messageIndex = isStaff ? index : index - 1;

                        if (showTyping && messageIndex == messages.length) {
                          return Padding(
                            padding: EdgeInsets.only(top: 4 * scale),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12 * scale,
                                  vertical: 8 * scale,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  borderRadius: BorderRadius.circular(
                                    16 * scale,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 18 * scale,
                                      height: 6 * scale,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: List.generate(
                                          3,
                                          (i) => Container(
                                            width: 4 * scale,
                                            height: 4 * scale,
                                            decoration: BoxDecoration(
                                              color: AppColors.textSecondary
                                                  .withValues(alpha: 0.7),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8 * scale),
                                    Text(
                                      AppStrings.chatAiTypingStatus,
                                      style: AppTextStyles.arimo(
                                        fontSize: 12 * scale,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }

                        final message = messages[messageIndex];
                        final sender = message.senderType.toLowerCase();

                        bool isDifferentGroup(ChatMessage a, ChatMessage b) {
                          if (a.senderType.toLowerCase() != b.senderType.toLowerCase()) return true;
                          return a.createdAt.year != b.createdAt.year ||
                                 a.createdAt.month != b.createdAt.month ||
                                 a.createdAt.day != b.createdAt.day ||
                                 a.createdAt.hour != b.createdAt.hour ||
                                 a.createdAt.minute != b.createdAt.minute;
                        }

                        final prevMessage = messageIndex > 0 ? messages[messageIndex - 1] : null;
                        final nextMessage = messageIndex < messages.length - 1 ? messages[messageIndex + 1] : null;

                        final isFirstInGroup = prevMessage == null || isDifferentGroup(message, prevMessage);
                        final isLastInGroup = nextMessage == null || isDifferentGroup(message, nextMessage);

                        final isAI = sender == 'ai';
                        final isStaffMessage =
                            sender == 'staff' ||
                            sender == 'employee' ||
                            sender == 'nurse' ||
                            sender == 'consultant';

                        // Logic isMine: So sánh senderId của tin nhắn với ID của tài khoản hiện tại
                        final isMine = message.senderId != null && 
                                      currentAccount != null && 
                                      message.senderId == currentAccount.id;

                        // Force initials per requirement: AI => "AI", staff => "NV"
                        final displayName = isAI
                            ? 'AI'
                            : (isStaffMessage
                                  ? 'NV'
                                  : (isMine
                                        ? (currentAccount?.displayName ?? 'Bạn')
                                        : (message.senderName ?? 'NV')));
                        final avatarUrl = isMine
                            ? currentAccount?.avatarUrl
                            : null;
                        final structured =
                            state.aiStructuredByMessageId[message.id];

                        return MessageBubble(
                          message: message,
                          isMine: isMine,
                          isAI: isAI,
                          isFirstInGroup: isFirstInGroup,
                          isLastInGroup: isLastInGroup,
                          displayName: displayName,
                          avatarUrl: avatarUrl,
                          structuredData: structured,
                        );
                      },
                    ),
                  ),
                ),
                if (messengerStyle)
                  MessengerComposer(
                    controller: controller,
                    onSend: (text) => context.read<ChatBloc>().add(
                      ChatSendMessageSubmitted(text, isStaff: isStaff),
                    ),
                    sending: state.sendStatus == ChatSendStatus.sending,
                  )
                else
                  Composer(
                    controller: controller,
                    onSend: (text) {
                      context.read<ChatBloc>().add(
                        ChatSendMessageSubmitted(text, isStaff: isStaff),
                      );
                    },
                    sending: state.sendStatus == ChatSendStatus.sending,
                  ),
              ],
            );

            if (messengerStyle) {
              return Container(
                color: AppColors.white,
                child: SafeArea(top: true, bottom: true, child: content),
              );
            }

            return Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(18 * scale),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 16 * scale,
                    offset: Offset(0, 6 * scale),
                  ),
                ],
              ),
              child: content,
            );
          },
        );
      },
    );
  }

  Widget _buildSupportBanner(
    BuildContext context,
    ChatState state,
    ChatConversation conversation,
    double scale,
  ) {
    // Tìm yêu cầu hỗ trợ cho cuộc trò chuyện này
    final myRequest = state.mySupportRequests.where(
      (r) => r.conversationId == conversation.id && r.status.toLowerCase() != 'resolved',
    ).firstOrNull;

    if (myRequest != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: Colors.green[50],
        child: Row(
          children: [
            const Icon(Icons.support_agent, color: Colors.green),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Bạn đang hỗ trợ yêu cầu này',
                style: TextStyle(
                  fontSize: 13 * scale,
                  color: Colors.green[800],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                context.read<ChatBloc>().add(
                  ChatResolveSupportRequestSubmitted(myRequest.id),
                );
              },
              child: const Text('Hoàn thành'),
            ),
          ],
        ),
      );
    }

    final pendingRequest = state.supportRequests.where(
      (r) => r.conversationId == conversation.id,
    ).firstOrNull;

    if (pendingRequest != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: Colors.orange[50],
        child: Row(
          children: [
            const Icon(Icons.help_outline, color: Colors.orange),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Khách hàng đang chờ hỗ trợ',
                style: TextStyle(
                  fontSize: 13 * scale,
                  color: Colors.orange[800],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<ChatBloc>().add(
                  ChatAcceptSupportRequestSubmitted(pendingRequest.id),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                visualDensity: VisualDensity.compact,
              ),
              child: const Text('Nhận hỗ trợ'),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

class _AiIntroBanner extends StatelessWidget {
  const _AiIntroBanner();

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 16 * scale,
        // Giảm padding dọc một chút để tránh tràn khi hiển thị kèm bottom nav nhân viên
        vertical: 12 * scale,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 52 * scale,
            height: 52 * scale,
            child: SvgPicture.asset(
              AppAssets.appIconThird,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(height: 8 * scale),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppStrings.chatAiAssistantTitle,
                style: AppTextStyles.tinos(
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(width: 6 * scale),
              Icon(
                Icons.verified_rounded,
                size: 18 * scale,
                color: AppColors.primary,
              ),
            ],
          ),
          SizedBox(height: 2 * scale),
          Text(
            AppStrings.chatAiIntroLine1,
            textAlign: TextAlign.center,
            style: AppTextStyles.arimo(
              fontSize: 12 * scale,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 4 * scale),
          Text(
            AppStrings.chatAiIntroLine2,
            textAlign: TextAlign.center,
            style: AppTextStyles.arimo(
              fontSize: 11 * scale,
              color: AppColors.textSecondary.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}
