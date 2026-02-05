import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/core/widgets/primary_button.dart';
import 'package:farm_vest/core/widgets/custom_textfield.dart';
import 'package:farm_vest/features/farm_manager/presentation/models/staff_model.dart';
import 'package:farm_vest/features/farm_manager/presentation/providers/staff_list_provider.dart';
import 'package:farm_vest/features/auth/presentation/providers/auth_provider.dart';
import 'package:farm_vest/core/utils/app_enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class StaffListScreen extends ConsumerStatefulWidget {
  const StaffListScreen({super.key});

  @override
  ConsumerState<StaffListScreen> createState() => _StaffListScreenState();
}

class _StaffListScreenState extends ConsumerState<StaffListScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Filter by Role'),
        children: [
          _buildFilterOption('All'),
          _buildFilterOption('Supervisor'),
          _buildFilterOption('Doctor'),
          _buildFilterOption('Assistant Doctor'),
          _buildFilterOption('Farm Manager'),
        ],
      ),
    );
  }

  Widget _buildFilterOption(String role) {
    return SimpleDialogOption(
      onPressed: () {
        ref.read(staffListProvider.notifier).setRoleFilter(role);
        Navigator.pop(context);
      },
      child: Text(role),
    );
  }

  void _showAddStaffBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddStaffBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final staffState = ref.watch(staffListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
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
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  hintText: 'Search Staff...',
                  hintStyle: TextStyle(color: Colors.black),
                  border: InputBorder.none,
                ),
                onChanged: (val) {
                  ref.read(staffListProvider.notifier).setSearchQuery(val);
                },
              )
            : const Text('Staff Directory'),
        backgroundColor: Colors.green,
        titleTextStyle: const TextStyle(
          fontSize: 22,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  ref.read(staffListProvider.notifier).setSearchQuery('');
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Active Staff'),
                  selected: staffState.isActiveFilter == true,
                  onSelected: (val) {
                    if (val) {
                      ref
                          .read(staffListProvider.notifier)
                          .setIsActiveFilter(true);
                    }
                  },
                  selectedColor: Colors.green.withOpacity(0.2),
                  checkmarkColor: Colors.green,
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Inactive Staff'),
                  selected: staffState.isActiveFilter == false,
                  onSelected: (val) {
                    if (val) {
                      ref
                          .read(staffListProvider.notifier)
                          .setIsActiveFilter(false);
                    }
                  },
                  selectedColor: Colors.red.withOpacity(0.2),
                  checkmarkColor: Colors.red,
                ),
              ],
            ),
          ),
          Expanded(
            child: staffState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : staffState.error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          staffState.error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                        TextButton(
                          onPressed: () =>
                              ref.read(staffListProvider.notifier).loadStaff(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : staffState.staff.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No staff members found',
                          style: TextStyle(color: AppTheme.slate, fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: staffState.staff.length,
                    separatorBuilder: (c, i) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final staffMember = staffState.staff[index];
                      return StaffCard(
                        staff: staffMember,
                        onTap: () => _showStaffDetailsDialog(staffMember),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddStaffBottomSheet,
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.person_add_alt_1, color: Colors.white),
      ),
    );
  }

  void _showStaffDetailsDialog(Staff staff) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: AppTheme.primary.withOpacity(0.1),
                child: Text(
                  staff.name?.substring(0, 1).toUpperCase() ?? '?',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                staff.name ?? 'Unknown',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                staff.role ?? 'No Role',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              _buildDetailRow(Icons.email, staff.email ?? 'N/A'),
              const SizedBox(height: 12),
              _buildDetailRow(Icons.phone, staff.phone ?? 'N/A'),
              const SizedBox(height: 12),
              _buildDetailRow(
                Icons.assignment_ind,
                'Status: ${staff.status ?? "Unknown"}',
              ),
              if (staff.assignedSheds.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildDetailRow(
                  Icons.warehouse,
                  'Sheds: ${staff.assignedSheds.join(", ")}',
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  text: 'Close',
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
      ],
    );
  }
}

class AddStaffBottomSheet extends ConsumerStatefulWidget {
  const AddStaffBottomSheet({super.key});

  @override
  ConsumerState<AddStaffBottomSheet> createState() =>
      _AddStaffBottomSheetState();
}

