import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/core/widgets/custom_Textfield.dart';
import 'package:farm_vest/features/employee/new_supervisor/providers/supervisor_animals_provider.dart';
import 'package:farm_vest/features/investor/data/models/investor_animal_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class BuffaloProfileView extends ConsumerStatefulWidget {
  const BuffaloProfileView({super.key});

  @override
  ConsumerState<BuffaloProfileView> createState() => _BuffaloProfileViewState();
}

class _BuffaloProfileViewState extends ConsumerState<BuffaloProfileView> {
  String selectedTab = "Buffalo Profile";
  final List<String> tabs = [
    "Buffalo Profile",
    "Milk Production",
    "Heat Cycle",
  ];

  String milkFilter = "Today";
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _eveningMilkController = TextEditingController();
  final TextEditingController _morningMilkController = TextEditingController();
  final TextEditingController _todayMilkController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final query = ref.read(animalSearchQueryProvider);
    _searchController.text = query == 'all' ? '' : query;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _eveningMilkController.dispose();
    _morningMilkController.dispose();
    _todayMilkController.dispose();
    super.dispose();
  }

  void _onSearch() {
    final query = _searchController.text.trim();
    ref.read(animalSearchQueryProvider.notifier).state = query.isEmpty
        ? 'all'
        : query;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        _buildTabs(),
        const SizedBox(height: 16),
        Expanded(child: _buildTabContent()),
      ],
    );
  }

  Widget _buildTabContent() {
    switch (selectedTab) {
      case "Milk Production":
        return _buildMilkProductionTab();
      case "Heat Cycle":
        return _buildHeatCycleTab();
      case "Buffalo Profile":
      default:
        return _buildBuffaloProfileTab();
    }
  }

  Widget _buildBuffaloProfileTab() {
    final animalsAsync = ref.watch(searchedAnimalsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white12
                : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _searchController,
                    hint: "Enter Tag, RFID or ID",
                    style: const TextStyle(fontSize: 14),
                    onFieldSubmitted: (_) => _onSearch(),
                    onChanged: (v) {
                      if (v.isEmpty) _onSearch();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 54,
                  width: 54,
                  decoration: BoxDecoration(
                    color: AppTheme.darkPrimary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.search,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Theme.of(context).colorScheme.onSurface
                          : Colors.white,
                    ),
                    onPressed: _onSearch,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            animalsAsync.when(
              data: (animals) {
                if (animals.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: Text("No animals found")),
                  );
                }
                return Column(
                  children: animals
                      .map((animal) => _buildBuffaloCard(animal))
                      .toList(),
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, stack) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(child: Text("Error: $err")),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMilkProductionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white12
                    : Colors.grey.shade300,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withOpacity(0.05)
                        : AppTheme.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: ["Today", "Month", "Year"].map((filter) {
                      final isSelected = milkFilter == filter;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => milkFilter = filter),
                          child: Container(
                            alignment: Alignment.center,
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.darkPrimary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              filter,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? AppTheme.white
                                    : (Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Theme.of(
                                              context,
                                            ).colorScheme.onSurface
                                          : AppTheme.darkPrimary),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _searchController,
                        hint: "Enter Buffalo ID",
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 54,
                      width: 54,
                      decoration: BoxDecoration(
                        color: AppTheme.darkPrimary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.search,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Theme.of(context).colorScheme.onSurface
                              : Colors.white,
                        ),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildMilkEntryRow(
                  "Evening milk",
                  _eveningMilkController,
                  "0.0 Litre",
                ),
                const SizedBox(height: 12),
                _buildMilkEntryRow(
                  "Morning milk",
                  _morningMilkController,
                  "0.0 Litre",
                ),
                const SizedBox(height: 12),
                _buildMilkEntryRow(
                  "Today's milk",
                  _todayMilkController,
                  "0.0 Litre",
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 220,
            height: 48,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.darkPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text(
                "Save",
                style: TextStyle(fontSize: 16, color: AppTheme.white),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: 220,
            height: 48,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                backgroundColor: AppTheme.darkPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text(
                "Cancel",
                style: TextStyle(fontSize: 16, color: AppTheme.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilkEntryRow(
    String label,
    TextEditingController controller,
    String hint,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        Expanded(
          child: CustomTextField(
            controller: controller,
            hint: hint,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildHeatCycleTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          _buildHeatCard(
            "Buffalo #32 (TAG - 8889)",
            "Shed 02 / Row 04",
            "Supervisor's Message:\nInitiate to AI Protocol.",
          ),
          const SizedBox(height: 24),
          Text(
            "Buffalo Profiles",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildBuffaloProfileImage("#65", "View Profile"),
              const SizedBox(width: 12),
              _buildBuffaloProfileImage("#66", "View Profile"),
              const SizedBox(width: 12),
              _buildBuffaloProfileImage("#67", "View Profile"),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white12
                    : Colors.grey.shade300,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: AppTheme.darkPrimary,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Mark Heat Details",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildDetailRow("ID", "BUF-082"),
                      const SizedBox(height: 12),
                      _buildDetailRow("Date of Observation", "28-01-2026"),
                      const SizedBox(height: 12),
                      _buildDetailRow("Heat Intensity", "High"),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        "Observation Notes",
                        "Bellowing, clear discharge, restless.",
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow("Recorded By", "Murrah"),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: 220,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.darkPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: const Text(
                            "See all",
                            style: TextStyle(
                              fontSize: 16,
                              color: AppTheme.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeatCard(String title, String subtitle, String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white12
              : Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/icons/buffalo_icon.png',
              width: 80,
              height: 80,
              fit: BoxFit.contain,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: AppTheme.mediumGrey),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Action Required",
                    style: TextStyle(
                      color: AppTheme.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuffaloProfileImage(String id, String status) {
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(Icons.pets, color: AppTheme.primary, size: 40),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            id,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.darkPrimary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: const TextStyle(
                color: AppTheme.white,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white.withOpacity(0.05)
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white12
              : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: tabs.map((tab) {
          final isSelected = selectedTab == tab;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => selectedTab = tab),
              child: Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.darkPrimary : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  tab,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? AppTheme.white
                        : (Theme.of(context).brightness == Brightness.dark
                              ? Theme.of(context).colorScheme.onSurface
                              : AppTheme.darkPrimary),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBuffaloCard(InvestorAnimal animal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white12
              : Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          iconColor: AppTheme.darkPrimary,
          collapsedIconColor: AppTheme.darkPrimary,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(
                  Icons.monitor_heart_outlined,
                  color: AppTheme.primary,
                  size: 22,
                ),
                onPressed: () {
                  context.push(
                    '/buffalo-device-details',
                    extra: {
                      'animalId': animal.animalId,
                      'beltId':
                          animal.neckBandId ??
                          'S1IAD1884', // Fallback to fixed belt id as requested for now
                      'rfid': animal.rfid,
                      'tagNumber': animal.earTagId,
                    },
                  );
                },
              ),
              const Icon(Icons.expand_more, color: AppTheme.darkPrimary),
            ],
          ),
          leading: CircleAvatar(
            backgroundColor: AppTheme.primary.withOpacity(0.1),
            child: const Icon(Icons.pets, color: AppTheme.primary, size: 20),
          ),
          title: Text(
            animal.rfid ?? 'No RFID',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
              fontSize: 14,
            ),
          ),
          subtitle: Text(
            "Tag: ${animal.earTagId ?? 'N/A'} | Shed: ${animal.shedName ?? 'N/A'} | Slot: ${animal.parkingId ?? 'N/A'}",
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          children: [
            const SizedBox(height: 8),
            _buildBuffaloDetailRow("ID", animal.animalId),
            _buildBuffaloDetailRow(
              "Slot",
              animal.parkingId ?? 'N/A',
              onTap: animal.parkingId != null
                  ? () {
                      context.push(
                        '/buffalo-allocation',
                        extra: {
                          'shedId': animal.shedId,
                          'parkingId': animal.parkingId,
                          'farmId': animal.farmId,
                          'animalId': animal.animalId,
                        },
                      );
                    }
                  : null,
            ),
            _buildBuffaloDetailRow("Breed", animal.breed ?? 'N/A'),
            _buildBuffaloDetailRow("Age", "${animal.age ?? 'N/A'} months"),
            _buildBuffaloDetailRow("Type", animal.animalType ?? 'N/A'),
            _buildBuffaloDetailRow("Health", animal.healthStatus),
            _buildBuffaloDetailRow("Status", animal.status ?? 'N/A'),
            if (animal.onboardedAt != null)
              _buildBuffaloDetailRow(
                "Onboarded",
                DateFormat('dd MMM yyyy').format(animal.onboardedAt!),
              ),
            Divider(
              height: 24,
              thickness: 1,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white12
                  : Colors.grey.shade300,
            ),
            _buildBuffaloDetailRow("Farm", animal.farmName ?? 'N/A'),
            _buildBuffaloDetailRow("Investor", animal.investorName ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildBuffaloDetailRow(
    String label,
    String value, {
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 13,
                  color: onTap != null
                      ? AppTheme.primary
                      : Theme.of(context).colorScheme.onSurface,
                  fontWeight: onTap != null ? FontWeight.bold : FontWeight.w500,
                  decoration: onTap != null ? TextDecoration.underline : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
