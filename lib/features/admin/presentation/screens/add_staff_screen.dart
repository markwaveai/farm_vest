import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/core/utils/app_enums.dart';
import 'package:farm_vest/core/services/sheds_api_services.dart';
import 'package:farm_vest/core/widgets/farm_selector_input.dart';
import 'package:farm_vest/core/widgets/primary_button.dart';
import 'package:farm_vest/core/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/admin_provider.dart';
import 'package:farm_vest/features/auth/presentation/providers/auth_provider.dart';

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
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    if (widget.isOnboardingManager) {
      _selectedRole = UserType.farmManager;
    }

    _nameController.addListener(_validateForm);
    _emailController.addListener(_validateForm);
    _phoneController.addListener(_validateForm);

    Future.microtask(() {
      final auth = ref.read(authProvider);
      final roleStr = auth.userData?.role;
      debugPrint("AddStaffScreen: User Role: $roleStr");
      final role = roleStr != null ? UserType.fromString(roleStr) : null;

      if (role == UserType.farmManager) {
        final fId = int.tryParse(auth.userData?.farmId ?? '');
        debugPrint("AddStaffScreen: FM Farm ID: $fId");
        if (mounted) {
          setState(() {
            _selectedFarmId = fId;
          });
        }
        _fetchSheds(fId);
      } else {
        ref.read(adminProvider.notifier).fetchFarms();
      }
    });
  }

  Future<void> _fetchSheds(int? farmId) async {
    debugPrint("AddStaffScreen: Fetching sheds for farm $farmId");
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token != null) {
      final sheds = await ShedsApiServices.getSheds(
        token: token,
        farmId: farmId,
      );
      debugPrint("AddStaffScreen: Found ${sheds.length} sheds");
      if (mounted) {
        setState(() {
          _sheds = sheds;
        });
      }
    }
  }

  void _validateForm() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();

    // Basic validity check (fields are not empty and meet basic criteria)
    final bool isValid =
        name.isNotEmpty &&
        email.isNotEmpty &&
        phone.length == 10 &&
        _selectedRole != null &&
        _selectedFarmId != null &&
        // For supervisors, shed must be selected
        (_selectedRole != UserType.supervisor || _selectedShedId != null);

    if (isValid != _isFormValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
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
    final currentUserRole = ref.watch(authProvider).userData?.role;
    final isFM =
        currentUserRole != null &&
        UserType.fromString(currentUserRole) == UserType.farmManager;

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
              _buildLabel('Full Name', isRequired: true),
              CustomTextField(
                controller: _nameController,
                hint: 'e.g. John Doe',
                autovalidateMode: AutovalidateMode.onUserInteraction,
                inputFormatters: [
                  // Only allow letters and spaces
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                ],
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Full name is required';
                  }

                  final trimmedName = v.trim();

                  // Check if name contains only letters and spaces
                  final nameRegex = RegExp(r'^[a-zA-Z\s]+$');
                  if (!nameRegex.hasMatch(trimmedName)) {
                    return 'Name should only contain letters and spaces';
                  }

                  // Check if name has at least 2 characters
                  if (trimmedName.length < 2) {
                    return 'Name must be at least 2 characters long';
                  }

                  // Check if name doesn't start or end with space
                  if (trimmedName.startsWith(' ') ||
                      trimmedName.endsWith(' ')) {
                    return 'Name should not start or end with spaces';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildLabel('Email Address', isRequired: true),
              CustomTextField(
                controller: _emailController,
                hint: 'e.g. john@farmvest.com',
                keyboardType: TextInputType.emailAddress,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r'\s')), // No spaces
                  _EmailComFormatter(),
                ],
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Email is required';
                  }

                  final trimmedEmail = v.trim().toLowerCase();

                  // Comprehensive email validation
                  final emailRegex = RegExp(
                    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                  );

                  if (!emailRegex.hasMatch(trimmedEmail)) {
                    return 'Please enter a valid email address';
                  }

                  // Check for consecutive dots
                  if (trimmedEmail.contains('..')) {
                    return 'Email cannot contain consecutive dots';
                  }

                  // Check if email starts or ends with dot
                  if (trimmedEmail.startsWith('.') ||
                      trimmedEmail.endsWith('.')) {
                    return 'Email cannot start or end with a dot';
                  }

                  // Check domain part
                  final parts = trimmedEmail.split('@');
                  if (parts.length != 2) {
                    return 'Email must contain exactly one @ symbol';
                  }

                  if (parts[0].isEmpty) {
                    return 'Email must have a username before @';
                  }

                  if (parts[1].isEmpty || !parts[1].contains('.')) {
                    return 'Email must have a valid domain';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildLabel('Phone Number', isRequired: true),
              CustomTextField(
                controller: _phoneController,
                hint: 'e.g. 9876543210',
                keyboardType: TextInputType.phone,
                maxLength: 10,
                showCounter: false,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Phone number is required';
                  }
                  final phoneRegex = RegExp(r'^\d{10}$');
                  if (!phoneRegex.hasMatch(v.trim())) {
                    return 'Please enter a valid 10-digit phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              if (!widget.isOnboardingManager) ...[
                _buildLabel('Assigned Role', isRequired: true),
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
                            if (!isFM) UserType.farmManager,
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
                  onChanged: (v) {
                    setState(() => _selectedRole = v);
                    _validateForm();
                  },
                  validator: (v) => v == null ? 'Role is required' : null,
                ),
                const SizedBox(height: 20),
              ],
              if (!isFM) ...[
                _buildLabel('Assigned Farm', isRequired: true),
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
                            _validateForm();
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
              ],

              if (_selectedRole == UserType.supervisor &&
                  _selectedFarmId != null) ...[
                _buildLabel('Assigned Shed', isRequired: true),
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
                      child: Text('${s['shed_name']} (${s['sheds.id']})'),
                    );
                  }).toList(),
                  onChanged: (v) {
                    setState(() => _selectedShedId = v);
                    _validateForm();
                  },
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
                onPressed: _isFormValid
                    ? () async {
                        if (_formKey.currentState?.validate() ?? false) {
                          final fullName = _nameController.text.trim();
                          final nameParts = fullName.split(' ');
                          final firstName = nameParts[0];
                          final lastName = nameParts.length > 1
                              ? nameParts.sublist(1).join(' ')
                              : '';

                          debugPrint("=== ADD STAFF FORM DATA ===");
                          debugPrint("First Name: $firstName");
                          debugPrint("Last Name: $lastName");
                          debugPrint("Email: ${_emailController.text.trim()}");
                          debugPrint("Mobile: ${_phoneController.text.trim()}");
                          debugPrint("Selected Role: $_selectedRole");
                          debugPrint(
                            "Role Backend Value: ${_selectedRole?.backendValue}",
                          );
                          debugPrint("Farm ID: $_selectedFarmId");
                          debugPrint("Shed ID: $_selectedShedId");
                          debugPrint("Is Test: $_isTestAccount");

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
                                content: Text(
                                  'Staff member added successfully!',
                                ),
                                backgroundColor: AppTheme.successGreen,
                              ),
                            );
                            Navigator.pop(context);
                          } else if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  ref.read(adminProvider).error ??
                                      'Failed to add staff',
                                ),
                                backgroundColor: AppTheme.errorRed,
                              ),
                            );
                          }
                        }
                      }
                    : null,
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

  Widget _buildLabel(String text, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text.rich(
        TextSpan(
          text: text,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppTheme.slate,
          ),
          children: [
            if (isRequired)
              const TextSpan(
                text: ' *',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EmailComFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    final comIndex = text.toLowerCase().indexOf('.com');

    if (comIndex != -1) {
      // If .com exists, truncate anything after it (com is 4 chars)
      final restrictedText = text.substring(0, comIndex + 4);
      if (restrictedText.length < text.length) {
        return TextEditingValue(
          text: restrictedText,
          selection: TextSelection.collapsed(offset: comIndex + 4),
        );
      }
    }
    return newValue;
  }
}
