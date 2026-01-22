import 'package:farm_vest/features/employee/new_supervisor/providers/leave_request_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CreateLeaveRequestScreen extends ConsumerStatefulWidget {
  const CreateLeaveRequestScreen({super.key});

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
        title: const Text('Create Leave Request'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.pop();
          }
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
                        decoration: const InputDecoration(
                          labelText: 'Start Date',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(_startDate?.toLocal().toString().split(' ')[0] ??
                            'Select date'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
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
                        decoration: const InputDecoration(
                          labelText: 'End Date',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(_endDate?.toLocal().toString().split(' ')[0] ??
                            'Select date'),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Leave Type Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Leave Type',
                  border: OutlineInputBorder(),
                ),
                value: _leaveType,
                items: ['CASUAL', 'SICK', 'ANNUAL', 'MATERNITY', 'PATERNITY', 'UNPAID']
                    .map((label) => DropdownMenuItem(
                          value: label,
                          child: Text(label),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _leaveType = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select a leave type' : null,
              ),
              const SizedBox(height: 16),

              // Reason Text Field
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter a reason' : null,
              ),
              const SizedBox(height: 24),

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
                        const SnackBar(
                          content: Text('Leave request created successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      context.pop();
                    } else if (leaveRequestState.error != null && context.mounted) {
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
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: leaveRequestState.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Submit Request'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
