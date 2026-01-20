import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:farm_vest/core/widgets/custom_button.dart';
import 'package:farm_vest/core/widgets/custom_dialog.dart';
import 'package:farm_vest/core/widgets/custom_textfield.dart';
import 'package:farm_vest/features/farm_manager/presentation/providers/farm_manager_provider.dart';
import 'package:flutter/material.dart';
import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/farm_manager_dashboard_model.dart';

class OnboardAnimalScreen extends ConsumerStatefulWidget {
  const OnboardAnimalScreen({super.key});

  @override
  ConsumerState<OnboardAnimalScreen> createState() => _OnboardAnimalScreenState();
}

class _OnboardAnimalScreenState extends ConsumerState<OnboardAnimalScreen> {
  // Controllers for all form fields
  late final TextEditingController shedController;
  late final TextEditingController rowController;
  late final TextEditingController dobController;
  late final TextEditingController animalCartIdController;
  late final TextEditingController healthStatusController;
  late final TextEditingController investorIdController;
  late final TextEditingController positionIdController;
  late final TextEditingController rfidTagController;
  late final TextEditingController statusController;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    shedController = TextEditingController(text: '1');
    rowController = TextEditingController(text: 'R4');
    dobController = TextEditingController(text: '2022-06-15');
    animalCartIdController = TextEditingController(text: '107');
    healthStatusController = TextEditingController(text: 'Healthy');
    investorIdController = TextEditingController(text: '1');
    positionIdController = TextEditingController(text: 'B1');
    rfidTagController = TextEditingController(text: 'RFID-123450');
    statusController = TextEditingController(text: 'high_yield');
  }

  @override
  void dispose() {
    shedController.dispose();
    rowController.dispose();
    dobController.dispose();
    animalCartIdController.dispose();
    healthStatusController.dispose();
    investorIdController.dispose();
    positionIdController.dispose();
    rfidTagController.dispose();
    statusController.dispose();
    super.dispose();
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return CustomDialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Image Source',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Divider(color: AppTheme.grey1.withAlpha(128)),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () async {
                  Navigator.pop(context);
                  await ref.read(farmManagerProvider.notifier).pickFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  await ref.read(farmManagerProvider.notifier).pickFromGallery();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final success = await ref.read(farmManagerProvider.notifier).onboardAnimal(
            shedId: shedController.text,
            rowId: rowController.text,
            dob: dobController.text,
            animalCartId: animalCartIdController.text,
            healthStatus: healthStatusController.text,
            investorId: investorIdController.text,
            positionId: positionIdController.text,
            rfidTag: rfidTagController.text,
            status: statusController.text,
          );

      if (!mounted) return;

      if (success) {
        context.go('/farm-manager');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Animal onboarded successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to onboard animal. Please check the fields and try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(farmManagerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Onboard Animal'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _helperTextField(
              helperText: 'Shed ID',
              field: CustomTextField(
                hint: 'Enter Shed ID (e.g., SHED-1)',
                controller: shedController,
              ),
            ),
            const SizedBox(height: 16),
            _helperTextField(
              helperText: 'Row ID',
              field: CustomTextField(
                hint: 'Enter Row ID (e.g., ROW_2)',
                controller: rowController,
              ),
            ),
            const SizedBox(height: 16),
            _helperTextField(
              helperText: 'Date of Birth (YYYY-MM-DD)',
              field: CustomTextField(
                hint: 'Enter DOB',
                controller: dobController,
              ),
            ),
            const SizedBox(height: 16),
            _helperTextField(
              helperText: 'Animal Cart ID',
              field: CustomTextField(
                hint: 'Enter Animal Cart ID',
                controller: animalCartIdController,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(height: 16),
            _helperTextField(
              helperText: 'Health Status',
              field: CustomTextField(
                hint: 'e.g., Healthy',
                controller: healthStatusController,
              ),
            ),
            const SizedBox(height: 16),
            _helperTextField(
              helperText: 'Investor ID',
              field: CustomTextField(
                hint: 'Enter Investor ID',
                controller: investorIdController,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(height: 16),
            _helperTextField(
              helperText: 'Position ID',
              field: CustomTextField(
                hint: 'e.g., A1',
                controller: positionIdController,
              ),
            ),
            const SizedBox(height: 16),
            _helperTextField(
              helperText: 'RFID Tag Number',
              field: CustomTextField(
                hint: 'Enter RFID Tag',
                controller: rfidTagController,
              ),
            ),
            const SizedBox(height: 16),
            _helperTextField(
              helperText: 'Status',
              field: CustomTextField(
                hint: 'e.g., high_yield',
                controller: statusController,
              ),
            ),
            const SizedBox(height: 16),
            DottedBorder(
              radius: const Radius.circular(10),
              color: AppTheme.lightPrimary,
              dashPattern: const [6, 4],
              strokeWidth: 1,
              child: InkWell(
                onTap: _showImageSourceDialog,
                child: SizedBox(
                  height: 60,
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.upload_file,
                          color: AppTheme.lightPrimary,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Upload Buffalo Image',
                          style: TextStyle(
                            color: AppTheme.lightPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (dashboardState.images.isNotEmpty)
              SizedBox(
                height: 110,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                  ),
                  itemCount: dashboardState.images.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final image = dashboardState.images[index];

                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: _buildImage(image),
                        ),
                        if (image.isUploading)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.black26,
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        if (image.hasError)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.black26,
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.error,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () {
                              ref.read(farmManagerProvider.notifier).removeImageAt(index);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            const SizedBox(height: 24),
            CustomActionButton(
              onPressed: _submit,
              color: AppTheme.lightPrimary,
              width: double.infinity,
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Submit',
                      style: TextStyle(color: Colors.white),
                    ),
            ),
            SizedBox(height: 40,),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(DashboardImage image) {
    if (image.localFile != null) {
      return Image.file(
        image.localFile!,
        width: 90,
        height: 90,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildErrorPlaceholder(),
      );
    } else if (image.networkUrl != null) {
      return Image.network(
        image.networkUrl!,
        width: 90,
        height: 90,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildErrorPlaceholder(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildShimmerPlaceholder();
        },
      );
    }
    return _buildErrorPlaceholder();
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.error_outline),
    );
  }

  Widget _buildShimmerPlaceholder() {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }

  Widget _helperTextField({required String helperText, required Widget field}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          helperText,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.grey1,
          ),
        ),
        const SizedBox(height: 6),
        field,
      ],
    );
  }
}
