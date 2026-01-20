import 'package:farm_vest/core/theme/app_constants.dart';
import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/features/farm_manager/presentation/providers/farm_manager_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class FarmManagerDashboard extends ConsumerStatefulWidget {
  const FarmManagerDashboard({super.key});

  @override
  ConsumerState<FarmManagerDashboard> createState() => _FarmManagerDashboardState();
}

class _FarmManagerDashboardState extends ConsumerState<FarmManagerDashboard> {
  void _logout(BuildContext context) {
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(farmManagerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 10),
        child: AppBar(
          backgroundColor: AppTheme.grey,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Farm Manager",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.dark,
                ),
              ),
              SizedBox(height: 3),
              Text(
                "Kurnool Main Branch",
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.grey1,
                ),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: IconButton(
                icon: Icon(Icons.logout, color: AppTheme.darkGrey),
                onPressed: () {
                  _logout(context);
                },
              ),
            ),
          ],
        ),
      ),
      body: dashboardState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : dashboardState.error != null
              ? Center(child: Text('Error: ${dashboardState.error}'))
              : RefreshIndicator(
                  onRefresh: () async {
                    ref.read(farmManagerProvider.notifier).refreshDashboard();
                  },
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _mainStatCard(context, dashboardState.investorCount),
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: () => context.go('/staff-list'),
                          child: Stack(
                            children: [
                              Positioned(
                                top: 0,
                                left: 0,
                                bottom: 0,
                                right: 3,
                                child: Container(
                                  width: 10,
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                              ),
                              Container(
                                height: 90,
                                margin: const EdgeInsets.only(left: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 10,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  leading: const CircleAvatar(
                                    backgroundColor: Color(0xFFF2F2F2),
                                    child: Icon(Icons.people, color: AppTheme.lightSecondary),
                                  ),
                                  title: Text(
                                    dashboardState.totalStaff.toString(),
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E2A78),
                                    ),
                                  ),
                                  subtitle: const Text(
                                    "Total Staff",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                        _sectionHeader("Pending Approvals", count: dashboardState.pendingApprovals),
                        const SizedBox(height: 16),
                        _approvalTile(
                          context,
                          title: "Transfer Request",
                          subtitle: "Supervisor Raj",
                          onTap: () => _reviewDialog(
                            context,
                            id: "REQ-01",
                            type: "Transfer",
                            by: "Supervisor Raj",
                            details: "Buffalo #89 needs isolation",
                          ),
                          icon: Icons.sync_lock_sharp,
                        ),
                        _approvalTile(
                          context,
                          title: "Expense Request",
                          subtitle: "Admin Assistant",
                          onTap: () => _reviewDialog(
                            context,
                            id: "REQ-02",
                            type: "Expense",
                            by: "Admin Assistant",
                            details: "₹12,000 - Fodder purchase urgent",
                          ),
                          icon: Icons.account_balance_wallet,
                        ),
                        _approvalTile(
                            context,
                            title: "Leave Request",
                            subtitle: "Dr. Sharma",
                            onTap: () => _reviewDialog(
                                  context,
                                  id: "REQ-03",
                                  type: "Leave",
                                  by: "Dr. Sharma",
                                  details: "Sick Leave (2 Days)",
                                ),
                            icon: Icons.person_off_sharp),
                        const SizedBox(height: 28),
                        _sectionHeader("Management Console"),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _consoleItem(context, Icons.bar_chart, "Reports",
                                () => _reportsDialog(context)),
                            _consoleItem(context, Icons.people, "Staff",
                                () => context.go('/staff-list')),
                            _consoleItem(context, Icons.inventory, "Stock", () => _stockDialog(context)),
                            _consoleItem(context, Icons.add, "Onboard Buffalo", () {
                              context.go('/onboard-animal');
                            }),
                          ],
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton.icon(
          onPressed: () => _searchDialog(context),
          icon: const Icon(Icons.search),
          label: const Text("Find Animal & Location"),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.lightPrimary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ),
    );
  }

  Widget _mainStatCard(BuildContext context, int investorCount) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        context.go('/investor-details');
      },
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            right: 2,
            child: Container(
              width: 10,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          Container(
            height: 90,
            margin: const EdgeInsets.only(left: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppTheme.grey,
                child: const Icon(Icons.trending_up, color: AppTheme.lightSecondary),
              ),
              title: const Text(
                "Investors",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Color(0xFF1E2A78),
                ),
              ),
              subtitle: Text(
                "$investorCount Active Investors",
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, {int? count}) {
    return Row(
      children: [
        Text(title,
            style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        if (count != null) ...[
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 10,
            backgroundColor: Colors.red,
            child: Text("$count",
                style: const TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ],
      ],
    );
  }

  Widget _approvalTile(BuildContext context, {
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFF2F2F2),
          child: Icon(
            icon,
            color: AppTheme.lightSecondary,
          ),
        ),
        title:
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing:
            const Text("Review", style: TextStyle(color: Colors.green)),
        onTap: onTap,
      ),
    );
  }

  Widget _consoleItem(BuildContext context, IconData icon, String label,
      [VoidCallback? onTap]) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              // border: Border.all(color: AppTheme.lightPrimary),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: AppTheme.lightSecondary),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  void _baseDialog(BuildContext context,
      {required String title, required Widget child}) {
    showDialog(
      context: context,
      builder: (_) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600)),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _reviewDialog(BuildContext context,
      {required String id,
      required String type,
      required String by,
      required String details}) {
    _baseDialog(
      context,
      title: "Review Request",
      child: Column(
        children: [
          _infoRow("Request ID", id),
          _infoRow("Type", type),
          _infoRow("Requested By", by),
          _infoRow("Details", details),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Reject"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Approve"),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  void _searchDialog(BuildContext context) {
    _baseDialog(
      context,
      title: "Search Animal",
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search by ID, RFID or Investor",
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.search, color: Colors.white),
              )
            ],
          ),
        ],
      ),
    );
  }

  void _reportsDialog(BuildContext context) {
    _baseDialog(
      context,
      title: "Farm Reports",
      child: Column(
        children: const [
          ListTile(
            leading: Icon(Icons.description, color: Colors.green),
            title: Text("Daily Milk Report"),
            trailing: Icon(Icons.download),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.description, color: Colors.green),
            title: Text("Health Summary"),
            trailing: Icon(Icons.download),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.description, color: Colors.green),
            title: Text("Financial Audit"),
            trailing: Icon(Icons.download),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.description, color: Colors.green),
            title: Text("Staff Attendance"),
            trailing: Icon(Icons.download),
          ),
        ],
      ),
    );
  }

  void _staffDialog(BuildContext context) {
    _baseDialog(
      context,
      title: "Staff Directory",
      child: Column(
        children: [
          ListTile(
            leading: const CircleAvatar(child: Text("D")),
            title: const Text("Dr. Sharma"),
            subtitle: RichText(
              text: const TextSpan(children: [
                TextSpan(
                  text: "Veterinarian • ",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                TextSpan(
                  text: "On Duty",
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 14,
                  ),
                ),
              ]),
            ),
            trailing: const Icon(Icons.call, color: Colors.green),
          ),
          const Divider(),
          ListTile(
            leading: const CircleAvatar(child: Text("R")),
            title: const Text("Raj Kumar"),
            subtitle: RichText(
              text: const TextSpan(children: [
                TextSpan(
                  text: "Supervisor • ",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                TextSpan(
                  text: "On Duty",
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 14,
                  ),
                ),
              ]),
            ),
            trailing: const Icon(Icons.call, color: Colors.green),
          ),
          const Divider(),
          ListTile(
            leading: const CircleAvatar(child: Text("A")),
            title: const Text("Anita Singh"),
            subtitle: RichText(
              text: const TextSpan(children: [
                TextSpan(
                  text: "Admin • ",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                TextSpan(
                  text: "Leave",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                  ),
                ),
              ]),
            ),
            trailing: const Icon(Icons.call, color: Colors.green),
          ),
        ],
      ),
    );
  }

  void _stockDialog(BuildContext context) {
    _baseDialog(
      context,
      title: "Inventory Status",
      child: Column(
        children: [
          _stockRow("Cattle Feed (Kg)", "1200", "High", Colors.green),
          const Divider(),
          _stockRow("Mineral Mix", "45", "Medium", Colors.orange),
          const Divider(),
          _stockRow("Vaccines", "12", "Low", Colors.red),
          const Divider(),
          _stockRow("Straw Bales", "800", "High", Colors.green),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size.fromHeight(44)),
            onPressed: () {},
            child: const Text("Place New Order"),
          )
        ],
      ),
    );
  }

  void _settingsDialog(BuildContext context) {
    _baseDialog(
      context,
      title: "Settings",
      child: Column(
        children: const [
          SwitchListTile(
              value: true, onChanged: null, title: Text("Push Notifications")),
          Divider(),
          SwitchListTile(
              value: true, onChanged: null, title: Text("Email Alerts")),
          Divider(),
          SwitchListTile(value: false, onChanged: null, title: Text("Dark Mode")),
          Divider(),
          SwitchListTile(
              value: true, onChanged: null, title: Text("Biometric Login")),
        ],
      ),
    );
  }

  Widget _infoRow(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text("$k :")),
          Expanded(
              child: Text(v,
                  style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  Widget _stockRow(String name, String qty, String status, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name),
            Text("Available: $qty",
                style: const TextStyle(color: Colors.grey)),
          ]),
          Text(status,
              style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
