import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/core/widgets/custom_button.dart';
import 'package:farm_vest/core/widgets/custom_textfield.dart';
import 'package:farm_vest/features/farm_manager/presentation/providers/farm_manager_provider.dart';
import 'package:farm_vest/features/farm_manager/presentation/providers/paid_orders_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:farm_vest/core/services/api_services.dart';
import '../../../farm_manager/data/models/animal_onboarding_entry.dart';
import '../../../farm_manager/presentation/widgets/onboarding/animal_entry_form.dart';
import '../../../farm_manager/presentation/widgets/onboarding/collapsible_section_title.dart';
import '../../../farm_manager/presentation/widgets/onboarding/info_card.dart';
import '../../../farm_manager/presentation/widgets/onboarding/order_card.dart';

class AdminOnboardAnimalScreen extends ConsumerStatefulWidget {
  const AdminOnboardAnimalScreen({super.key});

  @override
  ConsumerState<AdminOnboardAnimalScreen> createState() =>
      _AdminOnboardAnimalScreenState();
}

class _AdminOnboardAnimalScreenState
    extends ConsumerState<AdminOnboardAnimalScreen> {
  final TextEditingController searchController = TextEditingController();

  List<AnimalOnboardingEntry> buffaloEntries = [];
  List<AnimalOnboardingEntry> calfEntries = [];

  bool _isBuffaloExpanded = true;
  bool _isCalfExpanded = true;
  bool _isSubmitting = false;
  int? selectedFarmId; // For Admin to select farm during onboarding
  late Future<List<Map<String, dynamic>>> _farmsFuture;

  @override
  void initState() {
    super.initState();
    _initializeEmptyEntries();
    _farmsFuture = _fetchFarms();
  }

  void _initializeEmptyEntries() {
    final dashboardState = ref.read(farmManagerProvider);
    final order = dashboardState.currentOrder;

    if (order != null) {
      buffaloEntries = List.generate(order.order.buffaloCount, (index) {
        final buffaloId = index < order.order.buffaloIds.length
            ? order.order.buffaloIds[index]
            : '';
        return AnimalOnboardingEntry(
          animalId: buffaloId,
          rfidTag: '',
          earTag: '',
          dob: '',
          ageMonths: 0,
          healthStatus: 'Healthy',
          status: 'high_yield',
          type: 'BUFFALO',
          breedName: 'Murrah Buffalo',
          breedId: 'MURRAH-001',
          images: [],
        );
      });

      calfEntries = List.generate(order.order.calfCount, (index) {
        final calfId = index < order.order.calfIds.length
            ? order.order.calfIds[index]
            : '';
        return AnimalOnboardingEntry(
          animalId: calfId,
          rfidTag: '',
          earTag: '',
          dob: '',
          ageMonths: 0,
          healthStatus: 'Healthy',
          type: 'CALF',
          parentAnimalId: '',
          images: [],
        );
      });
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _showPaidOrdersDialog() {
    final mobile = searchController.text.trim();
    if (mobile.isEmpty) {
      _showError('Please enter a mobile number');
      return;
    }
    showDialog(
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final ordersAsync = ref.watch(
            paidOrdersProvider(PaidOrdersParams(mobile: mobile)),
          );
          return Dialog(
            insetPadding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(24),
              child: ordersAsync.when(
                data: (data) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Paid Orders for $mobile',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: data.orders.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = data.orders[index];
                          return OrderCard(
                            item: item,
                            onTap: () {
                              ref
                                  .read(farmManagerProvider.notifier)
                                  .setOrder(item);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error: $err')),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _submit() async {
    final dashboardState = ref.read(farmManagerProvider);
    final order = dashboardState.currentOrder;
    if (order == null || _isSubmitting) return;

    // Validate farm selection for Admin
    if (selectedFarmId == null) {
      _showError('Please select a farm before onboarding animals');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final success = await ref
          .read(farmManagerProvider.notifier)
          .onboardAnimalsBulk(
            order: order,
            animals: [...buffaloEntries, ...calfEntries],
            farmId: selectedFarmId, // Pass selected farm_id
          );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully onboarded animals!'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
        context.go('/buffalo-allocation');
      } else if (mounted) {
        _showError(dashboardState.error ?? 'Failed to submit');
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.errorRed),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchFarms() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null) return [];

    try {
      return await ApiServices.getFarms(token: token);
    } catch (e) {
      debugPrint('Error fetching farms: $e');
      return [];
    }
  }

  Widget _buildFarmSelector(WidgetRef ref) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _farmsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Error loading farms',
              style: TextStyle(color: AppTheme.errorRed),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'No farms available',
              style: TextStyle(color: Colors.orange),
            ),
          );
        }

        final farms = snapshot.data!;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              isExpanded: true,
              hint: const Text('Select Farm for Onboarding'),
              value: selectedFarmId,
              items: farms.map((farm) {
                return DropdownMenuItem(
                  value: farm['id'] as int,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.agriculture_rounded,
                        size: 20,
                        color: AppTheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        farm['farm_name'] as String,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedFarmId = value;
                });
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(farmManagerProvider.select((s) => s.currentOrder), (prev, next) {
      if (prev?.order.id != next?.order.id) {
        _initializeEmptyEntries();
        setState(() {});
      }
    });

    final dashboardState = ref.watch(farmManagerProvider);
    final order = dashboardState.currentOrder;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Admin Animal Onboarding'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () {
            ref.read(farmManagerProvider.notifier).clearOrder();
            context.go('/admin-dashboard');
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    hint: 'Investor Mobile',
                    controller: searchController,
                    prefixIcon: const Icon(Icons.phone),
                    keyboardType: TextInputType.phone,
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _showPaidOrdersDialog,
                  child: const Text('Find'),
                ),
              ],
            ),
            if (order != null) ...[
              const SizedBox(height: 24),
              // Investor Summary Card
              InfoCard(
                title: 'Investor Profile',
                icon: Icons.person_outline_rounded,
                color: Colors.blue,
                children: [
                  InfoDataRow(label: 'Name', value: order.investor.fullName),
                  InfoDataRow(label: 'Mobile', value: order.investor.mobile),
                  InfoDataRow(label: 'Email', value: order.investor.email),
                ],
              ),
              const SizedBox(height: 16),

              // Farm Selector
              _buildFarmSelector(ref),
              const SizedBox(height: 16),

              // Investment Summary Card
              InfoCard(
                title: 'Investment Details',
                icon: Icons.account_balance_wallet_outlined,
                color: Colors.teal,
                children: [
                  InfoDataRow(label: 'Order ID', value: order.order.id),
                  InfoDataRow(
                    label: 'Total Cost',
                    value:
                        '₹${NumberFormat('#,##,###').format(order.order.totalCost)}',
                  ),
                  InfoDataRow(
                    label: 'UTR Number',
                    value: order.transaction.utrNumber,
                  ),
                  InfoDataRow(
                    label: 'Date',
                    value: order.order.placedAt.split('T')[0],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (buffaloEntries.isNotEmpty)
                CollapsibleSectionTitle(
                  title: 'Buffaloes',
                  isExpanded: _isBuffaloExpanded,
                  onToggle: () =>
                      setState(() => _isBuffaloExpanded = !_isBuffaloExpanded),
                ),
              if (_isBuffaloExpanded)
                ...buffaloEntries.asMap().entries.map(
                  (e) => AnimalEntryForm(
                    entry: e.value,
                    index: e.key,
                    onRemove: () =>
                        setState(() => buffaloEntries.removeAt(e.key)),
                    onUpdate: () => setState(() {}),
                  ),
                ),
              if (calfEntries.isNotEmpty)
                CollapsibleSectionTitle(
                  title: 'Calves',
                  isExpanded: _isCalfExpanded,
                  onToggle: () =>
                      setState(() => _isCalfExpanded = !_isCalfExpanded),
                ),
              if (_isCalfExpanded)
                ...calfEntries.asMap().entries.map(
                  (e) => AnimalEntryForm(
                    entry: e.value,
                    index: e.key,
                    onRemove: () => setState(() => calfEntries.removeAt(e.key)),
                    onUpdate: () => setState(() {}),
                    buffaloEntries: buffaloEntries,
                  ),
                ),
              if (buffaloEntries.isNotEmpty || calfEntries.isNotEmpty)
                Center(
                  child: TextButton.icon(
                    onPressed: () {
                      setState(() {
                        int seed = DateTime.now().millisecondsSinceEpoch;
                        for (int i = 0; i < buffaloEntries.length; i++) {
                          final entry = buffaloEntries[i];
                          entry.rfidTag = 'RFID-TEST-${(seed + i) % 100000}';
                          entry.earTag = 'ET-${(seed + i) % 10000}';
                          entry.ageMonths = 36;
                          entry.dob = '2021-01-01';
                        }
                        for (int i = 0; i < calfEntries.length; i++) {
                          final entry = calfEntries[i];
                          entry.rfidTag =
                              'RFID-CTEST-${(seed + i + 100) % 100000}';
                          entry.earTag = 'CET-${(seed + i + 100) % 10000}';
                          entry.ageMonths = 6;
                          entry.dob = '2023-01-01';
                          if (buffaloEntries.isNotEmpty) {
                            entry.parentAnimalId = 'BUFFALOTEMP_0';
                          }
                        }
                      });
                    },
                    icon: const Icon(Icons.auto_fix_high),
                    label: const Text('Autofill Test Data'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.secondary,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              CustomActionButton(
                onPressed: _submit,
                color: AppTheme.primary,
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Confirm Onboarding',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
