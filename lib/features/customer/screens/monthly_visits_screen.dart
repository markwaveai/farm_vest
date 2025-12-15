import 'package:farm_vest/core/theme/app_constants.dart';
import 'package:farm_vest/core/utils/navigation_helper.dart';
import 'package:farm_vest/core/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_theme.dart';

enum SlotStatus { available, booked, full }

class VisitSlot {
  final DateTime date;
  final String time;
  final int maxSlots;
  int bookedSlots;
  final List<String> bookedBy; // List of user IDs who booked
  final List<String> visitedUsers; // Users who have already visited this month

  bool get isAvailable =>
      bookedSlots < maxSlots &&
      !visitedUsers.contains('current_user_id'); // Replace with actual user ID

  VisitSlot({
    required this.date,
    required this.time,
    this.maxSlots = 10,
    this.bookedSlots = 0,
    List<String>? bookedBy,
    List<String>? visitedUsers,
  }) : bookedBy = bookedBy ?? [],
       visitedUsers = visitedUsers ?? [];

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'time': time,
    'maxSlots': maxSlots,
    'bookedSlots': bookedSlots,
    'bookedBy': bookedBy,
    'visitedUsers': visitedUsers,
  };

  factory VisitSlot.fromJson(Map<String, dynamic> json) => VisitSlot(
    date: DateTime.parse(json['date']),
    time: json['time'],
    maxSlots: json['maxSlots'] ?? 10,
    bookedSlots: json['bookedSlots'] ?? 0,
    bookedBy: List<String>.from(json['bookedBy'] ?? []),
    visitedUsers: List<String>.from(json['visitedUsers'] ?? []),
  );
}

class MonthlyVisitsScreen extends StatefulWidget {
  const MonthlyVisitsScreen({super.key});

  @override
  State<MonthlyVisitsScreen> createState() => _MonthlyVisitsScreenState();
}

