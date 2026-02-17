import 'package:farm_vest/features/employee/new_supervisor/providers/leave_request_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:farm_vest/core/localization/translation_helpers.dart';
class CreateLeaveRequestScreen extends ConsumerStatefulWidget {
  CreateLeaveRequestScreen({super.key});

  @override
  ConsumerState<CreateLeaveRequestScreen> createState() =>
      _CreateLeaveRequestScreenState();
}

class _CreateLeaveRequestScreenState
    extends ConsumerState<CreateLeaveRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _startDate;
  DateTime? _endDate;
  String? _leaveType;
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final leaveRequestState = ref.watch(leaveRequestProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Create Leave Request'.tr(ref)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            context.pop();
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Start and End Date Pickers
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: _startDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(DateTime.now().year + 1),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            _startDate = pickedDate;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Start Date'.tr(ref),
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          _startDate?.toLocal().toString().split(' ')[0] ??
                              'Select date'.tr(ref),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: _endDate ?? _startDate ?? DateTime.now(),
                          firstDate: _startDate ?? DateTime.now(),
                          lastDate: DateTime(DateTime.now().year + 1),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            _endDate = pickedDate;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'End Date'.tr(ref),
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          _endDate?.toLocal().toString().split(' ')[0] ??
                              'Select date'.tr(ref),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Leave Type Dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Leave Type'.tr(ref),
                  border: OutlineInputBorder(),
                ),
                value: _leaveType,
                items:
                    [
                          'CASUAL',
                          'SICK',
                          'ANNUAL',
                          'MATERNITY',
                          'PATERNITY',
                          'UNPAID',
                        ]
                        .map(
                          (label) => DropdownMenuItem(
                            value: label,
                            child: Text(label.toLowerCase().tr(ref)),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    _leaveType = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select a leave type'.tr(ref) : null,
              ),
              SizedBox(height: 16),

              // Reason Text Field
              TextFormField(
                controller: _reasonController,
                decoration: InputDecoration(
                  labelText: 'Reason'.tr(ref),
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a reason'.tr(ref)
                    : null,
              ),
              SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final response = await ref
                        .read(leaveRequestProvider.notifier)
                        .createLeaveRequest(
                          startDate: _startDate.toString(),
                          endDate: _endDate.toString(),
                          leaveType: _leaveType!,
                          reason: _reasonController.text,
                        );
                    if (response != null && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Leave request created successfully'.tr(ref)),
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.secondary,
                        ),
                      );
                      context.pop();
                    } else if (leaveRequestState.error != null &&
                        context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(leaveRequestState.error!),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: leaveRequestState.isLoading
                    ? CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.onPrimary,
                      )
                    : Text('Submit Request'.tr(ref)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
