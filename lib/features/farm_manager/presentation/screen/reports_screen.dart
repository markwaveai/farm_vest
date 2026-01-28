import 'package:farm_vest/features/farm_manager/presentation/providers/staff_list_provider.dart';
import 'package:farm_vest/features/auth/presentation/providers/auth_provider.dart';
import 'package:farm_vest/core/utils/app_enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/core/widgets/custom_textfield.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  DateTime? _selectedDate;
  String _selectedSession = 'Morning';

  final TextEditingController _dateController = TextEditingController();
  double getResponsiveFontSize(BuildContext context, double fontSize) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Base design width (you can adjust if needed)
    const baseWidth = 375.0;

    return fontSize * (screenWidth / baseWidth);
  }

  @override
  Widget build(BuildContext context) {
    final milkReportState = ref.watch(milkReportProvider);

    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F8),
        appBar: AppBar(
          backgroundColor: AppTheme.grey,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              ref.read(milkReportProvider.notifier).clear();
              if (context.canPop()) {
                context.pop();
              } else {
                final userRole = ref.read(authProvider).role;
                if (userRole == UserType.admin) {
                  context.go('/admin-dashboard');
                } else if (userRole == UserType.supervisor) {
                  context.go('/supervisor-dashboard');
                } else {
                  context.go('/farm-manager-dashboard');
                }
              }
            },
          ),
          title: const Text(
            "Farm Reports",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          bottom: TabBar(
            indicatorColor: Colors.green,
            indicatorWeight: 3,
            labelColor: Colors.green,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: "Daily"),
              Tab(text: "Weekly"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _datePickerField(context),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: _selectedSession,
                    decoration: _inputDecoration("Session"),
                    items: const [
                      DropdownMenuItem(
                        value: 'Morning',
                        child: Text('Morning'),
                      ),
                      DropdownMenuItem(
                        value: 'Evening',
                        child: Text('Evening'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedSession = value!;
                      });
                    },
                  ),

                  const SizedBox(height: 24),

                  _getReportButton(() {
                    if (_selectedDate == null) return;

                    final date =
                        "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}";

                    ref
                        .read(milkReportProvider.notifier)
                        .getDailyReport(
                          date: date,
                          timing: _selectedSession.toUpperCase(),
                        );
                  }),
                  const SizedBox(height: 16),

                  Consumer(
                    builder: (context, ref, _) {
                      final state = ref.watch(milkReportProvider);

                      if (state.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state.error != null) {
                        return Text(
                          state.error!,
                          style: const TextStyle(color: Colors.red),
                        );
                      }

                      if (state.data == null) return const SizedBox();

                      final reportList = state.data['data'];

                      if (reportList is! List || reportList.isEmpty) {
                        return const Text("No daily report found");
                      }

                      final report = reportList[0];
                      return _milkReportCard(
                        title: "Daily Milk Report",
                        timing: report['timing'],
                        entryDate: report['entry_date'] ?? "-",
                        quantity: "${report['quantity'] ?? '-'}",
                        titleColor: Colors.orange,
                        quantityColor: AppTheme.lightPrimary,
                      );
                    },
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _datePickerField(context),
                  const SizedBox(height: 24),
                  // _getReportButton(() {

                  // }),
                  _getReportButton(() {
                    if (_selectedDate == null) return;

                    final date =
                        "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}";

                    ref
                        .read(milkReportProvider.notifier)
                        .getWeeklyReport(date: date);
                  }),
                  const SizedBox(height: 16),
                  Consumer(
                    builder: (context, ref, _) {
                      final state = ref.watch(milkReportProvider);

                      if (state.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state.error != null) {
                        return Text(
                          state.error!,
                          style: const TextStyle(color: Colors.red),
                        );
                      }

                      if (state.data == null || state.data['data'] == null) {
                        return const SizedBox();
                      }

                      final report = state.data['data'];

                      if (report is List) {
                        return Column(
                          children: report.map<Widget>((item) {
                            return _milkReportCard(
                              title: "Weekly Milk Report",
                              entryDate: item['entry_date'] ?? "-",
                              quantity: "${item['quantity'] ?? '-'}",
                              titleColor: Colors.green,
                              quantityColor: Colors.green,
                            );
                          }).toList(),
                        );
                      }

                      return const SizedBox();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _datePickerField(BuildContext context) {
    return InkWell(
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: _selectedDate ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );

        if (pickedDate != null) {
          setState(() {
            _selectedDate = pickedDate;
            _dateController.text =
                "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
          });
        }
      },
      child: IgnorePointer(
        child: CustomTextField(
          controller: _dateController,
          hint: "Select Date",
          enabled: true,
          prefixIcon: const Icon(Icons.calendar_today, size: 18),
        ),
      ),
    );
  }

  Widget _getReportButton(VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onTap,
        child: const Text("Get Report", style: TextStyle(fontSize: 16)),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey),
      ),
    );
  }

  Widget _infoRow({
    required String label,
    required String value,
    Color valueColor = AppTheme.black,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.darkGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              color: valueColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _milkReportCard({
    required String title,
    String? timing,
    required String entryDate,
    required String quantity,
    Color titleColor = Colors.deepOrangeAccent,
    Color quantityColor = AppTheme.lightPrimary,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title badge
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: titleColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),

          Row(
            children: [
              if (timing != null && timing.isNotEmpty) ...[
                Expanded(
                  child: _infoBadge(
                    icon: Icons.schedule,
                    text: timing,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
              ],

              Expanded(
                child: _infoBadge(
                  icon: Icons.calendar_today,
                  text: entryDate,
                  color: Colors.purple,
                ),
              ),
              const SizedBox(width: 8),

              Expanded(
                child: _infoBadge(
                  icon: Icons.opacity,
                  text: "$quantity Litres",
                  color: quantityColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoBadge({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: getResponsiveFontSize(context, 12),
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    ref.read(milkReportProvider.notifier).clear();
    _dateController.dispose();
    super.dispose();
  }
}
