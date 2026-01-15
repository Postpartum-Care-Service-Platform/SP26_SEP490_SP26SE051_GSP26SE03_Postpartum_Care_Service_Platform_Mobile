import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../domain/entities/chat_conversation.dart';
import '../../domain/entities/chat_message.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import 'chat_time_utils.dart';
import 'empty_placeholder.dart';

class ConversationList extends StatelessWidget {
  final VoidCallback onCreate;
  final ValueChanged<int>? onConversationTap;

  const ConversationList({
    super.key,
    required this.onCreate,
    this.onConversationTap,
  });

  DateTime _lastActivityTime(ChatConversation conversation) {
    var latest = conversation.createdAt;
    for (final message in conversation.messages) {
      if (message.createdAt.isAfter(latest)) {
        latest = message.createdAt;
      }
    }
    return latest;
  }

  ChatMessage? _latestMessage(ChatConversation conversation) {
    if (conversation.messages.isEmpty) return null;
    ChatMessage latest = conversation.messages.first;
    for (final message in conversation.messages.skip(1)) {
      if (message.createdAt.isAfter(latest.createdAt)) {
        latest = message;
      }
    }
    return latest;
  }

  String _buildPreviewText(ChatMessage? message) {
    if (message == null) return AppStrings.chatTypingHint;
    var text = message.content.trim();
    if (text.isEmpty) return AppStrings.chatTypingHint;

    // Bỏ các dòng bảng markdown và separator '---'
    final lines = text.split('\n');
    final buffer = <String>[];
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      if (trimmed.startsWith('|')) continue;
      if (trimmed.startsWith('---')) continue;
      buffer.add(trimmed);
    }
    text = buffer.join(' ');

    // Loại bỏ các ký hiệu markdown đơn giản: **bold**, _italic_, __bold__, ~~del~~
    text = text
        .replaceAllMapped(
            RegExp(r'(\*\*|__)(.+?)(\*\*|__)'), (m) => m[2] ?? '')
        .replaceAllMapped(RegExp(r'(\*|_)(.+?)(\*|_)'), (m) => m[2] ?? '')
        .replaceAllMapped(
            RegExp(r'(~~)(.+?)(~~)'), (m) => m[2] ?? '');

    // Thu gọn khoảng trắng
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();

    if (text.isEmpty) return AppStrings.chatTypingHint;
    return text;
  }

  List<ChatConversation> _filterConversations(
    List<ChatConversation> conversations,
    String searchQuery,
  ) {
    if (searchQuery.isEmpty) {
      return conversations;
    }
    
    final query = searchQuery.toLowerCase().trim();
    return conversations.where((conversation) {
      // Search in conversation name
      if (conversation.name.toLowerCase().contains(query)) {
        return true;
      }
      
      // Search in message content
      for (final message in conversation.messages) {
        if (message.content.toLowerCase().contains(query)) {
          return true;
        }
      }
      
      return false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    return BlocBuilder<ChatBloc, ChatState>(
      buildWhen: (p, c) =>
          p.conversations != c.conversations ||
          p.conversationsStatus != c.conversationsStatus ||
          p.selectedConversation?.id != c.selectedConversation?.id ||
          p.searchQuery != c.searchQuery,
      builder: (context, state) {
        final filteredConversations = _filterConversations(
          state.conversations,
          state.searchQuery,
        );
        // Show loading if initial or loading state
        if (state.conversationsStatus == ChatStatus.initial ||
            state.conversationsStatus == ChatStatus.loading) {
          return const Center(
            child: AppLoadingIndicator(color: AppColors.primary),
          );
        }
        
        // Show error state if failed
        if (state.conversationsStatus == ChatStatus.failure) {
          return EmptyPlaceholder(
            icon: Icons.wifi_off,
            title: AppStrings.chatLoadError,
            actionLabel: AppStrings.retry,
            onAction: () =>
                context.read<ChatBloc>().add(const ChatRefreshRequested()),
          );
        }
        
        // Only show empty state if we have successfully loaded
        if (state.conversationsStatus == ChatStatus.success) {
          // Show empty state if no conversations at all
          if (state.conversations.isEmpty) {
            return EmptyPlaceholder(
              icon: Icons.chat_bubble_outline_rounded,
              title: AppStrings.chatNoConversation,
              subtitle: AppStrings.chatEmptyMessage,
              actionLabel: AppStrings.chatNewConversation,
              onAction: onCreate,
            );
          }
          
          // Show no results if search query doesn't match any conversations
          if (state.searchQuery.isNotEmpty && filteredConversations.isEmpty) {
            return EmptyPlaceholder(
              icon: Icons.search_off_rounded,
              title: 'Không tìm thấy kết quả',
              subtitle: 'Thử tìm kiếm với từ khóa khác',
              actionLabel: AppStrings.chatNewConversation,
              onAction: onCreate,
            );
          }
        }
        
        // If not success state, show loading as fallback
        if (state.conversationsStatus != ChatStatus.success) {
          return const Center(
            child: AppLoadingIndicator(color: AppColors.primary),
          );
        }

        return Container(
          padding: EdgeInsets.all(12 * scale),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20 * scale),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 18 * scale,
                offset: Offset(0, 8 * scale),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async {
                    context.read<ChatBloc>().add(const ChatRefreshRequested());
                    await Future.delayed(const Duration(milliseconds: 600));
                  },
                  child: ListView.separated(
                    itemCount: filteredConversations.length,
                    separatorBuilder: (_, __) => SizedBox(height: 8 * scale),
                    itemBuilder: (context, index) {
                      final conversation = filteredConversations[index];
                      final isSelected =
                          conversation.id == state.selectedConversation?.id;
                      final lastMessage = _latestMessage(conversation);
                      final previewText = _buildPreviewText(lastMessage);
                      return Material(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.08)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12 * scale),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12 * scale),
                          onTap: () {
                            if (onConversationTap != null) {
                              onConversationTap!(conversation.id);
                              return;
                            }
                            context.read<ChatBloc>().add(
                              ChatConversationSelected(conversation.id),
                            );
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 10 * scale,
                              horizontal: 8 * scale,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 42 * scale,
                                  height: 42 * scale,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.primary.withValues(
                                      alpha: 0.06,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(4 * scale),
                                    child: SvgPicture.asset(
                                      AppAssets.appIconThird,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10 * scale),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              conversation.name,
                                              style: AppTextStyles.arimo(
                                                fontSize: 15 * scale,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.textPrimary,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Text(
                                            formatChatTime(
                                              _lastActivityTime(conversation),
                                            ),
                                            style: AppTextStyles.arimo(
                                              fontSize: 11 * scale,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 4 * scale),
                                      Text(
                                        previewText,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyles.arimo(
                                          fontSize: 12 * scale,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
