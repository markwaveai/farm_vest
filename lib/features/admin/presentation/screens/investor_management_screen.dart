import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/admin_provider.dart';

class InvestorManagementScreen extends ConsumerStatefulWidget {
  const InvestorManagementScreen({super.key});

  @override
  ConsumerState<InvestorManagementScreen> createState() =>
      _InvestorManagementScreenState();
}

class _InvestorManagementScreenState
    extends ConsumerState<InvestorManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(adminProvider.notifier).fetchInvestors());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProvider);
    final investors = adminState.investorList.where((investor) {
      final fullName = '${investor['first_name']} ${investor['last_name']}'
          .toLowerCase();
      final phone = investor['phone_number']?.toString() ?? '';
      return fullName.contains(_searchQuery.toLowerCase()) ||
          phone.contains(_searchQuery);
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      appBar: AppBar(
        title: const Text('Investor Management'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primary,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or phone...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: adminState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : investors.isEmpty
                ? const Center(child: Text('No investors found'))
                : ListView.builder(
                    itemCount: investors.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      final investor = investors[index];
                      return _buildInvestorCard(investor);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvestorCard(Map<String, dynamic> investor) {
    final firstName = investor['first_name'] ?? '';
    final lastName = investor['last_name'] ?? '';
    final fullName = '$firstName $lastName';
    final animalCount = investor['animal_count'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: AppTheme.primary.withOpacity(0.1),
          child: Text(
            firstName.isNotEmpty ? firstName[0].toUpperCase() : '?',
            style: const TextStyle(
              color: AppTheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          fullName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(investor['phone_number'] ?? 'No phone'),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.pets, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '$animalCount Buffaloes',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          context.pushNamed(
            'investor-animals',
            extra: {
              'investorId': investor['investor_id'],
              'investorName': fullName,
            },
          );
        },
      ),
    );
  }
}