class _MonthlyVisitsScreenState extends State<MonthlyVisitsScreen> {
  late DateTime _selectedMonth;
  List<VisitSlot> _visitSlots = [];
  final String _currentUserId =
      'current_user_id'; // Replace with actual user ID
  bool _hasVisitedThisMonth = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now();
    _loadVisitData();
  }

  Future<void> _loadVisitData() async {
    setState(() => _isLoading = true);

    // In a real app, load from your backend
    final prefs = await SharedPreferences.getInstance();
    final lastVisit = prefs.getString('last_visit_$_currentUserId');

    if (lastVisit != null) {
      final lastVisitDate = DateTime.parse(lastVisit);
      _hasVisitedThisMonth =
          lastVisitDate.month == DateTime.now().month &&
          lastVisitDate.year == DateTime.now().year;
    }

    // Generate slots for the current month
    _generateVisitSlots();
    setState(() => _isLoading = false);
  }

  void _generateVisitSlots() {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final slots = <VisitSlot>[];

    // Generate slots for each working day (Mon-Fri) of the current month
    for (var day = 1; day <= daysInMonth; day++) {
      final date = DateTime(now.year, now.month, day);

      // Skip weekends (6 = Saturday, 7 = Sunday)
      if (date.weekday >= 6) continue;

      // Add two time slots per day (morning and afternoon)
      slots.add(
        VisitSlot(
          date: date,
          time: '10:00 AM - 12:00 PM',
          maxSlots: 10,
          bookedSlots: 0, // In real app, load from backend
        ),
      );

      slots.add(
        VisitSlot(
          date: date,
          time: '2:00 PM - 4:00 PM',
          maxSlots: 10,
          bookedSlots: 0, // In real app, load from backend
        ),
      );
    }

    setState(() => _visitSlots = slots);
  }

  Future<void> _bookSlot(VisitSlot slot) async {
    if (_hasVisitedThisMonth) {
      _showMessage(
        'You have already visited this month. Please come back next month!',
      );
      return;
    }

    if (slot.bookedBy.contains(_currentUserId)) {
      _showMessage('You have already booked a slot for this day');
      return;
    }

    if (slot.bookedSlots >= slot.maxSlots) {
      _showMessage('This slot is already full');
      return;
    }

    // Show success message and update UI
    _showMessage('Slot booked successfully!');

    // In a real app, save to backend first
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'last_visit_$_currentUserId',
      slot.date.toIso8601String(),
    );

    if (mounted) {
      setState(() {
        slot.bookedSlots++;
        slot.bookedBy.add(_currentUserId);
        _hasVisitedThisMonth = true;
      });
    }
  }

  void _showMessage(String message) {
    ToastUtils.showInfo(context, message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Visits'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => NavigationHelper.safePopOrNavigate(
            context,
            fallbackRoute: '/customer-dashboard',
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasVisitedThisMonth
          ? _buildVisitedMessage()
          : _buildCalendar(),
    );
  }

  Widget _buildVisitedMessage() {
    // Find the user's booked slot
    final bookedSlot = _visitSlots.firstWhere(
      (slot) => slot.bookedBy.contains(_currentUserId),
      orElse: () => _visitSlots.first, // Fallback to first slot if not found
    );

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 64,
              color: AppTheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Visit Scheduled!',
              style: AppTheme.headingMedium.copyWith(color: AppTheme.primary),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Booking Details',
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      Icons.calendar_today,
                      DateFormat('EEEE, MMM d, yyyy').format(bookedSlot.date),
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow(Icons.access_time, bookedSlot.time),
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      Icons.people,
                      '${bookedSlot.bookedSlots}/${bookedSlot.maxSlots} slots filled',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _viewBookingDetails(bookedSlot),
                  icon: const Icon(Icons.visibility),
                  label: const Text('View Details'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                TextButton.icon(
                  onPressed: () => context.go('/customer-dashboard'),
                  icon: const Icon(Icons.dashboard),
                  label: const Text('Dashboard'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build detail rows
  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Text(text, style: AppTheme.bodyMedium),
      ],
    );
  }

  Widget _buildCalendar() {
    return Column(
      children: [
        _buildMonthSelector(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: _visitSlots.length,
            itemBuilder: (context, index) {
              final slot = _visitSlots[index];
              return _buildVisitSlot(slot);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMonthSelector() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: _previousMonth,
          ),
          Text(
            DateFormat('MMMM yyyy').format(_selectedMonth),
            style: AppTheme.headingMedium,
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios),
            onPressed: _nextMonth,
          ),
        ],
      ),
    );
  }

  Widget _buildVisitSlot(VisitSlot slot) {
    final isBooked = slot.bookedBy.contains(_currentUserId);
    final isFull = slot.bookedSlots >= slot.maxSlots;
    final isPastDate = slot.date.isBefore(
      DateTime.now().subtract(const Duration(days: 1)),
    );

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: ListTile(
        title: Text(
          '${DateFormat('EEEE, MMM d').format(slot.date)} • ${slot.time}',
          style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          '${slot.maxSlots - slot.bookedSlots} slots available',
          style: TextStyle(color: isFull ? Colors.red : Colors.green),
        ),
        trailing: isBooked
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OutlinedButton(
                    onPressed: () => _viewBookingDetails(slot),
                    child: const Text('View'),
                  ),
                  const SizedBox(width: 8),
                  const Chip(
                    label: Text(
                      'Booked',
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: AppTheme.primary,
                  ),
                ],
              )
            : ElevatedButton(
                onPressed: isFull || isPastDate || _hasVisitedThisMonth
                    ? isFull
                          ? null
                          : () => _showAlreadyScheduledMessage()
                    : () => _bookSlot(slot),
                child: Text(isFull ? 'Full' : 'Book Slot'),
              ),
      ),
    );
  }

  // Add this new method
  void _showAlreadyScheduledMessage() {
    ToastUtils.showInfo(
      context,
      'You have already scheduled a visit for this month.',
    );
  }

  // Add this method to show booking details
  void _viewBookingDetails(VisitSlot slot) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Your Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: ${DateFormat('EEEE, MMM d, yyyy').format(slot.date)}'),
            Text('Time: ${slot.time}'),
            const SizedBox(height: 16),
            const Text(
              'Status: Confirmed',
              style: TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('Slot: ${slot.bookedSlots}/${slot.maxSlots} booked'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _previousMonth() {
    if (_selectedMonth.month > DateTime.now().month ||
        _selectedMonth.year > DateTime.now().year) {
      setState(() {
        _selectedMonth = DateTime(
          _selectedMonth.year,
          _selectedMonth.month - 1,
          1,
        );
        // In a real app, load slots for the selected month from backend
      });
    }
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + 1,
        1,
      );
      // In a real app, load slots for the selected month from backend
    });
  }
}
