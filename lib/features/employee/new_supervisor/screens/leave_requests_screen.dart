import 'package:farm_vest/features/employee/new_supervisor/data/models/leave_request_model.dart';
import 'package:farm_vest/features/employee/new_supervisor/providers/leave_request_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:farm_vest/core/localization/translation_helpers.dart';
class LeaveRequestsScreen extends ConsumerStatefulWidget {
  LeaveRequestsScreen({super.key});

  @override
  ConsumerState<LeaveRequestsScreen> createState() =>
      _LeaveRequestsScreenState();
}

class _LeaveRequestsScreenState extends ConsumerState<LeaveRequestsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch leave requests when the screen is first initialized
    Future.microtask(
      () => ref.read(leaveRequestProvider.notifier).getLeaveRequests(),
    );
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

  void _showLeaveRequestDetails(
    BuildContext context,
    LeaveRequest leaveRequest,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Leave Request Details'.tr(ref)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${'Status'.tr(ref)}: ${leaveRequest.status.toLowerCase().tr(ref)}',
                  style: TextStyle(
                    color: _getStatusColor(leaveRequest.status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '${'Leave Type'.tr(ref)}: ${leaveRequest.leaveType.toLowerCase().tr(ref)}',
                ),
                SizedBox(height: 8),
                Text(
                  '${'From'.tr(ref)}: ${leaveRequest.startDate} ${'To'.tr(ref)}: ${leaveRequest.endDate}',
                ),
                SizedBox(height: 8),
                Text('${'Reason'.tr(ref)}:'),
                Text(leaveRequest.reason),
              ],
            ),
          ),
          actions: <Widget>[
            if (leaveRequest.status == 'PENDING')
              TextButton(
                child: Text(
                  'Cancel Request'.tr(ref),
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () {
                  ref
                      .read(leaveRequestProvider.notifier)
                      .cancelLeaveRequest(leaveRequest.id);
                  Navigator.of(context).pop();
                },
              ),
            TextButton(
              child: Text('Close'.tr(ref)),
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text(
          'Leave Requests'.tr(ref),
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => context.go('/supervisor-dashboard'),
        ),
      ),
      body: leaveRequestState.isLoading
          ? Center(child: CircularProgressIndicator())
          : leaveRequestState.error != null
          ? Center(child: Text(leaveRequestState.error!))
          : RefreshIndicator(
              onRefresh: () =>
                  ref.read(leaveRequestProvider.notifier).getLeaveRequests(),
              child: ListView.builder(
                itemCount: leaveRequestState.leaveRequests.length,
                itemBuilder: (context, index) {
                  final leaveRequest = leaveRequestState.leaveRequests[index];
                  return Card(
                    color: Theme.of(context).cardColor,
                    margin: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      title: Text(
                        '@type Leave'.trParams({
                          'type': leaveRequest.leaveType.toLowerCase().tr(ref),
                        }),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      subtitle: Text(
                        '${leaveRequest.startDate} ${'To'.tr(ref)} ${leaveRequest.endDate}',
                        style: TextStyle(color: Theme.of(context).hintColor),
                      ),
                      trailing: Text(
                        leaveRequest.status.toLowerCase().tr(ref),
                        style: TextStyle(
                          color: _getStatusColor(leaveRequest.status),
                          fontWeight: FontWeight.bold,
                        ),
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
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () {
          context.push('/create-leave-request');
        },
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