class _AddStaffBottomSheetState extends ConsumerState<AddStaffBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _selectedRole;
  int? _selectedShedId;
  int? _selectedDoctorId;
  int? _myFarmId;

  List<Map<String, dynamic>> _sheds = [];
  List<Map<String, dynamic>> _doctors = [];

  bool _isLoadingData = true;
  bool _isSubmitting = false;
  bool _isTestAccount = false;
  String? _localError;

  final List<String> _allowedRoles = [
    'Supervisor',
    'Doctor',
    'Assistant Doctor',
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final notifier = ref.read(staffListProvider.notifier);
    final farmId = await notifier.fetchMyFarmId();
    if (mounted) {
      setState(() {
        _myFarmId = farmId;
        _isLoadingData = false;
      });
    }
  }

  Future<void> _onRoleChanged(String? role) async {
    setState(() {
      _selectedRole = role;
      _selectedShedId = null;
      _selectedDoctorId = null;
      _localError = null;
    });

    if (role == 'Supervisor' || role == 'Assistant Doctor') {
      final sheds = await ref.read(staffListProvider.notifier).fetchMySheds();
      if (mounted) setState(() => _sheds = sheds);
    }

    if (role == 'Assistant Doctor') {
      final doctors = await ref.read(staffListProvider.notifier).fetchDoctors();
      if (mounted) setState(() => _doctors = doctors);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: _isLoadingData
          ? const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            )
          : _myFarmId == null
          ? const SizedBox(
              height: 100,
              child: Center(
                child: Text("Error: No Farm ID found. Please contact support."),
              ),
            )
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Add New Staff",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.dark,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Onboard a new staff member for your farm.',
                      style: TextStyle(color: AppTheme.slate.withOpacity(0.7)),
                    ),
                    const SizedBox(height: 24),
                    if (_localError != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.red.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          _localError!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    _buildLabel('Full Name (First and Last)'),
                    CustomTextField(
                      controller: _nameController,
                      hint: 'e.g. John Doe',
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Name is required';
                        if (!v.trim().contains(' '))
                          return 'Please enter both first and last name';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildLabel('Email Address'),
                    CustomTextField(
                      controller: _emailController,
                      hint: 'e.g. john@farmvest.com',
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) =>
                          v?.isEmpty ?? true ? 'Email is required' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildLabel('Phone Number'),
                    CustomTextField(
                      controller: _phoneController,
                      hint: 'e.g. 9876543210',
                      keyboardType: TextInputType.phone,
                      validator: (v) =>
                          v?.isEmpty ?? true ? 'Phone is required' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildLabel('Assigned Role'),
                    DropdownButtonFormField<String>(
                      value: _selectedRole,
                      decoration: _dropdownDecoration('Select Role'),
                      items: _allowedRoles
                          .map(
                            (r) => DropdownMenuItem(value: r, child: Text(r)),
                          )
                          .toList(),
                      onChanged: _onRoleChanged,
                      validator: (v) => v == null ? 'Role is required' : null,
                    ),
                    const SizedBox(height: 16),
                    if (_selectedRole == 'Supervisor' ||
                        _selectedRole == 'Assistant Doctor') ...[
                      _buildLabel(
                        _selectedRole == 'Assistant Doctor'
                            ? 'Assigned Shed (Optional)'
                            : 'Assigned Shed',
                      ),
                      DropdownButtonFormField<int>(
                        value: _selectedShedId,
                        decoration: _dropdownDecoration('Select Shed'),
                        items: _sheds
                            .map(
                              (s) => DropdownMenuItem(
                                value: s['id'] as int,
                                child: Text('${s['shed_name']} (${s['id']})'),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _selectedShedId = v),
                        validator: (v) =>
                            (_selectedRole == 'Supervisor' && v == null)
                            ? 'Shed is required for Supervisors'
                            : null,
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (_selectedRole == 'Assistant Doctor') ...[
                      _buildLabel('Senior Doctor'),
                      DropdownButtonFormField<int>(
                        value: _selectedDoctorId,
                        decoration: _dropdownDecoration('Select Doctor'),
                        items: _doctors.map((d) {
                          final firstName = d['first_name'] ?? '';
                          final lastName = d['last_name'] ?? '';
                          final fullName =
                              (firstName.isEmpty && lastName.isEmpty)
                              ? (d['name'] ?? 'Unknown Doctor')
                              : '$firstName $lastName'.trim();
                          return DropdownMenuItem(
                            value: d['id'] as int,
                            child: Text(fullName),
                          );
                        }).toList(),
                        onChanged: (v) => setState(() => _selectedDoctorId = v),
                        validator: (v) =>
                            v == null ? 'Senior Doctor is required' : null,
                      ),
                      const SizedBox(height: 16),
                    ],
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Is Test Employee'),
                      value: _isTestAccount,
                      onChanged: (val) =>
                          setState(() => _isTestAccount = val ?? false),
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: Colors.green,
                    ),
                    const SizedBox(height: 8),
                    PrimaryButton(
                      isLoading: _isSubmitting,
                      onPressed: _submitForm,
                      text: 'Add Staff Member',
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }

  InputDecoration _dropdownDecoration(String hint) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.mediumGrey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.mediumGrey),
      ),
      hintText: hint,
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppTheme.slate,
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_myFarmId == null) return;

      setState(() {
        _isSubmitting = true;
        _localError = null;
      });

      final fullName = _nameController.text.trim();
      final nameParts = fullName.split(' ');
      final firstName = nameParts[0];
      final lastName = nameParts.length > 1
          ? nameParts.sublist(1).join(' ')
          : '';

      final success = await ref
          .read(staffListProvider.notifier)
          .addStaff(
            firstName: firstName,
            lastName: lastName,
            email: _emailController.text.trim(),
            mobile: _phoneController.text.trim(),
            role: _selectedRole!,
            farmId: _myFarmId!,
            shedId: _selectedShedId,
            seniorDoctorId: _selectedDoctorId,
            isTest: _isTestAccount,
          );

      if (mounted) {
        setState(() => _isSubmitting = false);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Staff member added successfully!')),
          );
          Navigator.pop(context);
        } else {
          // Error description is stored in provider state
          final error = ref.read(staffListProvider).error;
          setState(() => _localError = error ?? 'Failed to add staff member');
        }
      }
    }
  }
}

