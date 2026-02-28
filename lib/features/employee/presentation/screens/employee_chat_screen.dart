import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../chat/presentation/bloc/chat_bloc.dart';
import '../../../chat/presentation/bloc/chat_event.dart';
import '../../../chat/presentation/bloc/chat_state.dart';
import '../../../chat/presentation/widgets/conversation_detail.dart';
import '../../../chat/presentation/widgets/conversation_list.dart';
import '../widgets/employee_scaffold.dart';

/// Màn hình chat dành riêng cho staff.
/// Nghiệp vụ: Staff chỉ nhận và trả lời tin nhắn từ khách hàng,
/// không được tạo cuộc trò chuyện mới.
class EmployeeChatScreen extends StatefulWidget {
  const EmployeeChatScreen({super.key});

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

            return DefaultTabController(
              length: 3,
              child: EmployeeScaffold(
                appBar: AppBar(
                  title: const Text('Trao đổi'),
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  bottom: TabBar(
                    labelColor: AppColors.white,
                    unselectedLabelColor: AppColors.white.withOpacity(0.7),
                    indicatorColor: AppColors.white,
                    tabs: [
                      Tab(text: 'Tất cả (${state.conversations.length})'),
                      Tab(text: 'Chờ xử lý (${state.supportRequests.length})'),
                      Tab(
                        text: 'Đang xử lý (${state.mySupportRequests.length})',
                      ),
                    ],
                  ),
                ),
                body: SafeArea(
                  child: Padding(
                    padding: AppResponsive.pagePadding(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TabBarView(
                            children: [
                              // Tab 1: Tất cả conversations
                              _buildConversationsView(
                                context,
                                state,
                                isDesktop,
                                scale,
                              ),
                              // Tab 2: Support requests đang chờ
                              _buildPendingSupportRequestsView(
                                context,
                                state,
                                scale,
                              ),
                              // Tab 3: Support requests đang xử lý
                              _buildMySupportRequestsView(
                                context,
                                state,
                                scale,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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

  Widget _buildPendingSupportRequestsView(
    BuildContext context,
    ChatState state,
    double scale,
  ) {
    if (state.supportRequestsStatus == ChatStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.supportRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.support_agent_outlined,
              size: 64 * scale,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 16 * scale),
            Text(
              'Không có yêu cầu hỗ trợ đang chờ',
              style: TextStyle(
                fontSize: 16 * scale,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: state.supportRequests.length,
      itemBuilder: (context, index) {
        final request = state.supportRequests[index];
        // Tìm conversation tương ứng để lấy thông tin khách hàng
        final conversation = state.conversations.firstWhere(
          (conv) => conv.id == request.conversationId,
          orElse: () => state.conversations.first,
        );
        final customerInfo = conversation.customerInfo;
        final customerName = customerInfo?['displayName'] ?? 
                            customerInfo?['name'] ?? 
                            customerInfo?['fullName'] ??
                            request.customer ?? 
                            'Khách hàng';
        final customerEmail = customerInfo?['email']?.toString();
        final customerPhone = customerInfo?['phone']?.toString();

        return Card(
          margin: EdgeInsets.only(bottom: 12 * scale),
          elevation: 2,
          child: InkWell(
            onTap: () {
              // Chuyển đến conversation tương ứng
              context.read<ChatBloc>().add(
                ChatConversationSelected(request.conversationId),
              );
              // Chuyển về tab đầu tiên
              DefaultTabController.of(context).animateTo(0);
            },
            child: Padding(
              padding: EdgeInsets.all(16 * scale),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Avatar khách hàng
                      CircleAvatar(
                        radius: 24 * scale,
                        backgroundColor: AppColors.primary,
                        child: Text(
                          customerName.isNotEmpty 
                              ? customerName[0].toUpperCase() 
                              : 'K',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 18 * scale,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(width: 12 * scale),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              customerName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16 * scale,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (customerEmail != null) ...[
                              SizedBox(height: 4 * scale),
                              Row(
                                children: [
                                  Icon(
                                    Icons.email_outlined,
                                    size: 14 * scale,
                                    color: AppColors.textSecondary,
                                  ),
                                  SizedBox(width: 4 * scale),
                                  Expanded(
                                    child: Text(
                                      customerEmail,
                                      style: TextStyle(
                                        fontSize: 12 * scale,
                                        color: AppColors.textSecondary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            if (customerPhone != null) ...[
                              SizedBox(height: 4 * scale),
                              Row(
                                children: [
                                  Icon(
                                    Icons.phone_outlined,
                                    size: 14 * scale,
                                    color: AppColors.textSecondary,
                                  ),
                                  SizedBox(width: 4 * scale),
                                  Text(
                                    customerPhone,
                                    style: TextStyle(
                                      fontSize: 12 * scale,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          context.read<ChatBloc>().add(
                            ChatAcceptSupportRequestSubmitted(request.id),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                        ),
                        child: const Text('Nhận'),
                      ),
                    ],
                  ),
                  SizedBox(height: 12 * scale),
                  Container(
                    padding: EdgeInsets.all(12 * scale),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8 * scale),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16 * scale,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 8 * scale),
                            Text(
                              'Lý do yêu cầu hỗ trợ:',
                              style: TextStyle(
                                fontSize: 12 * scale,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8 * scale),
                        Text(
                          request.reason,
                          style: TextStyle(
                            fontSize: 14 * scale,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8 * scale),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14 * scale,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 4 * scale),
                      Text(
                        'Tạo lúc: ${_formatDateTime(request.createdAt)}',
                        style: TextStyle(
                          fontSize: 12 * scale,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMySupportRequestsView(
    BuildContext context,
    ChatState state,
    double scale,
  ) {
    if (state.mySupportRequestsStatus == ChatStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.mySupportRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64 * scale,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 16 * scale),
            Text(
              'Bạn chưa nhận yêu cầu hỗ trợ nào',
              style: TextStyle(
                fontSize: 16 * scale,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: state.mySupportRequests.length,
      itemBuilder: (context, index) {
        final request = state.mySupportRequests[index];
        final isResolved = request.status.toLowerCase() == 'resolved';
        
        // Tìm conversation tương ứng để lấy thông tin khách hàng
        final conversation = state.conversations.firstWhere(
          (conv) => conv.id == request.conversationId,
          orElse: () => state.conversations.first,
        );
        final customerInfo = conversation.customerInfo;
        final customerName = customerInfo?['displayName'] ?? 
                            customerInfo?['name'] ?? 
                            customerInfo?['fullName'] ??
                            request.customer ?? 
                            'Khách hàng';
        final customerEmail = customerInfo?['email']?.toString();
        final customerPhone = customerInfo?['phone']?.toString();

        return Card(
          margin: EdgeInsets.only(bottom: 12 * scale),
          elevation: 2,
          color: isResolved ? AppColors.primary.withOpacity(0.05) : null,
          child: InkWell(
            onTap: () {
              // Chuyển đến conversation tương ứng
              context.read<ChatBloc>().add(
                ChatConversationSelected(request.conversationId),
              );
              // Chuyển về tab đầu tiên
              DefaultTabController.of(context).animateTo(0);
            },
            child: Padding(
              padding: EdgeInsets.all(16 * scale),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Avatar khách hàng
                      CircleAvatar(
                        radius: 24 * scale,
                        backgroundColor: isResolved 
                            ? AppColors.primary.withOpacity(0.3)
                            : AppColors.primary,
                        child: isResolved
                            ? Icon(
                                Icons.check_circle,
                                color: AppColors.primary,
                                size: 24 * scale,
                              )
                            : Text(
                                customerName.isNotEmpty 
                                    ? customerName[0].toUpperCase() 
                                    : 'K',
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 18 * scale,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                      SizedBox(width: 12 * scale),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    customerName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16 * scale,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                if (isResolved)
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8 * scale,
                                      vertical: 4 * scale,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(12 * scale),
                                    ),
                                    child: Text(
                                      'Đã xử lý',
                                      style: TextStyle(
                                        fontSize: 10 * scale,
                                        color: AppColors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            if (customerEmail != null) ...[
                              SizedBox(height: 4 * scale),
                              Row(
                                children: [
                                  Icon(
                                    Icons.email_outlined,
                                    size: 14 * scale,
                                    color: AppColors.textSecondary,
                                  ),
                                  SizedBox(width: 4 * scale),
                                  Expanded(
                                    child: Text(
                                      customerEmail,
                                      style: TextStyle(
                                        fontSize: 12 * scale,
                                        color: AppColors.textSecondary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            if (customerPhone != null) ...[
                              SizedBox(height: 4 * scale),
                              Row(
                                children: [
                                  Icon(
                                    Icons.phone_outlined,
                                    size: 14 * scale,
                                    color: AppColors.textSecondary,
                                  ),
                                  SizedBox(width: 4 * scale),
                                  Text(
                                    customerPhone,
                                    style: TextStyle(
                                      fontSize: 12 * scale,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (!isResolved)
                        ElevatedButton(
                          onPressed: () {
                            context.read<ChatBloc>().add(
                              ChatResolveSupportRequestSubmitted(request.id),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                          ),
                          child: const Text('Đã xử lý'),
                        ),
                    ],
                  ),
                  SizedBox(height: 12 * scale),
                  Container(
                    padding: EdgeInsets.all(12 * scale),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8 * scale),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16 * scale,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 8 * scale),
                            Text(
                              'Lý do yêu cầu hỗ trợ:',
                              style: TextStyle(
                                fontSize: 12 * scale,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8 * scale),
                        Text(
                          request.reason,
                          style: TextStyle(
                            fontSize: 14 * scale,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8 * scale),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14 * scale,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 4 * scale),
                      Text(
                        'Nhận lúc: ${_formatDateTime(request.assignedAt ?? request.createdAt)}',
                        style: TextStyle(
                          fontSize: 12 * scale,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  if (isResolved && request.resolvedAt != null) ...[
                    SizedBox(height: 4 * scale),
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 14 * scale,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 4 * scale),
                        Text(
                          'Đã xử lý: ${_formatDateTime(request.resolvedAt!)}',
                          style: TextStyle(
                            fontSize: 12 * scale,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Vừa xong';
        }
        return '${difference.inMinutes} phút trước';
      }
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays == 1) {
      return 'Hôm qua';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    }
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
