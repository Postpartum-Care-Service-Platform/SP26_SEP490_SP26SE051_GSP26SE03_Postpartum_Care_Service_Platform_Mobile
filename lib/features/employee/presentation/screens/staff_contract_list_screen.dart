import 'package:flutter/material.dart';

import '../../../../core/apis/api_client.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../../contract/data/datasources/contract_remote_datasource.dart';
import '../../../contract/data/models/contract_model.dart';
import 'staff_contract_screen.dart';

/// Danh sách hợp đồng cho staff (tất cả + chưa lên lịch)
class StaffContractListScreen extends StatefulWidget {
  const StaffContractListScreen({super.key});

  @override
  State<StaffContractListScreen> createState() =>
      _StaffContractListScreenState();
}

class _StaffContractListScreenState extends State<StaffContractListScreen> {
  final _remote = ContractRemoteDataSourceImpl(dio: ApiClient.dio);
  String _filter = 'all'; // all, no_schedule
  late Future<List<ContractModel>> _future = _load();

  Future<List<ContractModel>> _load() async {
    if (_filter == 'no_schedule') {
      final list = await _remote.getNoScheduleContracts();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    } else {
      final list = await _remote.getAllContracts();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppAppBar(
        title: 'Danh sách hợp đồng',
        centerTitle: true,
        titleFontSize: 20 * scale,
        titleFontWeight: FontWeight.w700,
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(scale),
          Expanded(
            child: FutureBuilder<List<ContractModel>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(24 * scale),
                      child: Text(
                        'Lỗi tải danh sách hợp đồng: ${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.arimo(
                          fontSize: 14 * scale,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }

                final items = snapshot.data ?? const [];
                if (items.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(24 * scale),
                      child: Text(
                        'Không có hợp đồng nào.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.arimo(
                          fontSize: 14 * scale,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.separated(
                    padding: EdgeInsets.all(16 * scale),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => SizedBox(height: 10 * scale),
                    itemBuilder: (context, index) {
                      final c = items[index];
                      return _ContractItem(
                        contract: c,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => StaffContractScreen.fromContract(c),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(double scale) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16 * scale, 8 * scale, 16 * scale, 4 * scale),
      child: Row(
        children: [
          Text(
            'Loại:',
            style: AppTextStyles.arimo(
              fontSize: 13 * scale,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          DropdownButton<String>(
            value: _filter,
            items: const [
              DropdownMenuItem(value: 'all', child: Text('Tất cả')),
              DropdownMenuItem(
                value: 'no_schedule',
                child: Text('Chưa lên lịch'),
              ),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _filter = value;
                _future = _load();
              });
            },
          ),
        ],
      ),
    );
  }
}

class _ContractItem extends StatelessWidget {
  final ContractModel contract;
  final VoidCallback? onTap;

  const _ContractItem({
    required this.contract,
    this.onTap,
  });

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return AppColors.textSecondary;
      case 'signed':
        return AppColors.verified;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    final statusColor = _statusColor(contract.status);
    final customerName =
        contract.customer?.username ?? contract.customer?.email ?? 'Khách hàng';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16 * scale),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16 * scale),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10 * scale,
              offset: Offset(0, 4 * scale),
            ),
          ],
        ),
        padding: EdgeInsets.all(14 * scale),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10 * scale,
                    vertical: 6 * scale,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    contract.status,
                    style: AppTextStyles.arimo(
                      fontSize: 11 * scale,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
                Text(
                  contract.contractCode,
                  style: AppTextStyles.arimo(
                    fontSize: 12 * scale,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10 * scale),
            Text(
              customerName,
              style: AppTextStyles.arimo(
                fontSize: 15 * scale,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 4 * scale),
            Text(
              'Booking #${contract.bookingId}',
              style: AppTextStyles.arimo(
                fontSize: 13 * scale,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 8 * scale),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 14 * scale,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: 6 * scale),
                Text(
                  '${contract.contractDate.day}/${contract.contractDate.month}/${contract.contractDate.year}',
                  style: AppTextStyles.arimo(
                    fontSize: 12 * scale,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

