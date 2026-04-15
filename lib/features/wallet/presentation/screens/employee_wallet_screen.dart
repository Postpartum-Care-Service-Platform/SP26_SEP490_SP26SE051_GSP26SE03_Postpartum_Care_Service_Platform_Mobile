import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../bloc/wallet_cubit.dart';
import '../bloc/wallet_state.dart';

class EmployeeWalletScreen extends StatefulWidget {
  const EmployeeWalletScreen({super.key});

  @override
  State<EmployeeWalletScreen> createState() => _EmployeeWalletScreenState();
}

class _EmployeeWalletScreenState extends State<EmployeeWalletScreen> {
  @override
  void initState() {
    super.initState();
    context.read<WalletCubit>().loadWallet();
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: BlocConsumer<WalletCubit, WalletState>(
        listener: (context, state) {
          if (state is WalletError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          }
        },
        builder: (context, state) {
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildHeader(context, scale),
              if (state is WalletLoading || state is WalletInitial)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                )
              else if (state is WalletLoaded) ...[
                SliverToBoxAdapter(
                  child: _buildBalanceCard(scale, state.wallet.balance.toDouble()),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20 * scale, 12 * scale, 20 * scale, 16 * scale),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Lịch sử giao dịch',
                          style: AppTextStyles.arimo(
                            fontSize: 18 * scale,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'Tháng này',
                            style: AppTextStyles.arimo(
                              fontSize: 14 * scale,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (state.transactions.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 64 * scale, color: Colors.grey[300]),
                        SizedBox(height: 16 * scale),
                        Text(
                          'Chưa có giao dịch nào',
                          style: AppTextStyles.arimo(
                            fontSize: 15 * scale,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 20 * scale),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final tx = state.transactions[index];
                          return _buildTransactionItem(scale, tx);
                        },
                        childCount: state.transactions.length,
                      ),
                    ),
                  ),
                SliverToBoxAdapter(child: SizedBox(height: 40 * scale)),
              ] else if (state is WalletError)
                SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                          const SizedBox(height: 16),
                          Text(state.message, textAlign: TextAlign.center),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () => context.read<WalletCubit>().loadWallet(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double scale) {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      pinned: true,
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
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        'Ví Của Tôi',
        style: AppTextStyles.arimo(
          fontSize: 18 * scale,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF1E293B),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.refresh_rounded, color: Colors.grey[600]),
          onPressed: () => context.read<WalletCubit>().loadWallet(),
        ),
      ],
    );
  }

  Widget _buildBalanceCard(double scale, double balance) {
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return Container(
      margin: EdgeInsets.all(20 * scale),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32 * scale),
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 24 * scale,
            offset: Offset(0, 12 * scale),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32 * scale),
        child: Stack(
          children: [
            Positioned(
              right: -40 * scale,
              top: -40 * scale,
              child: Container(
                width: 160 * scale,
                height: 160 * scale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(32 * scale),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8 * scale),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12 * scale),
                        ),
                        child: Icon(Icons.account_balance_wallet, color: Colors.white, size: 20 * scale),
                      ),
                      SizedBox(width: 12 * scale),
                      Text(
                        'Tổng số dư',
                        style: AppTextStyles.arimo(
                          fontSize: 14 * scale,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24 * scale),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      currencyFormatter.format(balance),
                      style: AppTextStyles.arimo(
                        fontSize: 40 * scale,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(double scale, dynamic tx) {
    final isReceived = (tx.amount ?? 0) >= 0;
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return Container(
      margin: EdgeInsets.only(bottom: 12 * scale),
      padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 14 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20 * scale),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64748B).withValues(alpha: 0.05),
            blurRadius: 10 * scale,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10 * scale),
            decoration: BoxDecoration(
              color: isReceived 
                ? AppColors.primary.withValues(alpha: 0.1)
                : const Color(0xFFFEE2E2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isReceived ? Icons.call_received_rounded : Icons.call_made_rounded,
              color: isReceived ? AppColors.primary : const Color(0xFFB91C1C),
              size: 20 * scale,
            ),
          ),
          SizedBox(width: 14 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.packageName ?? tx.description ?? tx.type ?? 'Giao dịch',
                  style: AppTextStyles.arimo(
                    fontSize: 15 * scale,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (tx.packageName != null && tx.description != null) ...[
                  SizedBox(height: 2 * scale),
                  Text(
                    tx.description!,
                    style: AppTextStyles.arimo(
                      fontSize: 12 * scale,
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                SizedBox(height: 4 * scale),
                Text(
                  tx.createdAt != null 
                    ? DateFormat('dd/MM/yyyy • HH:mm').format(tx.createdAt!)
                    : 'Gần đây',
                  style: AppTextStyles.arimo(
                    fontSize: 11 * scale,
                    color: const Color(0xFF94A3B8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isReceived ? '+' : ''}${currencyFormatter.format(tx.amount)}',
                style: AppTextStyles.arimo(
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.w800,
                  color: isReceived ? const Color(0xFF15803D) : const Color(0xFF0F172A),
                ),
              ),
              if (tx.status != null) ...[
                SizedBox(height: 2 * scale),
                Text(
                  tx.status!,
                  style: AppTextStyles.arimo(
                    fontSize: 10 * scale,
                    fontWeight: FontWeight.w700,
                    color: tx.status == 'Success' || tx.status == 'Completed' 
                        ? AppColors.primary
                        : const Color(0xFF64748B),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
