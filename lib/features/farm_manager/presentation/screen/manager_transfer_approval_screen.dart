import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/core/widgets/custom_button.dart';
import 'package:farm_vest/features/farm_manager/presentation/providers/farm_manager_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ManagerTransferApprovalScreen extends ConsumerStatefulWidget {
  const ManagerTransferApprovalScreen({super.key});

  @override
  ConsumerState<ManagerTransferApprovalScreen> createState() =>
      _ManagerTransferApprovalScreenState();
}

class _ManagerTransferApprovalScreenState
    extends ConsumerState<ManagerTransferApprovalScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _pendingTransfers = [];

  @override
  void initState() {
    super.initState();
    _loadTransfers();
  }

  Future<void> _loadTransfers() async {
    setState(() => _isLoading = true);
    try {
      final notifier = ref.read(farmManagerProvider.notifier);
      final transfers = await notifier.getPendingTransfers();
      setState(() {
        _pendingTransfers = transfers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading transfers: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transfer Approvals')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pendingTransfers.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _loadTransfers,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _pendingTransfers.length,
                itemBuilder: (context, index) {
                  final transfer = _pendingTransfers[index];
                  return _buildTransferCard(transfer);
                },
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No pending approvals',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildTransferCard(Map<String, dynamic> transfer) {
    final animalTag = transfer['animal_tag'] ?? 'Unknown';
    final description = transfer['description'] ?? '';
    final createdAt = transfer['created_at'] ?? '';
    final sourceShed = transfer['source_shed_name'] ?? 'N/A';
    final destShed = transfer['destination_shed_name'] ?? 'N/A';
    final direction = transfer['transfer_direction'] ?? 'OUT';
    final isOut = direction == 'OUT';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isOut ? Icons.arrow_upward : Icons.arrow_downward,
                      color: isOut ? Colors.orange : Colors.blue,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      animalTag,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: const Text(
                    'PENDING',
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'From',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        sourceShed,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward, color: AppTheme.primary),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'To',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        destShed,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                description,
                style: TextStyle(color: Colors.grey.shade700),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(createdAt),
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomActionButton(
                      height: 32,
                      width: 80,
                      color: Colors.red,
                      variant: ButtonVariant.outlined,
                      textColor: Colors.red,
                      onPressed: () => _rejectTransfer(transfer['id']),
                      child: const Text(
                        'Reject',
                        style: TextStyle(fontSize: 12, color: Colors.red),
                      ),
                    ),
                    const SizedBox(width: 8),
                    CustomActionButton(
                      height: 32,
                      width: 80,
                      color: Colors.green,
                      onPressed: () => _approveTransfer(transfer['id']),
                      child: const Text(
                        'Approve',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String isoDate) {
    if (isoDate.isEmpty) return '';
    try {
      final date = DateTime.parse(isoDate);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return isoDate;
    }
  }

  Future<void> _approveTransfer(int id) async {
    setState(() => _isLoading = true);
    try {
      await ref.read(farmManagerProvider.notifier).approveTransfer(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transfer approved'),
            backgroundColor: Colors.green,
          ),
        );
      }
      _loadTransfers();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _rejectTransfer(int id) async {
    // Show confirmation/reason dialog if needed
    setState(() => _isLoading = true);
    try {
      await ref.read(farmManagerProvider.notifier).rejectTransfer(id);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Transfer rejected')));
      }
      _loadTransfers();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
      setState(() => _isLoading = false);
    }
  }
}
