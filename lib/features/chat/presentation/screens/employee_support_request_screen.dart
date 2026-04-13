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
import '../../domain/entities/support_request.dart';
import '../../../auth/data/models/current_account_model.dart';

class EmployeeSupportRequestScreen extends StatefulWidget {
  final VoidCallback? onBackToDefaultStaffPage;

  const EmployeeSupportRequestScreen({
    super.key,
    this.onBackToDefaultStaffPage,
  });

  @override
  State<EmployeeSupportRequestScreen> createState() => _EmployeeSupportRequestScreenState();
}

class _EmployeeSupportRequestScreenState extends State<EmployeeSupportRequestScreen> {
  late final ChatBloc _chatBloc;

  @override
  void initState() {
    super.initState();
    _chatBloc = InjectionContainer.chatBloc;
    // Load data when entering the screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chatBloc.add(const ChatLoadSupportRequestsRequested());
      _chatBloc.add(const ChatLoadMySupportRequestsRequested());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _chatBloc,
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
                  leading: IconButton(
                    onPressed: widget.onBackToDefaultStaffPage ??
                        () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
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
    AppRouter.push(
      context,
      AppRoutes.employeeChat,
      arguments: {'conversationId': conversationId},
    );
  }

  void _showCustomerDetail(BuildContext context, SupportRequestCustomer? customer) {
    if (customer == null) return;

    final chatBloc = context.read<ChatBloc>();
    // Fetch full profile via API as requested
    chatBloc.add(ChatAccountDetailRequested(customer.id));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider.value(
        value: chatBloc,
        child: _CustomerDetailSheet(customerId: customer.id),
      ),
    );
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
    final customer = request.customer;
    final customerName = customer?.fullName ?? customer?.username ?? 'Khách hàng';

    return Card(
      margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.borderLight.withValues(alpha: 0.5)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  // Hiển thị thông tin chi tiết khách hàng và gọi API Account/GetById
                  final parentState = context.findAncestorStateOfType<_EmployeeSupportRequestScreenState>();
                  parentState?._showCustomerDetail(context, customer);
                },
                child: Row(
                  children: [
                    Container(
                      width: 52 * scale,
                      height: 52 * scale,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withValues(alpha: 0.1),
                      ),
                      child: ClipOval(
                        child: customer?.avatarUrl != null
                            ? Image.network(
                                customer!.avatarUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _buildInitialAvatar(customerName, scale),
                              )
                            : _buildInitialAvatar(customerName, scale),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                customerName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16 * scale,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.info_outline, size: 14 * scale, color: AppColors.primary),
                            ],
                          ),
                          if (customer?.email != null)
                            Text(
                              customer!.email,
                              style: TextStyle(
                                fontSize: 12 * scale,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          if (customer?.phone != null)
                            Text(
                              customer!.phone!,
                              style: TextStyle(
                                fontSize: 12 * scale,
                                color: AppColors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (onAction != null)
                      ElevatedButton(
                        onPressed: onAction,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isPending ? AppColors.primary : Colors.green[600],
                          foregroundColor: AppColors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          visualDensity: VisualDensity.compact,
                        ),
                        child: Text(isPending ? 'Nhận' : 'Hoàn thành'),
                      ),
                  ],
                ),
              ),
              const Divider(height: 24, color: AppColors.borderLight),
              Row(
                children: [
                  Icon(Icons.access_time_rounded, size: 14 * scale, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    _formatDateTime(request.createdAt),
                    style: TextStyle(
                      fontSize: 12 * scale,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _getStatusText(status),
                      style: TextStyle(
                        fontSize: 10 * scale,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(status),
                      ),
                    ),
                  ),
                ],
              ),
              if (request.reason.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lý do hỗ trợ:',
                        style: TextStyle(
                          fontSize: 11 * scale,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        request.reason,
                        style: TextStyle(
                          fontSize: 13 * scale,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInitialAvatar(String name, double scale) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'K',
        style: TextStyle(
          fontSize: 20 * scale,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'CHỜ XỬ LÝ';
      case 'assigned':
        return 'ĐANG XỬ LÝ';
      case 'resolved':
        return 'ĐÃ HOÀN THÀNH';
      default:
        return status.toUpperCase();
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'assigned':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) return 'Vừa xong';
    if (difference.inMinutes < 60) return '${difference.inMinutes} phút trước';
    if (difference.inHours < 24) return '${difference.inHours} giờ trước';
    if (difference.inDays < 7) return '${difference.inDays} ngày trước';

    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}

class _CustomerDetailSheet extends StatelessWidget {
  final String customerId;

  const _CustomerDetailSheet({required this.customerId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        final profile = state.customerProfiles[customerId];
        final isLoading = profile == null;

        return Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else ...[
                CircleAvatar(
                  radius: 40,
                  backgroundImage: profile.avatarUrl != null ? NetworkImage(profile.avatarUrl!) : null,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: profile.avatarUrl == null
                      ? Text(
                          profile.displayName[0].toUpperCase(),
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary),
                        )
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  profile.displayName,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                Text(
                  profile.roleName,
                  style: TextStyle(fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 24),
                _buildInfoRow(Icons.email_outlined, 'Email', profile.email),
                _buildInfoRow(Icons.phone_outlined, 'Số điện thoại', profile.phone),
                if (profile.memberType != null)
                  _buildInfoRow(Icons.card_membership, 'Loại thành viên', profile.memberType!),
                const SizedBox(height: 24),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
            ],
          ),
        ],
      ),
    );
  }
}
