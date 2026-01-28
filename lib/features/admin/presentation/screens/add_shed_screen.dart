import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/core/widgets/primary_button.dart';
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

  // CCTV Controllers
  final _cctv1 = TextEditingController();
  final _cctv2 = TextEditingController();
  final _cctv3 = TextEditingController();
  final _cctv4 = TextEditingController();

  bool _showCctvFields = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(adminProvider.notifier).fetchFarms());
  }

  @override
  void dispose() {
    _shedNameController.dispose();
    _capacityController.dispose();
    _cctv1.dispose();
    _cctv2.dispose();
    _cctv3.dispose();
    _cctv4.dispose();
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
                    hint: 'e.g. Northeast Cluster A',
                    prefixIcon: const Icon(Icons.warehouse_rounded, size: 20),
                    validator: (v) =>
                        v?.isEmpty ?? true ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 20),
                  _buildLabel('Capacity (Standard 300)'),
                  CustomTextField(
                    controller: _capacityController,
                    readOnly: true,
                    keyboardType: TextInputType.number,
                    prefixIcon: const Icon(Icons.group_work_rounded, size: 20),
                    hint: '300',
                  ),
                ],
              ),

              const SizedBox(height: 24),

              _buildCctvSection(),

              const SizedBox(height: 40),

              if (adminState.error != null)
                _buildErrorWidget(adminState.error!),

              PrimaryButton(
                text: 'Initialize Shed',
                isLoading: adminState.isLoading,
                onPressed: _handleCreateShed,
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
    return DropdownButtonFormField<int>(
      value: _selectedFarmId,
      decoration: InputDecoration(
        hintText: 'Select a farm unit',
        prefixIcon: const Icon(
          Icons.agriculture_rounded,
          size: 22,
          color: AppTheme.primary,
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
        ),
        helperText: 'Select the primary location for this shed.',
        helperStyle: const TextStyle(fontSize: 11),
      ),
      items: state.farms
          .map(
            (f) => DropdownMenuItem(
              value: f['id'] as int,
              child: Text(
                f['farm_name'] as String,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: AppTheme.dark,
                ),
              ),
            ),
          )
          .toList(),
      onChanged: (v) => setState(() => _selectedFarmId = v),
      validator: (v) => v == null ? 'Required' : null,
    );
  }

  Widget _buildCctvSection() {
    return Container(
      decoration: BoxDecoration(
        color: _showCctvFields
            ? Colors.white
            : Colors.blueGrey[50]?.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _showCctvFields
              ? AppTheme.primary.withOpacity(0.2)
              : Colors.transparent,
        ),
      ),
      child: Column(
        children: [
          ListTile(
            onTap: () => setState(() => _showCctvFields = !_showCctvFields),
            leading: Icon(
              Icons.videocam_rounded,
              color: _showCctvFields ? AppTheme.primary : Colors.grey,
            ),
            title: const Text(
              'CCTV Configuration',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              _showCctvFields ? 'Hide angles' : 'Optional: Set corner cameras',
              style: const TextStyle(fontSize: 12),
            ),
            trailing: _showCctvFields
                ? TextButton.icon(
                    onPressed: _fillTestUrls,
                    icon: const Icon(Icons.auto_fix_high_rounded, size: 16),
                    label: const Text(
                      'Fill Test',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : Icon(Icons.expand_more, color: Colors.grey[300]),
          ),
          if (_showCctvFields)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                children: [
                  const Divider(),
                  const SizedBox(height: 12),
                  _buildAngleField(_cctv1, 'Angle 1 (Main Entrance)'),
                  const SizedBox(height: 16),
                  _buildAngleField(_cctv2, 'Angle 2 (Back Corner)'),
                  const SizedBox(height: 16),
                  _buildAngleField(_cctv3, 'Angle 3 (Left Wall)'),
                  const SizedBox(height: 16),
                  _buildAngleField(_cctv4, 'Angle 4 (Right Wall)'),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _fillTestUrls() {
    setState(() {
      _cctv1.text = 'http://161.97.182.208:8888/stream1/index.m3u8';
      _cctv2.text = 'http://161.97.182.208:8888/stream2/index.m3u8';
      _cctv3.text = 'http://161.97.182.208:8888/stream3/index.m3u8';
      _cctv4.text = 'http://161.97.182.208:8888/stream4/index.m3u8';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Test HLS URLs pre-filled.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _buildAngleField(TextEditingController controller, String label) {
    return CustomTextField(
      controller: controller,
      hint: 'rtsp://...',
      label: label,
      prefixIcon: const Icon(Icons.add_link_rounded, size: 18),
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
    if (_formKey.currentState!.validate() && _selectedFarmId != null) {
      final timestamp = DateTime.now().millisecondsSinceEpoch % 10000;
      final autoShedId = 'SHED-${_selectedFarmId}-$timestamp';

      final success = await ref
          .read(adminProvider.notifier)
          .createShed(
            farmId: _selectedFarmId!,
            shedId: autoShedId,
            shedName: _shedNameController.text.trim(),
            capacity: int.tryParse(_capacityController.text.trim()) ?? 300,
            cctvUrl: _cctv1.text.trim().isEmpty ? null : _cctv1.text.trim(),
            cctvUrl2: _cctv2.text.trim().isEmpty ? null : _cctv2.text.trim(),
            cctvUrl3: _cctv3.text.trim().isEmpty ? null : _cctv3.text.trim(),
            cctvUrl4: _cctv4.text.trim().isEmpty ? null : _cctv4.text.trim(),
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
