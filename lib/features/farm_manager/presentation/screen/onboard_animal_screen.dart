import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/core/widgets/custom_button.dart';
import 'package:farm_vest/core/widgets/custom_textfield.dart';
import 'package:farm_vest/features/farm_manager/presentation/providers/farm_manager_provider.dart';
import 'package:farm_vest/features/farm_manager/presentation/providers/paid_orders_provider.dart';
import 'package:farm_vest/features/auth/presentation/providers/auth_provider.dart';
import 'package:farm_vest/core/utils/app_enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../data/models/animal_onboarding_entry.dart';
import '../widgets/onboarding/animal_entry_form.dart';
import '../widgets/onboarding/collapsible_section_title.dart';
import '../widgets/onboarding/info_card.dart';
import '../widgets/onboarding/order_card.dart';

class OnboardAnimalScreen extends ConsumerStatefulWidget {
  const OnboardAnimalScreen({super.key});

  @override
  ConsumerState<OnboardAnimalScreen> createState() =>
      _OnboardAnimalScreenState();
}

class _OnboardAnimalScreenState extends ConsumerState<OnboardAnimalScreen> {
  final TextEditingController searchController = TextEditingController();

  // Multiple animal entries for this order
  List<AnimalOnboardingEntry> buffaloEntries = [];
  List<AnimalOnboardingEntry> calfEntries = [];
  int currentBuffaloIndex = 0;
  int currentCalfIndex = 0;

