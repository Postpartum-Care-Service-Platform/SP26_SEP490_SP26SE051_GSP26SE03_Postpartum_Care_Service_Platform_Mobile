// lib/features/chat/presentation/screens/employee_support_request_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/routing/app_router.dart';
import '../../../../../core/routing/app_routes.dart';
import '../../../../../core/utils/app_responsive.dart';
import '../../../../../features/chat/presentation/bloc/chat_bloc.dart';
import '../../../../../features/chat/presentation/bloc/chat_event.dart';
import '../../../../../features/chat/presentation/bloc/chat_state.dart';
import '../../domain/entities/support_request.dart';

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
              SnackBar(
                content: const Text('Thao tác thành công'),
                backgroundColor: AppColors.primary,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
            context.read<ChatBloc>().add(const ChatLoadSupportRequestsRequested());
            context.read<ChatBloc>().add(const ChatLoadMySupportRequestsRequested());
          } else if (state.supportRequestActionStatus == ChatSupportRequestActionStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Thao tác thất bại. Vui lòng thử lại.'),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          }
        },
        child: BlocBuilder<ChatBloc, ChatState>(
          builder: (context, state) {
            final scale = AppResponsive.scaleFactor(context);

            return DefaultTabController(
              length: 2,
              child: Scaffold(
                backgroundColor: const Color(0xFFF8FAFC),
                appBar: AppBar(
                  elevation: 0,
                  backgroundColor: Colors.white,
                  centerTitle: true,
                  leading: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, size: 16, color: Colors.black),
                    ),
                    onPressed: widget.onBackToDefaultStaffPage ?? () => Navigator.of(context).pop(),
                  ),
                  title: Text(
                    'Hỗ Trợ Khách Hàng',
                    style: TextStyle(
                      fontSize: 18 * scale,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(50),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TabBar(
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        indicator: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        labelColor: Colors.white,
                        unselectedLabelColor: const Color(0xFF64748B),
                        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        tabs: [
                          Tab(text: 'Đang chờ (${state.supportRequests.length})'),
                          Tab(text: 'Của tôi (${state.mySupportRequests.length})'),
                        ],
                      ),
                    ),
                  ),
                ),
                body: TabBarView(
                  children: [
                    _buildPendingSupportRequestsView(context, state, scale),
                    _buildMySupportRequestsView(context, state, scale),
                  ],
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
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (state.supportRequests.isEmpty) {
      return _buildEmptyState(
        icon: Icons.chat_bubble_outline_rounded,
        message: 'Hiện không có yêu cầu nào',
        scale: scale,
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        context.read<ChatBloc>().add(const ChatLoadSupportRequestsRequested());
      },
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
        physics: const BouncingScrollPhysics(),
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
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (state.mySupportRequests.isEmpty) {
      return _buildEmptyState(
        icon: Icons.assignment_turned_in_outlined,
        message: 'Bạn chưa nhận yêu cầu nào',
        scale: scale,
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        context.read<ChatBloc>().add(const ChatLoadMySupportRequestsRequested());
      },
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
        physics: const BouncingScrollPhysics(),
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
          Container(
            padding: EdgeInsets.all(24 * scale),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(icon, size: 48 * scale, color: const Color(0xFFCBD5E1)),
          ),
          SizedBox(height: 24 * scale),
          Text(
            message,
            style: TextStyle(
              fontSize: 16 * scale,
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w600,
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
    final customer = request.customer;
    final customerName = customer?.fullName ?? customer?.username ?? 'Khách hàng';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64748B).withValues(alpha: 0.06),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        final parentState = context.findAncestorStateOfType<_EmployeeSupportRequestScreenState>();
                        parentState?._showCustomerDetail(context, customer);
                      },
                      child: Container(
                        width: 48 * scale,
                        height: 48 * scale,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary.withValues(alpha: 0.1),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.1), width: 2),
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
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15 * scale,
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.verified_rounded, size: 14 * scale, color: Colors.blue),
                            ],
                          ),
                          Text(
                            customer?.phone ?? 'Chưa cập nhật SĐT',
                            style: TextStyle(
                              fontSize: 12 * scale,
                              color: const Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusChip(status, scale),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline_rounded, size: 12 * scale, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text(
                            'LÝ DO HỖ TRỢ',
                            style: TextStyle(
                              fontSize: 10 * scale,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        request.reason.isNotEmpty ? request.reason : 'Không có mô tả chi tiết',
                        style: TextStyle(
                          fontSize: 13 * scale,
                          color: const Color(0xFF334155),
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.schedule_rounded, size: 14 * scale, color: const Color(0xFF94A3B8)),
                    const SizedBox(width: 4),
                    Text(
                      _formatDateTime(request.createdAt),
                      style: TextStyle(
                        fontSize: 12 * scale,
                        color: const Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    if (onAction != null)
                      SizedBox(
                        height: 36 * scale,
                        child: ElevatedButton(
                          onPressed: onAction,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isPending ? AppColors.primary : const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            isPending ? 'Tiếp nhận' : 'Hoàn thành',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status, double scale) {
    Color color;
    String text;
    
    switch (status) {
      case 'pending':
        color = const Color(0xFFF59E0B);
        text = 'Chờ';
        break;
      case 'assigned':
        color = const Color(0xFF3B82F6);
        text = 'Đang hỗ trợ';
        break;
      case 'resolved':
        color = const Color(0xFF10B981);
        text = 'Xong';
        break;
      default:
        color = const Color(0xFF64748B);
        text = status.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10 * scale,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }

  Widget _buildInitialAvatar(String name, double scale) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'K',
        style: TextStyle(
          fontSize: 18 * scale,
          fontWeight: FontWeight.w800,
          color: AppColors.primary,
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) return 'Vừa xong';
    if (difference.inMinutes < 60) return '${difference.inMinutes} phút trước';
    if (difference.inHours < 24) return '${difference.inHours} giờ trước';
    
    return DateFormat('dd/MM/yyyy').format(dateTime);
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
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 32),
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              else ...[
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.1),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.05), width: 4),
                  ),
                  child: ClipOval(
                    child: profile.avatarUrl != null
                        ? Image.network(profile.avatarUrl!, fit: BoxFit.cover)
                        : Center(
                            child: Text(
                              profile.displayName[0].toUpperCase(),
                              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.primary),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  profile.displayName,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    profile.roleName,
                    style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(height: 32),
                _buildInfoCard([
                  _InfoItem(Icons.email_rounded, 'Email', profile.email),
                  _InfoItem(Icons.phone_rounded, 'Số điện thoại', profile.phone),
                  if (profile.memberType != null)
                    _InfoItem(Icons.stars_rounded, 'Hạng thành viên', profile.memberType!),
                ]),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(List<_InfoItem> items) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          return Padding(
            padding: EdgeInsets.only(bottom: index == items.length - 1 ? 0 : 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.icon, size: 20, color: AppColors.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.label, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(item.value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _InfoItem {
  final IconData icon;
  final String label;
  final String value;
  _InfoItem(this.icon, this.label, this.value);
}
