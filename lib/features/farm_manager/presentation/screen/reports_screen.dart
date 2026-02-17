import 'package:farm_vest/features/farm_manager/presentation/providers/staff_list_provider.dart';
import 'package:farm_vest/features/auth/presentation/providers/auth_provider.dart';
import 'package:farm_vest/core/utils/app_enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/core/widgets/custom_textfield.dart';
import 'package:farm_vest/core/localization/translation_helpers.dart';
class ReportsScreen extends ConsumerStatefulWidget {
  final bool hideAppBar;

  ReportsScreen({super.key, this.hideAppBar = false});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  DateTime? _selectedDate;
  String _selectedSession = 'Morning';
  bool get _isDateSelected => _selectedDate != null;

  final TextEditingController _dateController = TextEditingController();
  double getResponsiveFontSize(BuildContext context, double fontSize) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Base design width (you can adjust if needed)
    const baseWidth = 375.0;

    return fontSize * (screenWidth / baseWidth);
  }

  @override
  Widget build(BuildContext context) {
    // final milkReportState = ref.watch(milkReportProvider); // Removed redundant watch

    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: widget.hideAppBar
            ? null
            : AppBar(
                backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    // ref.read(milkReportProvider.notifier).clear(); // Handled by autoDispose
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
                title: Text(
                  "Farm Reports".tr(ref),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                bottom: TabBar(
                  indicatorColor: AppTheme.primary,
                  indicatorWeight: 3,
                  labelColor: AppTheme.primary,
                  unselectedLabelColor: Theme.of(context).hintColor,
                  tabs: [
                    Tab(text: "Daily".tr(ref)),
                    Tab(text: "Weekly".tr(ref)),
                  ],
                ),
              ),
        body: TabBarView(
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _datePickerField(context),
                  SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: _selectedSession,
                    decoration: _inputDecoration("Session".tr(ref)),
                    items: [
                      DropdownMenuItem(
                        value: 'Morning',
                        child: Text('Morning'.tr(ref)),
                      ),
                      DropdownMenuItem(
                        value: 'Evening',
                        child: Text('Evening'.tr(ref)),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedSession = value!;
                      });
                    },
                  ),

                  SizedBox(height: 24),

                  _getReportButton(
                    _isDateSelected
                        ? () {
                            final date =
                                "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}";

                            ref
                                .read(milkReportProvider.notifier)
                                .getDailyReport(
                                  date: date,
                                  timing: _selectedSession.toUpperCase(),
                                );
                          }
                        : null,
                  ),
                  SizedBox(height: 16),

                  Consumer(
                    builder: (context, ref, _) {
                      final state = ref.watch(milkReportProvider);

                      if (state.isLoading) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (state.error != null) {
                        return Text(
                          state.error!,
                          style: TextStyle(color: Colors.red),
                        );
                      }

                      if (state.data == null) return SizedBox();

                      final reportList = state.data['data'];

                      if (reportList is! List || reportList.isEmpty) {
                        return Text("No daily report found".tr(ref));
                      }

                      final report = reportList[0];
                      return _milkReportCard(
                        title: "Daily Milk Report".tr(ref),
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
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _datePickerField(context),
                  SizedBox(height: 24),
                  // _getReportButton(() {

                  // }),
                  _getReportButton(
                    _isDateSelected
                        ? () {
                            final date =
                                "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}";

                            ref
                                .read(milkReportProvider.notifier)
                                .getWeeklyReport(date: date);
                          }
                        : null,
                  ),
                  SizedBox(height: 16),
                  Consumer(
                    builder: (context, ref, _) {
                      final state = ref.watch(milkReportProvider);

                      if (state.isLoading) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (state.error != null) {
                        return Text(
                          state.error!,
                          style: TextStyle(color: Colors.red),
                        );
                      }

                      if (state.data == null || state.data['data'] == null) {
                        return SizedBox();
                      }

                      final report = state.data['data'];

                      if (report is List) {
                        return Column(
                          children: report.map<Widget>((item) {
                            return _milkReportCard(
                              title: "Weekly Milk Report".tr(ref),
                              entryDate: item['entry_date'] ?? "-",
                              quantity: "${item['quantity'] ?? '-'}",
                              titleColor: Colors.green,
                              quantityColor: Colors.green,
                            );
                          }).toList(),
                        );
                      }

                      return SizedBox();
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
          hint: "Select Date".tr(ref),
          enabled: true,
          prefixIcon: Icon(Icons.calendar_today, size: 18),
        ),
      ),
    );
  }

  Widget _getReportButton(VoidCallback? onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
            if (states.contains(MaterialState.disabled)) {
              return Colors.grey.shade400;
            }
            return Colors.green;
          }),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        child: Text("Get Report".tr(ref), style: TextStyle(fontSize: 16)),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Theme.of(context).cardColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white24
              : Colors.grey,
        ),
      ),
    );
  }

  Widget _infoRow({
    required String label,
    required String value,
    Color valueColor = AppTheme.black,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).hintColor,
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
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title badge
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: titleColor.withValues(alpha: 0.15),
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
          SizedBox(height: 16),
          Divider(),
          SizedBox(height: 12),

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
                SizedBox(width: 8),
              ],

              Expanded(
                child: _infoBadge(
                  icon: Icons.calendar_today,
                  text: entryDate,
                  color: Colors.purple,
                ),
              ),
              SizedBox(width: 8),

              Expanded(
                child: _infoBadge(
                  icon: Icons.opacity,
                  text: "$quantity ${'Litres'.tr(ref)}",
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
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Icon(icon, size: 16, color: color),
          SizedBox(width: 6),
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
    _dateController.dispose();
    super.dispose();
  }
}
