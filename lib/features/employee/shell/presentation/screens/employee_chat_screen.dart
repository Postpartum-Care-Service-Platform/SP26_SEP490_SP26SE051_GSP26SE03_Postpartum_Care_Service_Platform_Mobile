import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/utils/app_responsive.dart';
import '../../../../../core/widgets/app_app_bar.dart';
import '../../../../../core/routing/app_router.dart';
import '../../../../../core/routing/app_routes.dart';
import '../../../../../features/chat/presentation/bloc/chat_bloc.dart';
import '../../../../../features/chat/presentation/bloc/chat_event.dart';
import '../../../../../features/chat/presentation/bloc/chat_state.dart';
import '../../../../../features/chat/presentation/widgets/conversation_detail.dart';
import '../../../../../features/chat/presentation/widgets/conversation_list.dart';  
import '../widgets/employee_scaffold.dart';

/// Màn hình chat dành riêng cho staff.
/// Nghiệp vụ: Staff chỉ nhận và trả lời tin nhắn từ khách hàng,
/// không được tạo cuộc trò chuyện mới.
class EmployeeChatScreen extends StatefulWidget {
  final VoidCallback? onBackToDefaultStaffPage;

  const EmployeeChatScreen({
    super.key,
    this.onBackToDefaultStaffPage,
  });

  @override
  State<EmployeeChatScreen> createState() => _EmployeeChatScreenState();
}

class _EmployeeChatScreenState extends State<EmployeeChatScreen> {
  late final ChatBloc _chatBloc;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _messageScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _chatBloc = InjectionContainer.chatBloc;
    // Load conversations and support requests on initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chatBloc.add(const ChatLoadAllConversationsRequested());
      _chatBloc.add(const ChatLoadSupportRequestsRequested());
      _chatBloc.add(const ChatLoadMySupportRequestsRequested());
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _messageScrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_messageScrollController.hasClients) return;
      _messageScrollController.animateTo(
        _messageScrollController.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _chatBloc,
      child: BlocListener<ChatBloc, ChatState>(
        listenWhen: (previous, current) =>
            previous.selectedConversation != current.selectedConversation ||
            previous.supportRequestActionStatus !=
                current.supportRequestActionStatus,
        listener: (context, state) {
          // Reload support requests sau khi accept/resolve
          if (state.supportRequestActionStatus ==
              ChatSupportRequestActionStatus.success) {
            context.read<ChatBloc>().add(
              const ChatLoadSupportRequestsRequested(),
            );
            context.read<ChatBloc>().add(
              const ChatLoadMySupportRequestsRequested(),
            );
          }
        },
        child: BlocBuilder<ChatBloc, ChatState>(
          builder: (context, state) {
            _scrollToBottom();
            final width = MediaQuery.sizeOf(context).width;
            final isDesktop = width >= AppResponsive.desktopBp;
            final scale = AppResponsive.scaleFactor(context);

            return EmployeeScaffold(
              appBar: AppAppBar(
                title: 'Trao đổi',
                centerTitle: true,
                backgroundColor: AppColors.primary,
                titleColor: AppColors.white,
                onBackPressed: widget.onBackToDefaultStaffPage,
              ),
              body: SafeArea(
                child: Padding(
                  padding: AppResponsive.pagePadding(context),
                  child: _buildConversationsView(
                    context,
                    state,
                    isDesktop,
                    scale,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildConversationsView(
    BuildContext context,
    ChatState state,
    bool isDesktop,
    double scale,
  ) {
    if (isDesktop) {
      return Row(
        children: [
          SizedBox(
            width: 320 * scale,
            child: ConversationList(
              onCreate: null, // Staff không được tạo conversation mới
            ),
          ),
          SizedBox(width: 16 * scale),
          Expanded(
            child: ConversationDetail(
              onSupport: null, // Staff không được gửi yêu cầu hỗ trợ
              controller: _messageController,
              scrollController: _messageScrollController,
              isStaff: true, // Đánh dấu là staff mode
            ),
          ),
        ],
      );
    }

    // Mobile view: Only show list, tapping navigates to separate detail screen
    return ConversationList(
      onCreate: null,
      onConversationTap: (id) {
        AppRouter.push(
          context,
          AppRoutes.employeeChat,
          arguments: {'conversationId': id},
        );
      },
    );
  }
}
