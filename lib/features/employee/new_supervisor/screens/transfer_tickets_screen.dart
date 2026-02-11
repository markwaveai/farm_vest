import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/core/widgets/custom_button.dart';
import 'package:farm_vest/features/employee/new_supervisor/providers/supervisor_dashboard_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm_vest/features/investor/data/models/investor_animal_model.dart';
import 'package:farm_vest/features/admin/data/models/ticket_model.dart';
import 'package:farm_vest/core/utils/app_enums.dart';
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
  List<Ticket> _outTransfers = [];
  List<Ticket> _inTransfers = [];

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
      final tickets = response['data'] as List<Ticket>? ?? [];

      setState(() {
        _outTransfers = tickets.where((t) {
          final metadata = t.metadata;
          return metadata?['transfer_direction'] == 'OUT';
        }).toList();
        _inTransfers = tickets.where((t) {
          final metadata = t.metadata;
          return metadata?['transfer_direction'] == 'IN';
        }).toList();
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => context.go('/doctor-dashboard'),
        ),
        title: Text(
          'Transfer Tickets',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primary,
          unselectedLabelColor: Theme.of(context).hintColor,
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

  Widget _buildTransferList(List<Ticket> transfers, {required bool isOut}) {
    if (transfers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isOut ? Icons.outbox_outlined : Icons.inbox_outlined,
              size: 64,
              color: Theme.of(context).hintColor,
            ),
            const SizedBox(height: 16),
            Text(
              isOut
                  ? 'No outgoing transfer requests'
                  : 'No incoming transfer requests',
              style: TextStyle(
                color: Theme.of(context).hintColor,
                fontSize: 16,
              ),
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

  Widget _buildTransferCard(Ticket transfer, {required bool isOut}) {
    final status = transfer.status;
    final metadata = transfer.metadata ?? {};
    final animalTag = transfer.rfid ?? metadata['animal_tag'] ?? 'Unknown';
    final description = transfer.description;
    final createdAt = transfer.createdAt?.toIso8601String() ?? '';
    final sourceShed = metadata['source_shed_name'] ?? 'N/A';
    final destShed = metadata['destination_shed_name'] ?? 'N/A';
    final animalId = transfer.animalId;

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
      color: Theme.of(context).cardColor,
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
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurface,
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
                          color: Theme.of(context).hintColor,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        sourceShed,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
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
                          color: Theme.of(context).hintColor,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        destShed,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
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
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.8),
                ),
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
                  style: TextStyle(
                    color: Theme.of(context).hintColor,
                    fontSize: 12,
                  ),
                ),
                if (status == 'APPROVED' && !isOut)
                  CustomActionButton(
                    height: 32,
                    color: AppTheme.primary,
                    onPressed: () {
                      // Navigate to allocation screen for this animal
                      context.go(
                        '/buffalo-allocation',
                        extra: {'animalId': animalId},
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
      backgroundColor: Theme.of(context).cardColor,
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
  String? _selectedAnimalId;
  InvestorAnimal? _selectedAnimal;
  int? _selectedShedId;

  final _outController = TextEditingController();
  final _focusNode = FocusNode();
  final _reasonFocusNode = FocusNode();
  String _priority = TicketPriority.medium.value;

  bool _isSubmitting = false;

  List<Map<String, dynamic>> _sheds = [];
  bool _isShedsLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSheds();
  }

  @override
  void dispose() {
    _animalController.dispose();
    _reasonController.dispose();
    _outController.dispose();
    _focusNode.dispose();
    _reasonFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadSheds({int? farmId}) async {
    setState(() => _isShedsLoading = true);
    try {
      final repo = ref.read(supervisorRepositoryProvider);
      final data = await repo.getSheds(farmId: farmId);
      setState(() {
        _sheds = data;
        _isShedsLoading = false;
      });
    } catch (e) {
      setState(() => _isShedsLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final suggestions = ref
        .watch(supervisorDashboardProvider)
        .animalSuggestions;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Create Transfer Request',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white12
                          : Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      size: 20,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Direction Toggle
            _buildSectionLabel('Transfer Direction'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildDirectionButton(
                    'OUT',
                    'Send Out',
                    Icons.arrow_upward_rounded,
                    const Color(0xFFF44336),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDirectionButton(
                    'IN',
                    'Receive',
                    Icons.arrow_downward_rounded,
                    const Color(0xFF4CAF50),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Animal Selection
            _buildSectionLabel('Select Animal'),
            const SizedBox(height: 12),
            TextField(
              controller: _animalController,
              focusNode: _focusNode,
              onChanged: (val) {
                ref
                    .read(supervisorDashboardProvider.notifier)
                    .searchSuggestions(val);
                if (_selectedAnimalId != null) {
                  setState(() {
                    _selectedAnimalId = null;
                    _selectedAnimal = null;
                    _outController.clear();
                  });
                }
              },

              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: 'Search by RFID or Ear Tag',
                hintStyle: TextStyle(color: Theme.of(context).hintColor),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: Theme.of(context).hintColor,
                ),
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.05)
                    : const Color(0xFFF8F9FA),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white12
                        : Colors.grey.shade200,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppTheme.primary,
                    width: 2,
                  ),
                ),
              ),
            ),

            // Suggestions List
            if (suggestions.isNotEmpty && _selectedAnimalId == null)
              Container(
                margin: const EdgeInsets.only(top: 8),
                constraints: const BoxConstraints(maxHeight: 200),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white12
                        : Colors.grey.shade200,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: suggestions.length,
                  itemBuilder: (context, index) {
                    final animal = suggestions[index];
                    final tag =
                        animal.rfid ?? animal.earTagId ?? animal.animalId;
                    return ListTile(
                      dense: true,
                      leading: const CircleAvatar(
                        radius: 14,
                        backgroundColor: Color(0xFFE8F5E9),
                        child: Icon(
                          Icons.pets,
                          size: 14,
                          color: AppTheme.primary,
                        ),
                      ),
                      title: Text(
                        tag,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      subtitle: Text(
                        'Shed: ${animal.shedName ?? 'N/A'}',
                        style: TextStyle(color: Theme.of(context).hintColor),
                      ),
                      onTap: () {
                        setState(() {
                          _selectedAnimalId = animal.animalId;
                          _selectedAnimal = animal;
                          _animalController.text = tag;
                          _outController.text =
                              animal.shedName ?? 'Unknown Shed';
                          if (_selectedShedId == animal.shedId)
                            _selectedShedId = null;
                        });
                        if (animal.farmId != null) {
                          _loadSheds(farmId: animal.farmId);
                        }
                        ref
                            .read(supervisorDashboardProvider.notifier)
                            .clearSuggestions();
                        FocusScope.of(context).unfocus();
                      },
                    );
                  },
                ),
              ),
            const SizedBox(height: 24),

            // Current Location (Source)
            _buildSectionLabel('Current Location'),
            const SizedBox(height: 12),
            TextField(
              controller: _outController,
              readOnly: true,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: 'Select an animal first',
                hintStyle: TextStyle(color: Theme.of(context).hintColor),
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.05)
                    : const Color(0xFFF8F9FA),
                prefixIcon: Icon(
                  Icons.location_on_rounded,
                  color: Theme.of(context).hintColor,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white12
                        : Colors.grey.shade200,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white12
                        : Colors.grey.shade200,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Destination
            _buildSectionLabel('Destination Shed (Optional)'),
            const SizedBox(height: 12),
            _isShedsLoading
                ? const Center(child: LinearProgressIndicator())
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withOpacity(0.05)
                          : const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white12
                            : Colors.grey.shade200,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        isExpanded: true,
                        value: _selectedShedId,
                        dropdownColor: Theme.of(context).cardColor,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        hint: Text(
                          'Select target shed',
                          style: TextStyle(color: Theme.of(context).hintColor),
                        ),
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                        borderRadius: BorderRadius.circular(12),
                        items: _sheds
                            .where(
                              (shed) => shed['id'] != _selectedAnimal?.shedId,
                            )
                            .map((shed) {
                              return DropdownMenuItem<int>(
                                value: shed['id'] as int,
                                child: Text(
                                  shed['shed_name'] ?? 'Shed ${shed['id']}',
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                                ),
                              );
                            })
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _selectedShedId = val),
                      ),
                    ),
                  ),
            const SizedBox(height: 24),
            _buildSectionLabel('Priority'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.05)
                    : const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white12
                      : Colors.grey.shade200,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _priority,
                  dropdownColor: Theme.of(context).cardColor,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  items: TicketPriority.values.map((p) {
                    return DropdownMenuItem<String>(
                      value: p.value,
                      child: Text(
                        p.label,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    );
                  }).toList(),

                  onChanged: (val) => setState(() => _priority = val!),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Reason
            _buildSectionLabel('Reason for Transfer'),
            const SizedBox(height: 12),
            TextField(
              controller: _reasonController,
              focusNode: _reasonFocusNode,
              maxLines: 3,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Describe why this animal is being moved...',
                hintStyle: TextStyle(color: Theme.of(context).hintColor),
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.05)
                    : const Color(0xFFF8F9FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white12
                        : Colors.grey.shade200,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppTheme.primary,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed:
                    (_isSubmitting ||
                        _selectedAnimalId == null ||
                        _reasonController.text.trim().isEmpty)
                    ? null
                    : _submitTransfer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        'Confirm Transfer',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).hintColor,
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
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.08)
              : (Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.05)
                    : const Color(0xFFF8F9FA)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? color
                : (Theme.of(context).brightness == Brightness.dark
                      ? Colors.white12
                      : Colors.grey.shade200),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? color : Theme.of(context).hintColor,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Theme.of(context).hintColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitTransfer() async {
    if (_selectedAnimalId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an animal'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (_reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a reason'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final body = {
        'animal_id': _selectedAnimalId,
        'transfer_direction': _direction,
        'description': _reasonController.text.trim(),
        'destination_shed_id': _selectedShedId,
        'source_shed_id': _selectedAnimal?.shedId,
        'priority': _priority,
      };

      final response = await ref
          .read(supervisorDashboardProvider.notifier)
          .createTransferTicket(body);

      if (mounted) {
        if (response != null && response['status'] == 'success') {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Transfer request submitted successfully'),
              backgroundColor: Color(0xFF4CAF50),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          throw Exception('Failed to create request');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
