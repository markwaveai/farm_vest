import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/features/investor/presentation/providers/investor_providers.dart';
import 'package:farm_vest/features/investor/data/models/investor_coins_model.dart';
import 'package:intl/intl.dart';

class InvestorCoinsScreen extends ConsumerWidget {
  const InvestorCoinsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coinsAsync = ref.watch(investorCoinsProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('My Wallet'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.dark,
        actions: [],
      ),
      body: coinsAsync.when(
        data: (response) {
          if (response == null) {
            return const Center(child: Text('No wallet data found'));
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(investorCoinsProvider.future),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(response.coins)),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Transaction History',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.dark,
                          ),
                        ),
                        Text(
                          '${response.transactions.length} items',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final tx = response.transactions[index];
                      return _buildTransactionCard(tx);
                    }, childCount: response.transactions.length),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildHeader(InvestorCoins coins) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Remaining Balance',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.stars, color: Colors.amber, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'STAGING',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _formatAmount(coins.remainingCoins),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Coins',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildStatsItem(
                'Total Earnings',
                coins.totalCoins,
                Icons.arrow_upward,
              ),
              const SizedBox(width: 24),
              _buildStatsItem(
                'Total Spent',
                coins.spendingCoins,
                Icons.shopping_bag,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildStatsItem(
                'Direct Ref.',
                coins.directReferralsCoins,
                Icons.person,
              ),
              const SizedBox(width: 24),
              _buildStatsItem(
                'Indirect Ref.',
                coins.indirectReferralsCoins,
                Icons.people,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsItem(String label, double value, IconData icon) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white60, size: 14),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(color: Colors.white60, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _formatAmount(value),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                'Coins',
                style: TextStyle(color: Colors.white60, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(CoinTransaction tx) {
    bool isCredit = tx.type == 'REFERRAL_REWARD' || tx.type == 'REFUND';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _getTypeColor(tx.type).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getTypeIcon(tx.type),
              color: _getTypeColor(tx.type),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.description,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppTheme.dark,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      tx.createdAt,
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                    if (tx.giverName.trim().isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        tx.giverName,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isCredit ? "+" : "-"}${tx.coins.toStringAsFixed(0)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isCredit ? Colors.green[700] : Colors.red[700],
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getTypeColor(tx.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  tx.referralStatus,
                  style: TextStyle(
                    color: _getTypeColor(tx.type),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'REFERRAL_REWARD':
        return Icons.redeem;
      case 'REFUND':
        return Icons.history;
      case 'REDEMPTION':
        return Icons.shopping_cart;
      default:
        return Icons.account_balance_wallet;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'REFERRAL_REWARD':
        return Colors.green;
      case 'REFUND':
        return Colors.blue;
      case 'REDEMPTION':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatAmount(double amount) {
    final format = NumberFormat.decimalPattern(
      'en_IN',
    ); // Use decimal with commas
    return format.format(amount);
  }
}
