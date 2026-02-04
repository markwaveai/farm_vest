import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/core/widgets/farm_selector_input.dart';
import '../../../../core/widgets/primary_button.dart';
import 'package:farm_vest/core/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/admin_provider.dart';

class AddShedScreen extends ConsumerStatefulWidget {
  const AddShedScreen({super.key});

  @override
  ConsumerState<AddShedScreen> createState() => _AddShedScreenState();
}

class _AddShedScreenState extends ConsumerState<AddShedScreen> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedFarmId;
  final _shedNameController = TextEditingController();
  final _capacityController = TextEditingController(text: '300');
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _shedNameController.addListener(_updateFormValidity);
    Future.microtask(() => ref.read(adminProvider.notifier).fetchFarms());
  }

  void _updateFormValidity() {
    final isValid =
        _selectedFarmId != null && _shedNameController.text.trim().isNotEmpty;
    if (isValid != _isFormValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  @override
  void dispose() {
    _shedNameController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'New Shed Configuration',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppTheme.dark,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 32),

              _buildSectionCard(
                title: 'Basic Information',
                icon: Icons.info_outline_rounded,
                children: [
                  _buildLabel('Target Farm'),
                  _buildFarmDropdown(adminState),
                  const SizedBox(height: 20),
                  _buildLabel('Shed Name / Designation'),
                  CustomTextField(
                    controller: _shedNameController,
                    hint: 'e.g. Kurnool shed A',
                    prefixIcon: const Icon(Icons.warehouse_rounded, size: 20),
                    validator: (v) =>
                        v?.isEmpty ?? true ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 20),
                  _buildLabel('Capacity'),
                  CustomTextField(
                    controller: _capacityController,
                    enabled: true,
                    keyboardType: TextInputType.number,
                    prefixIcon: const Icon(Icons.group_work_rounded, size: 20),
                    hint: '300',
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // CCTV section removed as per request
              if (adminState.error != null)
                _buildErrorWidget(adminState.error!),

              PrimaryButton(
                text: 'Initialize Shed',
                isLoading: adminState.isLoading,
                onPressed: _isFormValid ? _handleCreateShed : null,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Infrastructure Setup',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppTheme.dark,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Configure a new containment unit for livestock.',
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppTheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppTheme.dark,
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          ...children,
        ],
      ),
    );
  }

  Widget _buildFarmDropdown(AdminState state) {
    return FarmSelectorInput(
      selectedFarmId: _selectedFarmId,
      onChanged: (id) {
        setState(() {
          _selectedFarmId = id;
        });
        _updateFormValidity();
      },
    );
  }

  Widget _buildErrorWidget(String error) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(color: Colors.red, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCreateShed() async {
    if (_formKey.currentState!.validate()) {
      final timestamp = DateTime.now().millisecondsSinceEpoch % 10000;
      final autoShedId = 'SHED-${_selectedFarmId}-$timestamp';

      final success = await ref
          .read(adminProvider.notifier)
          .createShed(
            farmId: _selectedFarmId!,
            shedId: autoShedId,
            shedName: _shedNameController.text.trim(),
            capacity: int.tryParse(_capacityController.text.trim()) ?? 300,
          );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Shed infrastructure initialized successfully'),
            backgroundColor: AppTheme.successGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppTheme.dark,
          fontSize: 13,
        ),
      ),
    );
  }
}