class StaffCard extends ConsumerWidget {
  final Staff staff;
  final VoidCallback? onTap;

  const StaffCard({super.key, required this.staff, this.onTap});

  Color _getRoleColor(String? role) {
    switch (role?.toUpperCase()) {
      case 'SUPERVISOR':
        return Colors.green;
      case 'DOCTOR':
        return Colors.blue;
      case 'ASSISTANT DOCTOR':
        return Colors.indigo;
      case 'FARM MANAGER':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roleColor = _getRoleColor(staff.role);
    final isActive = staff.status != 'Inactive';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isActive
            ? null
            : Border.all(color: Colors.red.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Stack(
                  children: [
                    Hero(
                      tag: 'staff-${staff.role}-${staff.id}',
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: isActive
                                ? [roleColor, roleColor.withOpacity(0.7)]
                                : [Colors.grey, Colors.grey.shade400],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          (staff.name?.isNotEmpty ?? false)
                              ? staff.name!.substring(0, 1).toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    if (staff.status == 'On Duty')
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        staff.name ?? 'Unknown Staff',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          decoration: isActive
                              ? null
                              : TextDecoration.lineThrough,
                          color: isActive ? Colors.black : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: roleColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              staff.role ?? 'No Role',
                              style: TextStyle(
                                fontSize: 11,
                                color: roleColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (staff.assignedFarms.isNotEmpty ||
                          staff.assignedSheds.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            ...staff.assignedFarms.map(
                              (f) => _buildMiniTag(
                                Icons.agriculture_rounded,
                                f,
                                Colors.orange,
                              ),
                            ),
                            ...staff.assignedSheds.map(
                              (s) => _buildMiniTag(
                                Icons.warehouse_rounded,
                                s,
                                Colors.blueGrey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'toggle_status') {
                      final success = await ref
                          .read(staffListProvider.notifier)
                          .toggleEmployeeStatus(
                            mobile: staff.phone!,
                            isActive: !isActive,
                          );
                      if (success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Status updated successfully'),
                          ),
                        );
                      }
                    } else if (value == 'call') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Calling ${staff.name}...')),
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'call',
                      child: Row(
                        children: [
                          Icon(Icons.call, size: 20),
                          SizedBox(width: 8),
                          Text('Call Staff'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'toggle_status',
                      child: Row(
                        children: [
                          Icon(
                            isActive ? Icons.person_off : Icons.person_add,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(isActive ? 'Deactivate' : 'Activate'),
                        ],
                      ),
                    ),
                  ],
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.more_vert,
                      color: Colors.grey,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniTag(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
