import 'package:farm_vest/core/theme/app_constants.dart';
import 'package:farm_vest/core/utils/navigation_helper.dart';
import 'package:farm_vest/core/utils/toast_utils.dart';
import 'package:farm_vest/features/investor/presentation/screens/profile_Screens/live_chart_screen.dart';
import 'package:flutter/material.dart';
import 'package:farm_vest/core/theme/app_theme.dart';

class FAQ {
  final String question;
  final String answer;
  final IconData icon;

  FAQ({required this.question, required this.answer, required this.icon});
}

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final List<FAQ> _faqs = [
    FAQ(
      question: 'How do I book a monthly visit?',
      answer:
          'Go to Monthly Visits section, select an available slot, and confirm your booking. You can book up to 10 visits per month.',
      icon: Icons.calendar_today,
    ),
    FAQ(
      question: 'Can I view live CCTV footage?',
      answer:
          'Yes, you can access live CCTV feeds from the Live CCTV section. Make sure you have a stable internet connection for best quality.',
      icon: Icons.videocam,
    ),
    FAQ(
      question: 'How is my buffalo\'s health monitored?',
      answer:
          'Our team conducts regular health checkups, monitors vital signs, and maintains detailed health records accessible through the app.',
      icon: Icons.medical_services,
    ),
    FAQ(
      question: 'How are revenue calculations done?',
      answer:
          'Revenue is calculated based on daily milk production, current market rates, and any additional services. You can view detailed breakdowns in the Revenue section.',
      icon: Icons.attach_money,
    ),
    FAQ(
      question: 'What factors affect asset valuation?',
      answer:
          'Asset valuation considers age, milk production capacity, health score, and current market conditions. The valuation is updated monthly.',
      icon: Icons.trending_up,
    ),
    FAQ(
      question: 'How do I contact support?',
      answer:
          'You can contact support through the app, call our helpline, or raise a ticket. Our team is available 24/7 for emergencies.',
      icon: Icons.support_agent,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        NavigationHelper.safePopOrNavigate(
          context,
          fallbackRoute: '/customer-dashboard',
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Support & FAQ'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => NavigationHelper.safePopOrNavigate(
              context,
              fallbackRoute: '/customer-dashboard',
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quick Actions
              Text(
                'Quick Actions',
                style: AppTheme.headingMedium.copyWith(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
              ),
              const SizedBox(height: AppConstants.spacingM),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: AppConstants.spacingM,
                mainAxisSpacing: AppConstants.spacingM,
                childAspectRatio: 1.1,
                children: [
                  _buildActionCard(
                    'Contact Support',
                    'Chat with our team',
                    Icons.chat,
                    AppTheme.primary,
                    () => _showContactOptions(context),
                  ),
                  _buildActionCard(
                    'Raise Ticket',
                    'Report an issue',
                    Icons.report_problem,
                    AppTheme.warningOrange,
                    () => _openRaiseTicket(context),
                  ),
                  _buildActionCard(
                    'Ticket History',
                    'View past tickets',
                    Icons.history,
                    AppTheme.primary,
                    () => _openTicketHistory(context),
                  ),
                  _buildActionCard(
                    'Call MarkWave',
                    'Direct phone support',
                    Icons.phone,
                    AppTheme.secondary,
                    () => _makePhoneCall(),
                  ),
                  _buildActionCard(
                    'App Guide',
                    'Learn how to use',
                    Icons.help_outline,
                    AppTheme.darkSecondary,
                    () => _showAppGuide(context),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingL),

              // Emergency Contact
              Card(
                color: AppTheme.errorRed.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.spacingM),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.emergency,
                        color: AppTheme.errorRed,
                        size: AppConstants.iconL,
                      ),
                      const SizedBox(width: AppConstants.spacingM),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Emergency Support',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.errorRed,
                              ),
                            ),
                            const SizedBox(height: AppConstants.spacingXS),
                            const Text(
                              'For urgent health issues or emergencies',
                              style: AppTheme.bodySmall,
                            ),
                            const SizedBox(height: AppConstants.spacingS),
                            ElevatedButton(
                              onPressed: () => _callEmergency(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.errorRed,
                              ),
                              child: const Text('Call Now'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spacingL),

              // FAQs
              Text(
                'Frequently Asked Questions',
                style: AppTheme.headingMedium.copyWith(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
              ),
              const SizedBox(height: AppConstants.spacingM),

              ...(_faqs.map((faq) => _buildFAQCard(faq))),

              const SizedBox(height: AppConstants.spacingL),

              // Contact Information
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.spacingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Contact Information',
                        style: AppTheme.headingSmall.copyWith(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingM),

                      _buildContactInfo(Icons.phone, 'Phone', '+91 7702710290'),
                      _buildContactInfo(
                        Icons.email,
                        'Email',
                        'contact@markwave.ai',
                      ),
                      _buildContactInfo(
                        Icons.access_time,
                        'Support Hours',
                        '24/7 Available',
                      ),
                      _buildContactInfo(
                        Icons.location_on,
                        'Address',
                        'PSR Prime Towers, 2nd Floor,506,DLF,\nGachibowli, Hyderabad-500032',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spacingL),

              // App Version
              Center(
                child: Column(
                  children: [
                    Text(
                      'FarmVest v1.0.0',
                      style: AppTheme.bodySmall.copyWith(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white70
                            : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingXS),
                    Text(
                      AppConstants.poweredBy,
                      style: AppTheme.bodySmall.copyWith(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white70
                            : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingM),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: AppConstants.iconL),
              const SizedBox(height: AppConstants.spacingS),
              Text(
                title,
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.spacingXS),
              Text(
                subtitle,
                softWrap: true,
                style: AppTheme.bodySmall.copyWith(
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAQCard(FAQ faq) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingM),
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      child: ExpansionTile(
        leading: Icon(faq.icon, color: AppTheme.primary),
        title: Text(
          faq.question,
          style: AppTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        collapsedIconColor: isDark ? Colors.white70 : Colors.black54,
        iconColor: AppTheme.primary,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.spacingM),
            child: Text(
              faq.answer,
              style: AppTheme.bodyMedium.copyWith(
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo(IconData icon, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingM),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primary, size: AppConstants.iconM),
          const SizedBox(width: AppConstants.spacingM),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTheme.bodySmall.copyWith(
                  color: isDark ? Colors.white70 : AppTheme.mediumGrey,
                ),
              ),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showContactOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppConstants.spacingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Contact Support', style: AppTheme.headingMedium),
            const SizedBox(height: AppConstants.spacingL),

            ListTile(
              leading: const Icon(Icons.chat, color: AppTheme.primary),
              title: const Text('Live Chat'),
              subtitle: const Text('Chat with our support team'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatScreen()),
                );
                ToastUtils.showInfo(context, 'Opening live chat...');
              },
            ),
            ListTile(
              leading: const Icon(Icons.phone, color: AppTheme.primary),
              title: const Text('Phone Call'),
              subtitle: const Text('+91 77027 10290'),
              onTap: () {
                Navigator.pop(context);
                _makePhoneCall();
              },
            ),
            ListTile(
              leading: const Icon(Icons.email, color: AppTheme.primary),
              title: const Text('Email'),
              subtitle: const Text('contact@markwave.ai'),
              onTap: () {
                Navigator.pop(context);
                ToastUtils.showInfo(context, 'Opening email app...');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openRaiseTicket(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const RaiseSupportTicketSheet(),
    );
  }

  void _openTicketHistory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const TicketHistorySheet(),
    );
  }

  void _showAppGuide(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('App Instructions'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('1. Dashboard', style: AppTheme.bodyMedium),
              Text(
                'Access all features from the main dashboard. Each card takes you to a specific section.',
                style: AppTheme.bodySmall,
              ),
              SizedBox(height: AppConstants.spacingM),

              Text('2. Unit Details', style: AppTheme.bodyMedium),
              Text(
                'View detailed information about your buffalo including health status and basic info.',
                style: AppTheme.bodySmall,
              ),
              SizedBox(height: AppConstants.spacingM),

              Text('3. Live CCTV', style: AppTheme.bodyMedium),
              Text(
                'Monitor your unit in real-time. Use fullscreen mode for better viewing.',
                style: AppTheme.bodySmall,
              ),
              SizedBox(height: AppConstants.spacingM),

              Text('4. Monthly Visits', style: AppTheme.bodyMedium),
              Text(
                'Book up to 10 visits per month. Available slots are shown in green.',
                style: AppTheme.bodySmall,
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _makePhoneCall() {
    ToastUtils.showInfo(context, 'Calling +91 98765 43210...');
  }

  void _callEmergency() {
    ToastUtils.showError(context, 'Calling emergency support...');
  }
}

class RaiseSupportTicketSheet extends StatefulWidget {
  const RaiseSupportTicketSheet({super.key});

  @override
  State<RaiseSupportTicketSheet> createState() =>
      _RaiseSupportTicketSheetState();
}

class _RaiseSupportTicketSheetState extends State<RaiseSupportTicketSheet> {
  final TextEditingController _issueController = TextEditingController();
  String _selectedPriority = 'Medium';

  final priorities = ['Low', 'Medium', 'High', 'Critical'];

  @override
  void initState() {
    super.initState();
    _issueController.addListener(() {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _issueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppConstants.spacingL,
        AppConstants.spacingL,
        AppConstants.spacingL,
        bottomPadding + AppConstants.spacingL,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          // Title
          const Text('Raise a Support Ticket', style: AppTheme.headingMedium),
          const SizedBox(height: 6),
          const Text(
            'Tell us what went wrong. Our team will get back to you shortly.',
            style: AppTheme.bodySmall,
          ),

          const SizedBox(height: 24),

          // Priority selector
          const Text('Priority', style: AppTheme.bodyMedium),
          const SizedBox(height: 8),

          Wrap(
            spacing: 8,
            children: priorities.map((priority) {
              final isSelected = _selectedPriority == priority;
              return ChoiceChip(
                label: Text(priority),
                selected: isSelected,
                onSelected: (_) {
                  setState(() => _selectedPriority = priority);
                },
                checkmarkColor: Colors.black,
                selectedColor: AppTheme.primary.withOpacity(0.15),
                labelStyle: TextStyle(
                  color: isSelected ? AppTheme.primary : Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Issue description
          const Text('Describe the issue', style: AppTheme.bodyMedium),
          const SizedBox(height: 8),

          TextField(
            controller: _issueController,
            maxLines: 4,
            maxLength: 300,
            decoration: InputDecoration(
              hintText: 'Please describe your issue in detail...',
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _issueController.text.trim().isEmpty
                  ? null
                  : _submitTicket,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Submit Ticket'),
            ),
          ),
        ],
      ),
    );
  }

  void _submitTicket() {
    Navigator.pop(context);

    ToastUtils.showSuccess(
      context,
      'Ticket raised successfully! Our support team will contact you soon.',
    );
  }
}

class SupportTicket {
  final String id;
  final String issue;
  final String priority;
  final DateTime createdAt;
  final bool isClosed;

  SupportTicket({
    required this.id,
    required this.issue,
    required this.priority,
    required this.createdAt,
    required this.isClosed,
  });
}

class TicketHistorySheet extends StatefulWidget {
  const TicketHistorySheet({super.key});

  @override
  State<TicketHistorySheet> createState() => _TicketHistorySheetState();
}

class _TicketHistorySheetState extends State<TicketHistorySheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<SupportTicket> tickets = [
    SupportTicket(
      id: '1',
      issue: 'Live CCTV not loading',
      priority: 'High',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      isClosed: false,
    ),
    SupportTicket(
      id: '2',
      issue: 'Monthly visit booking issue',
      priority: 'Medium',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      isClosed: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Support Ticket History', style: AppTheme.headingMedium),
          const SizedBox(height: 12),

          TabBar(
            controller: _tabController,
            labelColor: AppTheme.primary,
            tabs: const [
              Tab(text: 'Active'),
              Tab(text: 'Closed'),
            ],
          ),

          const SizedBox(height: 12),

          SizedBox(
            height: 350,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTicketList(isClosed: false),
                _buildTicketList(isClosed: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketList({required bool isClosed}) {
    final filtered = tickets.where((t) => t.isClosed == isClosed).toList();

    if (filtered.isEmpty) {
      return const Center(child: Text('No tickets found'));
    }

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final ticket = filtered[index];
        return _TicketCard(
          ticket: ticket,
          showDelete: isClosed,
          onDelete: () {
            setState(() => tickets.remove(ticket));
            ToastUtils.showInfo(context, 'Ticket removed from history');
          },
        );
      },
    );
  }
}

class _TicketCard extends StatelessWidget {
  final SupportTicket ticket;
  final bool showDelete;
  final VoidCallback? onDelete;

  const _TicketCard({
    required this.ticket,
    this.showDelete = false,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    ticket.issue,
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (showDelete)
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: AppTheme.errorRed,
                    ),
                    onPressed: onDelete,
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text('Priority: ${ticket.priority}', style: AppTheme.bodySmall),
            const SizedBox(height: 4),
            Text(
              'Raised on: ${ticket.createdAt.day}/${ticket.createdAt.month}/${ticket.createdAt.year}',
              style: AppTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
