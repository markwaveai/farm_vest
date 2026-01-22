import 'package:farm_vest/features/farm_manager/presentation/models/staff_model.dart';
import 'package:farm_vest/features/farm_manager/presentation/providers/staff_list_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class StaffListScreen extends ConsumerWidget {
  const StaffListScreen({super.key});

  // 1. Method updated to use a BottomSheet instead of a Dialog
  void _showAddStaffBottomSheet(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final roleController = TextEditingController();
    final designationController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Important for keyboard handling
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Add New Staff Member",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Name"),
                  validator: (value) =>
                      value!.isEmpty ? "Please enter a name" : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: roleController,
                  decoration: const InputDecoration(
                    labelText: "Role (e.g., Supervisor)",
                  ),
                  validator: (value) =>
                      value!.isEmpty ? "Please enter a role" : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: designationController,
                  decoration: const InputDecoration(labelText: "Designation"),
                  validator: (value) =>
                      value!.isEmpty ? "Please enter a designation" : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: "Phone Number"),
                  keyboardType: TextInputType.phone,
                  validator: (value) =>
                      value!.isEmpty ? "Please enter a phone number" : null,
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: "Email Address"),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            //final newStaff = Staff(
                            //   name: nameController.text,
                            //   role: roleController.text,
                            //   designation: designationController.text,
                            //   phone: phoneController.text,
                            //   email: emailController.text,
                            //   status: 'On Duty',
                            // );

                            // final newStaff = Staff(
                            //   name: nameController.text,
                            //   role: roleController.text,
                            //   designation: designationController.text,
                            //   phone: phoneController.text,
                            //   status: 'On Duty', // Default status
                            // );
                            //ref.read(staffListProvider.notifier).addStaff(newStaff);
                            Navigator.of(context).pop();
                          }
                        },
                        child: const Text('Add Staff'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staffState = ref.watch(staffListProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go('/farm-manager-dashboard'),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text('Staff Directory'),
        backgroundColor: Colors.green,
        titleTextStyle: const TextStyle(
          fontSize: 22,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: staffState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : staffState.error != null
          ? Center(child: Text(staffState.error!))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: staffState.staff.length,
              itemBuilder: (context, index) {
                final staffMember = staffState.staff[index];
                return StaffCard(staff: staffMember);
              },
            ),

      // body: staffState.isLoading
      //     ? const Center(child: CircularProgressIndicator())
      //     : ListView.builder(
      //         padding: const EdgeInsets.all(16),
      //         itemCount: staffState.staff.length,
      //         itemBuilder: (context, index) {
      //           final staffMember = staffState.staff[index];
      //           return StaffCard(staff: staffMember);
      //         },
      //       ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddStaffBottomSheet(context, ref),
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class StaffCard extends StatelessWidget {
  final Staff staff;

  const StaffCard({super.key, required this.staff});

  void _showStaffDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(staff.name ?? 'Unknown Staff'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              staff.role ?? 'No Designation',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24),
            _buildDetailRow(Icons.work, "Role", staff.role),
            _buildDetailRow(Icons.phone, "mobile", staff.phone),
            _buildDetailRow(Icons.email, "Email", staff.email),
            if (staff.seniorDoctorName != null)
              _buildDetailRow(
                Icons.person_outline,
                "Senior Doctor",
                staff.seniorDoctorName,
              ),
            if (staff.seniorDoctorPhone != null)
              _buildDetailRow(
                Icons.phone_android,
                "Senior Doctor Phone",
                staff.seniorDoctorPhone,
              ),
            _buildDetailRow(
              staff.status == 'On Duty' ? Icons.check_circle : Icons.cancel,
              "Status",
              staff.status,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value ?? 'N/A', textAlign: TextAlign.end)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: () => _showStaffDetailsDialog(context),
        leading: CircleAvatar(
          backgroundColor: Colors.green.withOpacity(0.1),
          child: Text(
            (staff.name?.isNotEmpty ?? false)
                ? staff.name!.substring(0, 1)
                : '?',
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          staff.name ?? 'Unknown Staff',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(staff.role ?? 'No Role Assigned'),
            if (staff.seniorDoctorName != null)
              Text(
                'Senior: ${staff.seniorDoctorName}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.call_outlined, color: Colors.green),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Calling ${staff.name ?? 'staff'}...')),
            );
          },
        ),
      ),
    );
  }
}
