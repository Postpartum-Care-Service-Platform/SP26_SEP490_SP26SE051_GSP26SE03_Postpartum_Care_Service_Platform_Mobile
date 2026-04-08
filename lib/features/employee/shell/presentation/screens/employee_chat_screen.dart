import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/utils/app_responsive.dart';
import '../../../../../core/widgets/app_app_bar.dart';
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
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _messageScrollController = ScrollController();

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
    return BlocProvider(
      create: (_) {
        final bloc = InjectionContainer.chatBloc;
        // Load tất cả conversations và support requests khi màn hình được khởi tạo
        WidgetsBinding.instance.addPostFrameCallback((_) {
          bloc.add(const ChatLoadAllConversationsRequested());
          bloc.add(const ChatLoadSupportRequestsRequested());
          bloc.add(const ChatLoadMySupportRequestsRequested());
        });
        return bloc;
      },
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
    return isDesktop
        ? Row(
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
          )
        : Column(
            children: [
              SizedBox(
                height: 280 * scale,
                child: ConversationList(
                  onCreate: null, // Staff không được tạo conversation mới
                ),
              ),
              SizedBox(height: 12 * scale),
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
}
