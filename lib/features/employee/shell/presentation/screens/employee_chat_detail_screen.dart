import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/utils/app_responsive.dart';
import '../../../../../features/chat/presentation/bloc/chat_bloc.dart';
import '../../../../../features/chat/presentation/bloc/chat_event.dart';
import '../../../../../features/chat/presentation/bloc/chat_state.dart';
import '../../../../../features/chat/presentation/widgets/conversation_detail.dart';
import '../widgets/employee_scaffold.dart';

/// Màn hình chi tiết cuộc hội thoại dành riêng cho Staff.
/// Chỉ hiển thị nội dung chat giữa Staff và Khách hàng.
class EmployeeChatDetailScreen extends StatefulWidget {
  final int conversationId;

  const EmployeeChatDetailScreen({
    super.key,
    required this.conversationId,
  });

  @override
  State<EmployeeChatDetailScreen> createState() => _EmployeeChatDetailScreenState();
}

class _EmployeeChatDetailScreenState extends State<EmployeeChatDetailScreen> {
  late final ChatBloc _chatBloc;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _messageScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _chatBloc = InjectionContainer.chatBloc;
    
    // Đảm bảo conversation được chọn và load chi tiết
    _chatBloc.add(ChatConversationSelected(widget.conversationId));
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
      child: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          _scrollToBottom();
          final scale = AppResponsive.scaleFactor(context);

          return EmployeeScaffold(
            // Ẩn FAB vì trong màn chat không cần menu tiện ích nhanh gây vướng
            showFab: false,
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 12 * scale,
                  vertical: 8 * scale,
                ),
                child: ConversationDetail(
                  onSupport: null, // Staff không tự yêu cầu hỗ trợ chính mình
                  onBack: () => Navigator.of(context).pop(),
                  controller: _messageController,
                  scrollController: _messageScrollController,
                  isStaff: true, // Chế độ nhân viên
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
