import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/admin_provider.dart';

class AddFarmScreen extends ConsumerStatefulWidget {
  const AddFarmScreen({super.key});

  @override
  ConsumerState<AddFarmScreen> createState() => _AddFarmScreenState();
}

class _AddFarmScreenState extends ConsumerState<AddFarmScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedLocation = 'KURNOOL';
  bool _isTestAccount = false;
  bool _isFormValid = false;

  final List<String> _locations = ['KURNOOL', 'HYDERABAD'];

  @override
  void initState() {
    super.initState();
    // Listen to name changes to update button state
    _nameController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _nameController.removeListener(_validateForm);
    _nameController.dispose();
    super.dispose();
  }

  void _validateForm() {
    final farmName = _nameController.text.trim();
    final isValid = farmName.isNotEmpty && farmName.length >= 3;

    if (isValid != _isFormValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Add New Farm')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Farm Details',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.dark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter the details of the new farm being onboarded.',
                style: TextStyle(color: AppTheme.slate.withOpacity(0.7)),
              ),
              const SizedBox(height: 32),

              _buildLabel('Farm Name', isRequired: true),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'e.g. Green Valley Farm',
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Farm name is required';
                  }
                  if (v.trim().length < 3) {
                    return 'Farm name must be at least 3 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              _buildLabel('Location', isRequired: true),
              DropdownButtonFormField<String>(
                value: _selectedLocation,
                items: _locations
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedLocation = v!),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Is Test Farm'),
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
                text: 'Create Farm',
                isLoading: adminState.isLoading,
                onPressed: _isFormValid
                    ? () async {
                        if (_formKey.currentState!.validate()) {
                          final success = await ref
                              .read(adminProvider.notifier)
                              .createFarm(
                                name: _nameController.text.trim(),
                                location: _selectedLocation,
                                isTest: _isTestAccount,
                              );
                          if (success && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Farm created successfully'),
                                backgroundColor: AppTheme.successGreen,
                              ),
                            );
                            Navigator.pop(context);
                          }
                        }
                      }
                    : null, // Disabled when form is invalid
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text.rich(
        TextSpan(
          text: label,
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
