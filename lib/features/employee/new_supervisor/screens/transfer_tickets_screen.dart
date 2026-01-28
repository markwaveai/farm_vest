import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/core/widgets/custom_button.dart';
import 'package:farm_vest/features/employee/new_supervisor/providers/supervisor_dashboard_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TransferTicketsScreen extends ConsumerStatefulWidget {
  const TransferTicketsScreen({super.key});

  @override
  ConsumerState<TransferTicketsScreen> createState() =>
      _TransferTicketsScreenState();
}

class _TransferTicketsScreenState extends ConsumerState<TransferTicketsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<Map<String, dynamic>> _outTransfers = [];
  List<Map<String, dynamic>> _inTransfers = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTransfers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTransfers() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(supervisorRepositoryProvider);
      final response = await repo.getTransferTickets();
      final tickets = response['data'] as List<dynamic>? ?? [];

      setState(() {
        _outTransfers = tickets
            .where((t) => t['transfer_direction'] == 'OUT')
            .map((t) => Map<String, dynamic>.from(t))
            .toList();
        _inTransfers = tickets
            .where((t) => t['transfer_direction'] == 'IN')
            .map((t) => Map<String, dynamic>.from(t))
            .toList();
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/supervisor-dashboard'),
        ),
        title: const Text('Transfer Tickets'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.primary,
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.arrow_upward, size: 18),
                  const SizedBox(width: 4),
                  Text('OUT (${_outTransfers.length})'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.arrow_downward, size: 18),
                  const SizedBox(width: 4),
                  Text('IN (${_inTransfers.length})'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildTransferList(_outTransfers, isOut: true),
                _buildTransferList(_inTransfers, isOut: false),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateTransferDialog(context),
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'New Transfer',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildTransferList(
    List<Map<String, dynamic>> transfers, {
    required bool isOut,
  }) {
    if (transfers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isOut ? Icons.outbox_outlined : Icons.inbox_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              isOut
                  ? 'No outgoing transfer requests'
                  : 'No incoming transfer requests',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTransfers,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: transfers.length,
        itemBuilder: (context, index) {
          final transfer = transfers[index];
          return _buildTransferCard(transfer, isOut: isOut);
        },
      ),
    );
  }

  Widget _buildTransferCard(
    Map<String, dynamic> transfer, {
    required bool isOut,
  }) {
    final status = transfer['status'] as String? ?? 'PENDING';
    final animalTag = transfer['animal_tag'] ?? 'Unknown';
    final description = transfer['description'] ?? '';
    final createdAt = transfer['created_at'] ?? '';
    final sourceShed = transfer['source_shed_name'] ?? 'N/A';
    final destShed = transfer['destination_shed_name'] ?? 'N/A';

    Color statusColor;
    switch (status) {
      case 'APPROVED':
        statusColor = Colors.green;
        break;
      case 'REJECTED':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.orange;
    }

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
                      color: isOut ? Colors.red : Colors.green,
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
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
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
                if (status == 'APPROVED' && !isOut)
                  CustomActionButton(
                    height: 32,
                    color: AppTheme.primary,
                    onPressed: () {
                      // Navigate to allocation screen for this animal
                      context.go(
                        '/buffalo-allocation',
                        extra: {'animalId': transfer['animal_id']},
                      );
                    },
                    child: const Text(
                      'Allocate Slot',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
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

  void _showCreateTransferDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _CreateTransferSheet(),
    ).then((_) => _loadTransfers());
  }
}

class _CreateTransferSheet extends ConsumerStatefulWidget {
  const _CreateTransferSheet();

  @override
  ConsumerState<_CreateTransferSheet> createState() =>
      _CreateTransferSheetState();
}

class _CreateTransferSheetState extends ConsumerState<_CreateTransferSheet> {
  String _direction = 'OUT';
  final _animalController = TextEditingController();
  final _reasonController = TextEditingController();
  int? _selectedAnimalId;
  int? _selectedShedId;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadSheds();
  }

  Future<void> _loadSheds() async {
    // Placeholder for loading sheds if needed in the future
  }

  @override
  Widget build(BuildContext context) {
    final suggestions = ref
        .watch(supervisorDashboardProvider)
        .animalSuggestions;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Create Transfer Request',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Direction Toggle
            const Text(
              'Transfer Direction',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildDirectionButton(
                    'OUT',
                    'Send Out',
                    Icons.arrow_upward,
                    Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDirectionButton(
                    'IN',
                    'Receive',
                    Icons.arrow_downward,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Animal Search
            const Text(
              'Select Animal',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _animalController,
              decoration: InputDecoration(
                hintText: 'Search by RFID or Ear Tag',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: const Icon(Icons.search),
              ),
              onChanged: (val) {
                ref
                    .read(supervisorDashboardProvider.notifier)
                    .searchSuggestions(val);
                if (_selectedAnimalId != null) {
                  setState(() => _selectedAnimalId = null);
                }
              },
            ),
            if (suggestions.isNotEmpty && _selectedAnimalId == null)
              Container(
                margin: const EdgeInsets.only(top: 4),
                constraints: const BoxConstraints(maxHeight: 120),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: suggestions.length,
                  itemBuilder: (context, index) {
                    final animal = suggestions[index]['animal_details'];
                    final tag =
                        animal['rfid_tag_number'] ??
                        animal['ear_tag'] ??
                        animal['animal_id'];
                    return ListTile(
                      dense: true,
                      title: Text(tag),
                      subtitle: Text('Row: ${animal['row_number'] ?? 'N/A'}'),
                      onTap: () {
                        setState(() {
                          _selectedAnimalId = animal['id'];
                          _animalController.text = tag;
                        });
                        ref
                            .read(supervisorDashboardProvider.notifier)
                            .clearSuggestions();
                      },
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),

            // Reason
            const Text(
              'Reason for Transfer',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _reasonController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Enter reason...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitTransfer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Submit Transfer Request',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectionButton(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    final isSelected = _direction == value;
    return InkWell(
      onTap: () => setState(() => _direction = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? color : Colors.grey),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitTransfer() async {
    if (_selectedAnimalId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select an animal')));
      return;
    }
    if (_reasonController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a reason')));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final body = {
        'animal_id': _selectedAnimalId,
        'ticket_type': 'TRANSFER',
        'transfer_direction': _direction,
        'description': _reasonController.text,
        'destination_shed_id': _selectedShedId,
      };

      await ref.read(supervisorDashboardProvider.notifier).createTicket(body);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transfer request submitted for approval'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
