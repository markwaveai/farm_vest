import 'package:farm_vest/core/theme/app_constants.dart';
import 'package:farm_vest/core/utils/navigation_helper.dart';
import 'package:farm_vest/core/utils/toast_utils.dart';
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
              const Text('Quick Actions', style: AppTheme.headingMedium),
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
                    () => _showRaiseTicketDialog(context),
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
              const Text(
                'Frequently Asked Questions',
                style: AppTheme.headingMedium,
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
                      const Text(
                        'Contact Information',
                        style: AppTheme.headingSmall,
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
                    const Text('FarmVest v1.0.0', style: AppTheme.bodySmall),
                    const SizedBox(height: AppConstants.spacingXS),
                    const Text(
                      AppConstants.poweredBy,
                      style: AppTheme.bodySmall,
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
    return Card(
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
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.spacingXS),
              Text(
                softWrap: true,

                subtitle,
                style: AppTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAQCard(FAQ faq) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingM),
      child: ExpansionTile(
        leading: Icon(faq.icon, color: AppTheme.primary),
        title: Text(
          faq.question,
          style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.spacingM),
            child: Text(faq.answer, style: AppTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo(IconData icon, String label, String value) {
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
                style: AppTheme.bodySmall.copyWith(color: AppTheme.mediumGrey),
              ),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
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
                Navigator.pop(context);
                ToastUtils.showInfo(context, 'Opening live chat...');
              },
            ),
            ListTile(
              leading: const Icon(Icons.phone, color: AppTheme.primary),
              title: const Text('Phone Call'),
              subtitle: const Text('+91 98765 43210'),
              onTap: () {
                Navigator.pop(context);
                _makePhoneCall();
              },
            ),
            ListTile(
              leading: const Icon(Icons.email, color: AppTheme.primary),
              title: const Text('Email'),
              subtitle: const Text('support@markwave.com'),
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

  void _showRaiseTicketDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const RaiseSupportTicketDialog(),
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

class RaiseSupportTicketDialog extends StatefulWidget {
  const RaiseSupportTicketDialog({super.key});

  @override
  State<RaiseSupportTicketDialog> createState() =>
      _RaiseSupportTicketDialogState();
}

class _RaiseSupportTicketDialogState extends State<RaiseSupportTicketDialog> {
  final TextEditingController _issueController = TextEditingController();
  String _selectedPriority = 'Medium';

  @override
  void dispose() {
    _issueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Raise Support Ticket'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            value: _selectedPriority,
            decoration: const InputDecoration(labelText: 'Priority'),
            items: ['Low', 'Medium', 'High', 'Critical']
                .map(
                  (priority) =>
                      DropdownMenuItem(value: priority, child: Text(priority)),
                )
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedPriority = value!;
              });
            },
          ),
          const SizedBox(height: AppConstants.spacingM),
          TextField(
            controller: _issueController,
            decoration: const InputDecoration(
              labelText: 'Describe your issue',
              hintText: 'Please provide details about the problem...',
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            ToastUtils.showSuccess(
              context,
              'Ticket raised successfully! We\'ll contact you soon.',
            );
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
