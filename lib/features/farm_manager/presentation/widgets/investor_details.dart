import 'package:farm_vest/features/farm_manager/presentation/providers/investor_list_provider.dart';
import 'package:farm_vest/features/auth/presentation/providers/auth_provider.dart';
import 'package:farm_vest/core/utils/app_enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'investor_card_widget.dart';
import 'package:farm_vest/core/localization/translation_helpers.dart';
class InvestorDetails extends ConsumerStatefulWidget {
  InvestorDetails({super.key});

  @override
  ConsumerState<InvestorDetails> createState() => _InvestorDetailsState();
}

class _InvestorDetailsState extends ConsumerState<InvestorDetails> {
  bool _isSearching = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterDialog() {
    final notifier = ref.read(investorListProvider.notifier);
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text('Filter by Status'.tr(ref)),
          children: [
            SimpleDialogOption(
              onPressed: () {
                notifier.setStatusFilter('all');
                Navigator.pop(context);
              },
              child: Text('All'.tr(ref)),
            ),
            SimpleDialogOption(
              onPressed: () {
                notifier.setStatusFilter('active');
                Navigator.pop(context);
              },
              child: Text('Active'.tr(ref)),
            ),
            SimpleDialogOption(
              onPressed: () {
                notifier.setStatusFilter('inactive');
                Navigator.pop(context);
              },
              child: Text('Inactive'.tr(ref)),
            ),
            SimpleDialogOption(
              onPressed: () {
                notifier.setStatusFilter('exited');
                Navigator.pop(context);
              },
              child: Text('Exited'.tr(ref)),
            ),
          ],
        );
      },
    );
  }

  AppBar _buildAppBar() {
    final theme = Theme.of(context);
    return AppBar(
      // Use GoRouter for consistent navigation
      leading: IconButton(
        onPressed: () {
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
        icon: Icon(Icons.arrow_back, color: theme.appBarTheme.foregroundColor),
      ),
      backgroundColor: theme.appBarTheme.backgroundColor,
      title: _isSearching
          ? TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search Investors...',
                hintStyle: TextStyle(
                  color: theme.appBarTheme.foregroundColor?.withOpacity(0.6),
                ),
                border: InputBorder.none,
              ),
              style: TextStyle(
                color: theme.appBarTheme.foregroundColor,
                fontSize: 18,
              ),
              onChanged: (query) {
                ref.read(investorListProvider.notifier).setSearchQuery(query);
              },
            )
          : Text("Investors Data".tr(ref)),
      titleTextStyle: TextStyle(
        fontSize: 22,
        color: theme.appBarTheme.foregroundColor,
        fontWeight: FontWeight.bold,
      ),
      actions: [
        IconButton(
          icon: Icon(
            _isSearching ? Icons.close : Icons.search,
            color: theme.appBarTheme.foregroundColor,
          ),
          onPressed: () {
            setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) {
                _searchController.clear();
                ref.read(investorListProvider.notifier).setSearchQuery('');
              }
            });
          },
        ),
        IconButton(
          icon: Icon(
            Icons.filter_list,
            color: theme.appBarTheme.foregroundColor,
          ),
          onPressed: _showFilterDialog,
        ),
      ],
    );
  }

  String _getEmptyMessage(String status) {
    switch (status) {
      case 'active':
        return 'No active investors found';
      case 'inactive':
        return 'No inactive investors found';
      case 'exited':
        return 'No exited investors found';
      default:
        return 'No investors found';
    }
  }

  @override
  Widget build(BuildContext context) {
    final investorState = ref.watch(investorListProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: investorState.isLoading
          ? Center(child: CircularProgressIndicator())
          : investorState.investors.isEmpty
          ? Center(
              child: Text(
                _getEmptyMessage(investorState.statusFilter),
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).hintColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: investorState.investors.length,
              itemBuilder: (context, index) {
                final investor = investorState.investors[index];
                return InvestorCard(
                  name: investor.fullName,
                  location: investor.address ?? 'N/A',
                  amount: '₹${investor.animalCount}',
                  date: investor.memberSince?.toIso8601String() ?? 'N/A',
                  status: investor.animalCount > 0
                      ? 'Active'
                      : 'Inactive'
                            'Exited',
                );
              },
            ),
    );
  }
}
