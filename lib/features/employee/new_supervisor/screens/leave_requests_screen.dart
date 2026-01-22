import 'package:farm_vest/features/employee/new_supervisor/data/models/leave_request_model.dart';
import 'package:farm_vest/features/employee/new_supervisor/providers/leave_request_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LeaveRequestsScreen extends ConsumerStatefulWidget {
  const LeaveRequestsScreen({super.key});

  @override
  ConsumerState<LeaveRequestsScreen> createState() => _LeaveRequestsScreenState();
}

class _LeaveRequestsScreenState extends ConsumerState<LeaveRequestsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch leave requests when the screen is first initialized
    Future.microtask(() => ref.read(leaveRequestProvider.notifier).getLeaveRequests());
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Colors.orange;
      case 'APPROVED':
        return Colors.green;
      case 'CANCELLED':
      case 'REJECTED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showLeaveRequestDetails(BuildContext context, LeaveRequest leaveRequest) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Leave Request Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Status: ${leaveRequest.status}', style: TextStyle(color: _getStatusColor(leaveRequest.status), fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Leave Type: ${leaveRequest.leaveType}'),
                const SizedBox(height: 8),
                Text('From: ${leaveRequest.startDate} To: ${leaveRequest.endDate}'),
                const SizedBox(height: 8),
                const Text('Reason:'),
                Text(leaveRequest.reason),
              ],
            ),
          ),
          actions: <Widget>[
            if (leaveRequest.status == 'PENDING')
              TextButton(
                child: const Text('Cancel Request', style: TextStyle(color: Colors.red)),
                onPressed: () {
                   ref.read(leaveRequestProvider.notifier).cancelLeaveRequest(leaveRequest.id);
                   Navigator.of(context).pop();
                },
              ),
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final leaveRequestState = ref.watch(leaveRequestProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave Requests'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/supervisor-dashboard'),
        ),
      ),
      body: leaveRequestState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : leaveRequestState.error != null
              ? Center(child: Text(leaveRequestState.error!))
              : RefreshIndicator(
                  onRefresh: () => ref.read(leaveRequestProvider.notifier).getLeaveRequests(),
                  child: ListView.builder(
                    itemCount: leaveRequestState.leaveRequests.length,
                    itemBuilder: (context, index) {
                      final leaveRequest = leaveRequestState.leaveRequests[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                        ),
                        child: ListTile(
                          title: Text('${leaveRequest.leaveType} Leave'),
                          subtitle: Text(
                              '${leaveRequest.startDate} to ${leaveRequest.endDate}'),
                          trailing: Text(
                            leaveRequest.status,
                            style: TextStyle(color: _getStatusColor(leaveRequest.status), fontWeight: FontWeight.bold),
                          ),
                          onTap: () {
                            _showLeaveRequestDetails(context, leaveRequest);
                          },
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/create-leave-request');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
