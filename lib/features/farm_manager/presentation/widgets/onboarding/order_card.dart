import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/features/farm_manager/data/models/animalkart_order_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderCard extends StatelessWidget {
  final AnimalkartOrder item;
  final VoidCallback onTap;

  const OrderCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.lightGrey, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primary.withValues(alpha: 0.1),
                            AppTheme.darkPrimary.withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.receipt_long,
                        color: AppTheme.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.investor.fullName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.darkGrey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '📱 ${item.investor.mobile}',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.grey1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Order #${item.order.id.substring(0, 8)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.grey1,
                              fontFamily: 'Monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: AppTheme.grey1,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Divider(height: 1, color: AppTheme.lightGrey),
                const SizedBox(height: 16),

                // Stats Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatItem(
                      'Buffaloes',
                      item.order.buffaloCount.toString(),
                      Icons.pets,
                    ),
                    _buildStatItem(
                      'Calves',
                      item.order.calfCount.toString(),
                      Icons.cruelty_free,
                    ),
                    _buildStatItem(
                      'Total',
                      '₹${NumberFormat('#,##,###').format(item.order.totalCost)}',
                      Icons.payments_outlined,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AppTheme.grey1),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.grey1,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppTheme.darkGrey,
          ),
        ),
      ],
    );
  }
}