  bool _isBuffaloExpanded = true;
  bool _isSubmitting = false;
  int? _selectedFarmId;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final auth = ref.read(authProvider);
      if (auth.role == UserType.farmManager) {
        final fId = int.tryParse(auth.userData?.farmId ?? '');
        debugPrint("OnboardAnimalScreen: FM Farm ID initialization: $fId");
        if (mounted) {
          setState(() {
            _selectedFarmId = fId;
          });
        }
      }
    });

    _initializeEmptyEntries();
    searchController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  void _initializeEmptyEntries() {
    final dashboardState = ref.read(farmManagerProvider);
    final order = dashboardState.currentOrder;

    if (order != null) {
      // Create empty entries for buffaloes
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
          status: 'high_yield', // Default from JSON example
          type: 'BUFFALO',
          breedName: 'Murrah Buffalo', // Default or fetch
          breedId: 'MURRAH-001',
          images: [],
        );
      });

      // Create empty entries for calves
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
          parentAnimalId: '', // To be selected
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
    if (mobile.length < 10) {
      _showError('Please enter a valid 10-digit mobile number');
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final ordersAsync = ref.watch(
              paidOrdersProvider(
                IntransitOrdersParams(mobile: mobile.isEmpty ? null : mobile),
              ),
            );

            return Dialog(
              insetPadding: const EdgeInsets.all(20),
              backgroundColor: Colors.transparent,
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                  maxWidth: 600,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.shadow,
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.receipt_long,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  mobile.isEmpty
                                      ? 'All Paid Orders'
                                      : 'Orders for $mobile',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Select an order to continue',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close, color: Colors.white),
                          ),
                        ],
                      ),
                    ),

                    // Content
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        child: ordersAsync.when(
                          data: (paidOrdersData) {
                            final orders = paidOrdersData.orders;
                            final filteredOrders = mobile.isEmpty
                                ? orders
                                : orders
                                      .where((o) => o.investor.mobile == mobile)
                                      .toList();

                            if (filteredOrders.isEmpty) {
                              return Container(
                                padding: const EdgeInsets.all(40),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: AppTheme.lightGrey,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.inbox_outlined,
                                        size: 48,
                                        color: Theme.of(context).disabledColor,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No paid orders found',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      mobile.isEmpty
                                          ? 'There are no paid orders available.'
                                          : 'No orders found for this mobile number.',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Theme.of(context).hintColor,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              );
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Orders List
                                Expanded(
                                  child: ListView.separated(
                                    itemCount: filteredOrders.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 12),
                                    itemBuilder: (context, index) {
                                      final item = filteredOrders[index];
                                      return OrderCard(
                                        item: item,
                                        onTap: () {
                                          ref
                                              .read(
                                                farmManagerProvider.notifier,
                                              )
                                              .setOrder(item);
                                          Navigator.pop(context);
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                          loading: () => Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Loading orders...',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(context).hintColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          error: (err, stack) => Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: AppTheme.errorRed.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.error_outline,
                                    size: 48,
                                    color: AppTheme.errorRed,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Error loading orders',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.errorRed,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  err.toString(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.grey1,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _submit() async {
    final dashboardState = ref.read(farmManagerProvider);
    final order = dashboardState.currentOrder;

    if (order == null) return;
    if (_isSubmitting) return;

    // Validate all animal entries
    final allAnimals = [...buffaloEntries, ...calfEntries];
    for (int i = 0; i < allAnimals.length; i++) {
      final animal = allAnimals[i];
      final animalName = "${animal.type.toLowerCase()} #${i + 1}";

      if (animal.rfidTag.trim().isEmpty) {
        _showError('RFID Tag is required for $animalName');
        return;
      }

      // Enforce RFID- prefix as required by backend
      if (!animal.rfidTag.startsWith('RFID-')) {
        _showError('RFID Tag must start with "RFID-" for $animalName');
        return;
      }

      if (animal.earTag.trim().isEmpty) {
        _showError('Ear Tag is required for $animalName');
        return;
      }

      if (animal.type == 'BUFFALO' && animal.ageMonths < 36) {
        _showError('Buffalo age must be 36 months or above for $animalName');
        return;
      }

      if (animal.ageMonths <= 0 || animal.ageMonths > 300) {
        _showError('Valid Age (1-300 months) is required for $animalName');
        return;
      }

      if (animal.healthStatus.trim().isEmpty) {
        _showError('Health Status is required for $animalName');
        return;
      }

      if (animal.images.isEmpty) {
        _showError('At least one photo is required for $animalName');
        return;
      }

      if (animal.type == 'BUFFALO') {
        if (animal.breedName.trim().isEmpty) {
          _showError('Breed Name is required for $animalName');
          return;
        }
        if (animal.status.trim().isEmpty) {
          _showError('Status is required for $animalName');
          return;
        }
      } else if (animal.type == 'CALF') {
        if (animal.parentAnimalId.isEmpty) {
          _showError('Please select a Parent Buffalo for $animalName');
          return;
        }
      }
    }

    setState(() => _isSubmitting = true);

    try {
      // Prepare animals list with resolved Parent IDs
      final List<AnimalOnboardingEntry> preparedAnimals = [];

      // Add Buffalos
      preparedAnimals.addAll(buffaloEntries);

      // Add Calves, resolving Parent ID from TEMP index to actual Ear Tag
      for (var calf in calfEntries) {
        String resolvedParentId = calf.parentAnimalId;
        if (resolvedParentId.startsWith('BUFFALOTEMP_')) {
          final indexStr = resolvedParentId.replaceAll('BUFFALOTEMP_', '');
          final index = int.tryParse(indexStr);
          if (index != null && index >= 0 && index < buffaloEntries.length) {
            // Use the RFID Tag of the referenced buffalo as the Parent ID
            final rfid = buffaloEntries[index].rfidTag;
            resolvedParentId = rfid.startsWith('RFID-') ? rfid : 'RFID-$rfid';
          }
        }
        preparedAnimals.add(calf.copyWith(parentAnimalId: resolvedParentId));
      }

      final success = await ref
          .read(farmManagerProvider.notifier)
          .onboardAnimalsBulk(
            order: order,
            animals: preparedAnimals,
            farmId: _selectedFarmId,
          );

      if (!success) {
        if (mounted) {
          setState(() => _isSubmitting = false);
          _showError(
            dashboardState.error ?? 'Failed to submit onboarding data',
          );
        }
        return;
      }

      if (mounted) {
        // Clear all entries and reset
        _initializeEmptyEntries();

        context.go('/buffalo-allocation');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text('Successfully onboarded ${allAnimals.length} animals!'),
              ],
            ),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to onboard animals: ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.errorRed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Listen for changes in the current order to reset the form
    ref.listen(farmManagerProvider.select((s) => s.currentOrder), (prev, next) {
      if (prev?.order.id != next?.order.id) {
        // Order changed, re-initialize
        _initializeEmptyEntries();
        setState(() {}); // Trigger rebuild to show new entries
      }
    });

    final dashboardState = ref.watch(farmManagerProvider);
    final order = dashboardState.currentOrder;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text(
          'Buffalo Onboarding',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () {
            ref.read(farmManagerProvider.notifier).clearOrder();
            if (context.canPop()) {
              context.pop();
            } else {
              final userRole = ref.read(authProvider).role;
              if (userRole == UserType.supervisor) {
                context.go('/supervisor-dashboard');
              } else {
                context.go('/farm-manager-dashboard');
              }
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Section
            SectionTitle('Find Investor Orders'),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: CustomTextField(
                    hint: 'Enter mobile number...',
                    controller: searchController,
                    prefixIcon: const Icon(Icons.phone_android_rounded),
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    showCounter: false,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    // Theme aware text field is handled by CustomTextField but we ensure its consistent
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: searchController.text.trim().length < 10
                      ? null
                      : _showPaidOrdersDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Find Orders'),
                ),
              ],
            ),

            if (dashboardState.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  dashboardState.error!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
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

              const SizedBox(height: 20),

              SectionTitle('Animals to Onboard'),
              const SizedBox(height: 8),
              Text(
                'Enter identification details for each animal',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).hintColor,
                ),
              ),
              const SizedBox(height: 16),

              // Buffalo Forms
              if (buffaloEntries.isNotEmpty) ...[
                CollapsibleSectionTitle(
                  title: 'Buffaloes (${buffaloEntries.length})',
                  isExpanded: _isBuffaloExpanded,
                  onToggle: () =>
                      setState(() => _isBuffaloExpanded = !_isBuffaloExpanded),
                ),
                const SizedBox(height: 12),

                if (_isBuffaloExpanded)
                  ...buffaloEntries.asMap().entries.map((entry) {
                    final index = entry.key;
                    final buffalo = entry.value;
                    final calf = (index < calfEntries.length)
                        ? calfEntries[index]
                        : null;

                    return AnimalEntryForm(
                      key: ValueKey('buffalo_${index}_${buffalo.animalId}'),
                      entry: buffalo,
                      calfEntry: calf,
                      index: index,
                      buffaloEntries: buffaloEntries,
                      calfEntries: calfEntries,
                      // title: 'Buffalo', // Widget determines title from type
                      onRemove: () {
                        setState(() {
                          buffaloEntries.removeAt(index);
                          if (index < calfEntries.length) {
                            calfEntries.removeAt(index);
                          }
                          // Re-index remaining entries
                          final updatedEntries = <AnimalOnboardingEntry>[];
                          for (int i = 0; i < buffaloEntries.length; i++) {
                            final updatedBuffalo = buffaloEntries[i].copyWith(
                              rfidTag: buffaloEntries[i].rfidTag,
                              earTag: buffaloEntries[i].earTag,
                              neckbandId: buffaloEntries[i].neckbandId,
                              dob: buffaloEntries[i].dob,
                              healthStatus: buffaloEntries[i].healthStatus,
                              type: buffaloEntries[i].type,
                            );
                            updatedEntries.add(updatedBuffalo);
                          }
                          buffaloEntries = updatedEntries;
                        });
                      },
                      onUpdate: () => setState(() {}),
                    );
                  }),
              ],

              const SizedBox(height: 24),

              // Removed Global Image Selector in favor of per-animal validation
              const SizedBox(height: 24),

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
                width: double.infinity,
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
                        'Confirm Onboarding',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 40),
            ],
          ],
        ),
      ),
    );
  }
}
