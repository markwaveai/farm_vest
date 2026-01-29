import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/core/utils/app_enums.dart';
import 'package:farm_vest/core/services/sheds_api_services.dart';
import 'package:farm_vest/core/widgets/farm_selector_input.dart';
import 'package:farm_vest/core/widgets/primary_button.dart';
import 'package:farm_vest/core/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/admin_provider.dart';

class AddStaffScreen extends ConsumerStatefulWidget {
  final bool isOnboardingManager;
  const AddStaffScreen({super.key, this.isOnboardingManager = false});

  @override
  ConsumerState<AddStaffScreen> createState() => _AddStaffScreenState();
}

class _AddStaffScreenState extends ConsumerState<AddStaffScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  UserType? _selectedRole;
  int? _selectedFarmId;
  int? _selectedShedId;
  bool _isTestAccount = false;
  List<Map<String, dynamic>> _sheds = [];

  Future<void> _fetchSheds(int farmId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token != null) {
      final sheds = await ShedsApiServices.getSheds(
        token: token,
        farmId: farmId,
      );
      if (mounted) {
        setState(() {
          _sheds = sheds;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.isOnboardingManager) {
      _selectedRole = UserType.farmManager;
    }
    Future.microtask(() => ref.read(adminProvider.notifier).fetchFarms());
  }

  // ... (rest of build method)

  // ... (rest of method)

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isOnboardingManager
              ? 'Onboard Farm Manager'
              : 'Add New Employee',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.dark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter the details of the new staff member below.',
                style: TextStyle(color: AppTheme.slate.withOpacity(0.7)),
              ),
              const SizedBox(height: 32),
              _buildLabel('Full Name'),
              CustomTextField(
                controller: _nameController,
                hint: 'e.g. John Doe',
                validator: (v) =>
                    v?.isEmpty ?? true ? 'Name is required' : null,
              ),
              const SizedBox(height: 20),
              _buildLabel('Email Address'),
              CustomTextField(
                controller: _emailController,
                hint: 'e.g. john@farmvest.com',
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                    v?.isEmpty ?? true ? 'Email is required' : null,
              ),
              const SizedBox(height: 20),
              _buildLabel('Phone Number'),
              CustomTextField(
                controller: _phoneController,
                hint: 'e.g. 9876543210',
                keyboardType: TextInputType.phone,
                validator: (v) =>
                    v?.isEmpty ?? true ? 'Phone is required' : null,
              ),
              const SizedBox(height: 20),
              if (!widget.isOnboardingManager) ...[
                _buildLabel('Assigned Role'),
                DropdownButtonFormField<UserType>(
                  value: _selectedRole,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.mediumGrey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.mediumGrey),
                    ),
                  ),
                  hint: const Text('Select Role'),
                  items:
                      [
                            UserType.farmManager,
                            UserType.supervisor,
                            UserType.doctor,
                            UserType.assistant,
                          ]
                          .map(
                            (r) => DropdownMenuItem(
                              value: r,
                              child: Text(r.label),
                            ),
                          )
                          .toList(),
                  onChanged: (v) => setState(() => _selectedRole = v),
                  validator: (v) => v == null ? 'Role is required' : null,
                ),
                const SizedBox(height: 20),
              ],
              _buildLabel('Assigned Farm'),
              FormField<int>(
                initialValue: _selectedFarmId,
                validator: (v) => _selectedFarmId == null
                    ? 'Farm selection is required'
                    : null,
                builder: (state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FarmSelectorInput(
                        selectedFarmId: _selectedFarmId,
                        onChanged: (v) {
                          setState(() {
                            _selectedFarmId = v;
                            _selectedShedId = null;
                            _sheds = [];
                          });
                          state.didChange(v);
                          if (v != null) _fetchSheds(v);
                        },
                        label: 'Select Farm',
                      ),
                      if (state.hasError)
                        Padding(
                          padding: const EdgeInsets.only(left: 12, top: 4),
                          child: Text(
                            state.errorText!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),

              if (_selectedRole == UserType.supervisor &&
                  _selectedFarmId != null) ...[
                _buildLabel('Assigned Shed'),
                DropdownButtonFormField<int>(
                  value: _selectedShedId,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.mediumGrey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.mediumGrey),
                    ),
                  ),
                  hint: const Text('Select Shed'),
                  items: _sheds.map<DropdownMenuItem<int>>((s) {
                    return DropdownMenuItem(
                      value: s['id'] as int,
                      child: Text('${s['shed_name']} (${s['shed_id']})'),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _selectedShedId = v),
                  validator: (v) => v == null
                      ? 'Shed assignment is required for Supervisors'
                      : null,
                ),
                const SizedBox(height: 20),
              ],

              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Is Test Employee'),
                value: _isTestAccount,
                onChanged: (val) =>
                    setState(() => _isTestAccount = val ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: AppTheme.primary,
              ),
              const SizedBox(height: 16),

              if (adminState.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    adminState.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              PrimaryButton(
                isLoading: adminState.isLoading,
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    final fullName = _nameController.text.trim();
                    final nameParts = fullName.split(' ');
                    final firstName = nameParts[0];
                    final lastName = nameParts.length > 1
                        ? nameParts.sublist(1).join(' ')
                        : '';

                    final success = await ref
                        .read(adminProvider.notifier)
                        .addStaff(
                          firstName: firstName,
                          lastName: lastName,
                          email: _emailController.text.trim(),
                          mobile: _phoneController.text.trim(),
                          roles: [_selectedRole!.backendValue],
                          farmId: _selectedFarmId!,
                          shedId: _selectedRole == UserType.supervisor
                              ? _selectedShedId
                              : null,
                          isTest: _isTestAccount,
                        );

                    if (success && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Staff member added successfully!'),
                        ),
                      );
                      Navigator.pop(context);
                    }
                  }
                },
                text: widget.isOnboardingManager
                    ? 'Finish Onboarding'
                    : 'Add Staff Member',
              ),
            ],
          ),
        ),
      ),
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
}
