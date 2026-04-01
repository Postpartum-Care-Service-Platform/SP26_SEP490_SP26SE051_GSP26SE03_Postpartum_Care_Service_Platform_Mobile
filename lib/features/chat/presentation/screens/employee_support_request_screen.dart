// lib/features/chat/presentation/screens/employee_support_request_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/routing/app_router.dart';
import '../../../../../core/routing/app_routes.dart';
import '../../../../../core/utils/app_responsive.dart';
import '../../../../../features/chat/presentation/bloc/chat_bloc.dart';
import '../../../../../features/chat/presentation/bloc/chat_event.dart';
import '../../../../../features/chat/presentation/bloc/chat_state.dart';
import '../../../../../features/employee/shell/presentation/widgets/employee_scaffold.dart';

class EmployeeSupportRequestScreen extends StatefulWidget {
  const EmployeeSupportRequestScreen({super.key});

  @override
  State<EmployeeSupportRequestScreen> createState() => _EmployeeSupportRequestScreenState();
}

class _EmployeeSupportRequestScreenState extends State<EmployeeSupportRequestScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: InjectionContainer.chatBloc,
      child: BlocListener<ChatBloc, ChatState>(
        listenWhen: (previous, current) =>
            previous.supportRequestActionStatus != current.supportRequestActionStatus,
        listener: (context, state) {
          if (state.supportRequestActionStatus == ChatSupportRequestActionStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Thao tác thành công'),
                backgroundColor: AppColors.primary,
              ),
            );
            context.read<ChatBloc>().add(const ChatLoadSupportRequestsRequested());
            context.read<ChatBloc>().add(const ChatLoadMySupportRequestsRequested());
          } else if (state.supportRequestActionStatus == ChatSupportRequestActionStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Thao tác thất bại. Vui lòng thử lại.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<ChatBloc, ChatState>(
          builder: (context, state) {
            final scale = AppResponsive.scaleFactor(context);

            return DefaultTabController(
              length: 2,
              child: EmployeeScaffold(
                appBar: AppBar(
                  title: const Text('Yêu cầu hỗ trợ'),
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  bottom: TabBar(
                    labelColor: AppColors.white,
                    unselectedLabelColor: AppColors.white.withValues(alpha: 0.7),
                    indicatorColor: AppColors.white,
                    tabs: [
                      Tab(text: 'Chờ xử lý (${state.supportRequests.length})'),
                      Tab(text: 'Của tôi (${state.mySupportRequests.length})'),
                    ],
                  ),
                ),
                body: SafeArea(
                  child: Padding(
                    padding: AppResponsive.pagePadding(context),
                    child: TabBarView(
                      children: [
                        _buildPendingSupportRequestsView(context, state, scale),
                        _buildMySupportRequestsView(context, state, scale),
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

  Widget _buildPendingSupportRequestsView(
    BuildContext context,
    ChatState state,
    double scale,
  ) {
    if (state.supportRequestsStatus == ChatStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.supportRequests.isEmpty) {
      return _buildEmptyState(
        icon: Icons.support_agent_outlined,
        message: 'Không có yêu cầu hỗ trợ đang chờ',
        scale: scale,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<ChatBloc>().add(const ChatLoadSupportRequestsRequested());
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 12),
        itemCount: state.supportRequests.length,
        itemBuilder: (context, index) {
          final request = state.supportRequests[index];
          return _SupportRequestCard(
            request: request,
            scale: scale,
            isPending: true,
            onTap: () => _navigateToChat(context, request.conversationId),
            onAction: () {
              context.read<ChatBloc>().add(
                ChatAcceptSupportRequestSubmitted(request.id),
              );
            },
          );
        },
      ),
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
      return _buildEmptyState(
        icon: Icons.assignment_ind_outlined,
        message: 'Bạn chưa nhận yêu cầu hỗ trợ nào',
        scale: scale,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<ChatBloc>().add(const ChatLoadMySupportRequestsRequested());
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 12),
        itemCount: state.mySupportRequests.length,
        itemBuilder: (context, index) {
          final request = state.mySupportRequests[index];
          final isResolved = request.status.toLowerCase() == 'resolved';

          return _SupportRequestCard(
            request: request,
            scale: scale,
            isPending: false,
            onTap: () => _navigateToChat(context, request.conversationId),
            onAction: isResolved ? null : () {
              context.read<ChatBloc>().add(
                ChatResolveSupportRequestSubmitted(request.id),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    required double scale,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64 * scale, color: AppColors.textSecondary.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16 * scale,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToChat(BuildContext context, int conversationId) {
    context.read<ChatBloc>().add(ChatConversationSelected(conversationId));
    AppRouter.push(context, AppRoutes.employeeChat);
  }
}

class _SupportRequestCard extends StatelessWidget {
  final dynamic request;
  final double scale;
  final bool isPending;
  final VoidCallback onTap;
  final VoidCallback? onAction;

  const _SupportRequestCard({
    required this.request,
    required this.scale,
    required this.isPending,
    required this.onTap,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final status = request.status.toLowerCase();
    final isResolved = status == 'resolved';
    final customerName = request.customer ?? 'Khách hàng';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22 * scale,
                    backgroundColor: isResolved ? Colors.grey[300] : AppColors.primary,
                    child: Text(
                      customerName.isNotEmpty ? customerName[0].toUpperCase() : 'K',
                      style: TextStyle(
                        color: isResolved ? Colors.grey[700] : AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
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
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 14 * scale, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              _formatDateTime(request.createdAt),
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
                  if (onAction != null)
                    ElevatedButton(
                      onPressed: onAction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(isPending ? 'Nhận' : 'Hoàn thành'),
                    )
                  else if (isResolved)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: const Text(
                        'Đã xử lý',
                        style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lý do hỗ trợ:',
                      style: TextStyle(
                        fontSize: 12 * scale,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      request.reason,
                      style: TextStyle(fontSize: 14 * scale, color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes <= 0) return 'Vừa xong';
        return '${difference.inMinutes} phút trước';
      }
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays == 1) {
      return 'Hôm qua';
    }
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
