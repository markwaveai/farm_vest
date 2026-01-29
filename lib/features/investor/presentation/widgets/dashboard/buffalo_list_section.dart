import 'package:farm_vest/core/theme/app_constants.dart';
import 'package:farm_vest/core/utils/toast_utils.dart';
import 'package:farm_vest/features/investor/data/models/investor_animal_model.dart';
import 'package:farm_vest/features/investor/presentation/providers/investor_providers.dart';
import 'package:farm_vest/features/investor/presentation/widgets/dashboard/buffalo_card.dart';
// import 'package:farm_vest/features/investor/presentation/widgets/invoice_screen.dart'; // Commented out as currently disabled
// import 'package:farm_vest/features/investor/presentation/widgets/pdf_viewer.dart'; // Commented out as currently disabled
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BuffaloListSection extends ConsumerStatefulWidget {
  const BuffaloListSection({super.key});

  @override
  ConsumerState<BuffaloListSection> createState() => _BuffaloListSectionState();
}

class _BuffaloListSectionState extends ConsumerState<BuffaloListSection> {
  bool _isGridView = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buffalosAsync = ref.watch(filteredBuffaloListProvider);

    return Column(
      children: [
        // Header with toggle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Buffaloes',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
                onPressed: () {
                  setState(() {
                    _isGridView = !_isGridView;
                  });
                },
                tooltip: _isGridView
                    ? 'Switch to List View'
                    : 'Switch to Grid View',
              ),
            ],
          ),
        ),

        // List/Grid Content
        Expanded(
          child: buffalosAsync.when(
            data: (data) {
              if (data.isEmpty) {
                return const Center(child: Text('No buffaloes found'));
              }

              return _isGridView
                  ? _buildGridView(context, data, ref)
                  : _buildListView(context, data, ref);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) =>
                Center(child: Text('Error: ${err.toString()}')),
          ),
        ),
      ],
    );
  }

  Widget _buildGridView(
    BuildContext context,
    List<InvestorAnimal> buffalos,
    WidgetRef ref,
  ) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.65,
      ),
      itemCount: buffalos.length,
      itemBuilder: (context, index) {
        final buffalo = buffalos[index];
        return BuffaloCard(
          rfid: buffalo.rfid ?? '',
          shedName: buffalo.shedId.toString() ?? '',

          age: buffalo.age?.toString() ?? '-',

          farmName: buffalo.farmName ?? 'FarmVest Unit',
          location: buffalo.farmLocation ?? 'Location',
          // ShedName: buffalo.ShedName ?? '-',
          imageUrl: buffalo.images.isNotEmpty ? buffalo.images.first : null,
          isGridView: true,
          onTap: () {
            context.push('/unit-details', extra: {'buffalo': buffalo});
          },
          onInvoiceTap: () async {
            _handleInvoiceTap(context, ref, buffalo.rfid);
          },
          onCalvesTap: () async {
            _handleCalvesTap(context, buffalo.rfid);
          },
          healthStatus: buffalo.healthStatus,
          lastMilking: '',
          breed: '',
          id: buffalo.animalId,
        );
        // return BuffaloCard(
        //   farmName: buffalo.farmName ?? 'FarmVest Unit',
        //   location: buffalo.farmLocation ?? 'Location',
        //   id: buffalo.animalId,
        //   healthStatus: buffalo.healthStatus,
        //   lastMilking: 'Checked recently',
        //   age: '-', // Field not available in new model
        //   breed: '-', // Field not available in new model
        //   imageUrl: buffalo.images.isNotEmpty ? buffalo.images.first : null,
        //   isGridView: true,
        //   onTap: () {
        //     // Passing the new model directly. Screen receiving this must be updated to handle InvestorAnimal.
        //     context.push('/unit-details', extra: {'buffalo': buffalo});
        //   },
        //   onInvoiceTap: () async {
        //     _handleInvoiceTap(context, ref, buffalo.animalId);
        //   },
        //   onCalvesTap: () async {
        //     _handleCalvesTap(context, buffalo.animalId);
        //   },
        // );
      },
    );
  }

  Widget _buildListView(
    BuildContext context,
    List<InvestorAnimal> buffalos,
    WidgetRef ref,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      itemCount: buffalos.length,
      itemBuilder: (context, index) {
        final buffalo = buffalos[index];

        return BuffaloCard(
          rfid: buffalo.rfid ?? kHyphen,
          age: buffalo.age?.toString() ?? kHyphen,
          farmName: buffalo.farmName ?? kHyphen,
          location: buffalo.farmLocation ?? kHyphen,
          shedName: buffalo.shedId?.toString() ?? kHyphen,
          imageUrl: buffalo.images.isNotEmpty ? buffalo.images.first : null,
          isGridView: false,
          onTap: () {
            context.push('/unit-details', extra: {'buffalo': buffalo});
          },
          onInvoiceTap: () async {
            _handleInvoiceTap(context, ref, buffalo.rfid);
          },
          onCalvesTap: () async {
            _handleCalvesTap(context, buffalo.rfid);
          },
          id: buffalo.animalId,
          healthStatus: buffalo.healthStatus,
          lastMilking: '',
          breed: '',
        );

        // return BuffaloCard(
        //   farmName: buffalo.farmName ?? 'FarmVest Unit',
        //   location: buffalo.farmLocation ?? 'Location',
        //   id: buffalo.animalId,
        //   healthStatus: buffalo.healthStatus,
        //   lastMilking: 'Checked recently',
        //   age: '-', // Field not available in new model
        //   breed: '-', // Field not available in new model
        //   imageUrl: buffalo.images.isNotEmpty ? buffalo.images.first : null,
        //   isGridView: false,
        //   onTap: () {
        //     context.push('/unit-details', extra: {'buffalo': buffalo});
        //   },
        //   onInvoiceTap: () async {
        //     _handleInvoiceTap(context, ref, buffalo.animalId);
        //   },
        //   onCalvesTap: () async {
        //     _handleCalvesTap(context, buffalo.animalId);
        //   },
        // );
      },
    );
  }

  Future<void> _handleInvoiceTap(
    BuildContext context,
    WidgetRef ref,
    String? buffaloId,
  ) async {
    // Invoice feature temporarily disabled due to model refactoring
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Invoice feature coming soon available")),
    );

    /* 
    // OLD CODE - KEEPING FOR REFERENCE UNTIL RE-ENABLED
    final unitResponse = ref.read(unitResponseProvider).value;
    Order? order;

    if (unitResponse?.orders != null && buffaloId != null) {
      try {
        order = unitResponse!.orders!.firstWhere(
          (o) => o.buffalos?.any((b) => b.id == buffaloId) ?? false,
        );
      } catch (_) {}
    }
    
    if (order != null) {
      final path = await InvoiceGenerator.generateInvoice(order);
      if (!context.mounted) return;

      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (_) => InvoicePdfView(order: order!, filePath: path),
        ),
      );
    } else {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invoice not found for this unit")),
      );
    }
    */
  }

  Future<void> _handleCalvesTap(BuildContext context, String? buffaloId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null) {
      ToastUtils.showError(context, "Authentication error");
      return;
    }

    ToastUtils.showInfo(context, "Fetching calves...");

    // Logic for fetching calves would go here
    // Currently disabled/commented out in original code
  }
}
