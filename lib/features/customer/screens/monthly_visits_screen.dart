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
  late DateTime _selectedDate;
  List<VisitSlot> _visitSlots = [];
  final String _currentUserId =
      'current_user_id'; // Replace with actual user ID
  bool _hasVisitedThisMonth = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _selectedMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
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
          lastVisitDate.month == _selectedMonth.month &&
          lastVisitDate.year == _selectedMonth.year;
    }

    // Generate slots for the current month
    _generateVisitSlots();
    setState(() => _isLoading = false);
  }

  void _generateVisitSlots() {
    final daysInMonth =
        DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;
    final slots = <VisitSlot>[];

    // Generate slots for each working day (Mon-Fri) of the current month
    for (var day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_selectedMonth.year, _selectedMonth.month, day);

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

      // slots.add(
      //   VisitSlot(
      //     date: date,
      //     time: '2:00 PM - 4:00 PM',
      //     maxSlots: 10,
      //     bookedSlots: 0, // In real app, load from backend
      //   ),
      // );
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
        actions: [
          IconButton(onPressed: (){
            
          }, icon: Icon(Icons.history))
        ],
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
              shadowColor: AppTheme.dark.withOpacity(0.5),
              elevation:1.0,
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
        _buildSlotSummaryCard(),
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

  Widget _buildSlotSummaryCard() {
    final totalCapacity = _visitSlots.fold<int>(0, (sum, s) => sum + s.maxSlots);
    final totalBooked = _visitSlots.fold<int>(0, (sum, s) => sum + s.bookedSlots);
    final totalAvailable = (totalCapacity - totalBooked).clamp(0, totalCapacity);
    final progress = totalCapacity == 0 ? 0.0 : (totalBooked / totalCapacity);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Card(
        elevation: 6,
        shadowColor: Colors.black.withOpacity(0.12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primary.withOpacity(0.10),
                Colors.white,
              ],
            ),
          ),
        child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.insights,
                              size: 18,
                              color: AppTheme.primary,
                            ),
                            const SizedBox(width: 8),
                  Text(
                    'Slots Summary',
                    style: AppTheme.bodyMedium.copyWith(
                                fontWeight: FontWeight.w800,
                    ),
                  ),
                          ],
                        ),
                        const SizedBox(height: 6),
                  Text(
                    DateFormat('MMMM yyyy').format(_selectedMonth),
                    style: AppTheme.bodySmall.copyWith(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$totalBooked / $totalCapacity',
                        style: AppTheme.bodySmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                    Expanded(
                      child: _buildSummaryPill(
                    title: 'Available',
                    value: totalAvailable.toString(),
                    color: Colors.green,
                        icon: Icons.event_available,
                      ),
                  ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryPill(
                    title: 'Filled',
                    value: totalBooked.toString(),
                    color: Colors.red,
                        icon: Icons.event_busy,
                      ),
                  ),
                ],
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryPill({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTheme.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
        ],
      ),
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
          Expanded(
            child: Center(
              child: InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.mediumGrey.withOpacity(0.35),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.calendar_month,
                        size: 18,
                        color: AppTheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('dd MMM yyyy').format(_selectedDate),
                        style: AppTheme.headingMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios),
            onPressed: _nextMonth,
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(now.year - 5, 1, 1),
      lastDate: DateTime(now.year + 5, 12, 31),
    );

    if (picked == null) return;

    setState(() {
      _selectedDate = picked;
      _selectedMonth = DateTime(picked.year, picked.month, 1);
    });
    await _loadVisitData();
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
        subtitle: Text( isFull?'Slots Full':isPastDate?'Unavailable':
          '${slot.maxSlots - slot.bookedSlots} slots available',
          style: TextStyle(color: isFull ? Colors.red :isPastDate? Colors.grey: Colors.green),
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
                   Chip(
                    label: Text(
                      'Booked',
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor:isPastDate? Colors.grey: AppTheme.primary,
                  ),
                ],
              )
            : ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isFull || isPastDate || _hasVisitedThisMonth
                    ? Colors.grey
                    : AppTheme.primary,
              ),
                onPressed: isFull || isPastDate || _hasVisitedThisMonth
                    ? isFull
                          ? null
                          : () => _showAlreadyScheduledMessage()
                    : () => _bookSlot(slot),
                child: Text(isFull ? 'Full' :isPastDate? 'Expired':'Book Slot'),
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
        _selectedDate = _selectedMonth;
      });
      _loadVisitData();
    }
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + 1,
        1,
      );
      _selectedDate = _selectedMonth;
    });
    _loadVisitData();
  }
}
