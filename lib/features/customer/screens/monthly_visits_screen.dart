import 'package:farm_vest/core/utils/navigation_helper.dart';
import 'package:farm_vest/core/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_theme.dart';

class VisitSlot {
  final String time;
  final int totalCapacity;
  int bookedCount;
  bool isSelected;

  bool get isFull => bookedCount >= totalCapacity;

  VisitSlot({
    required this.time,
    required this.totalCapacity,
    required this.bookedCount,
    this.isSelected = false,
  });
}

class MonthlyVisitsScreen extends StatefulWidget {
  const MonthlyVisitsScreen({super.key});

  @override
  State<MonthlyVisitsScreen> createState() => _MonthlyVisitsScreenState();
}

class _MonthlyVisitsScreenState extends State<MonthlyVisitsScreen> {
  DateTime _selectedDate = DateTime.now();
  List<VisitSlot> _slots = [];
  bool _isLoading = true;
  bool _hasBookedThisMonth = false;
  DateTime? _userBookingDate; // Track exact date of booking if any
  String? _userBookingTime;
  final int _slotCapacity = 5;

  @override
  void initState() {
    super.initState();
    _checkMonthBooking();
    _generateSlots();
  }

  // Simulate checking if user has already booked for this month
  Future<void> _checkMonthBooking() async {
    final prefs = await SharedPreferences.getInstance();
    // Key format: visit_booking_userId_year_month
    // For demo, we use a generic key or simulate
    final currentMonthKey = 'visit_booking_2024_${_selectedDate.month}';
    final savedBooking = prefs.getString(currentMonthKey);

    if (savedBooking != null) {
      final parts = savedBooking.split('|'); // date|time
      if (parts.length == 2) {
        setState(() {
          _hasBookedThisMonth = true;
          _userBookingDate = DateTime.parse(parts[0]);
          _userBookingTime = parts[1];
        });
      }
    }
  }

  void _generateSlots() {
    setState(() => _isLoading = true);

    // Simulate API delay
    Future.delayed(const Duration(milliseconds: 500), () {
      final List<String> times = [
        "09:00 - 09:30 AM",
        "09:30 - 10:00 AM",
        "10:00 - 10:30 AM",
        "10:30 - 11:00 AM",
        "11:00 - 11:30 AM",
        "11:30 - 12:00 PM",
      ];

      _slots = times.map((time) {
        // Randomly simulate existing bookings for demo
        // In real app, this comes from API
        int booked = 0;
        if (_selectedDate.day % 2 == 0) {
          booked =
              (time.hashCode %
              (_slotCapacity + 1)); // Allow existing full slots
        }

        return VisitSlot(
          time: time,
          totalCapacity: _slotCapacity,
          bookedCount: booked,
        );
      }).toList();

      setState(() => _isLoading = false);
    });
  }

  void _onDateSelected(DateTime date) {
    if (date.month != _selectedDate.month) {
      // If month changes, we should ideally re-check month booking,
      // but for this UI flow, let's assume valid range is current month/future.
      // User requirement: "1 year 12 slots... monthly 1 slot"
    }
    setState(() {
      _selectedDate = date;
      // Reset selection when date changes
      for (var s in _slots) {
        s.isSelected = false;
      }
    });
    _generateSlots(); // Reload slots for new date
    _checkMonthBooking(); // Re-check if this month has a booking
  }

  void _onSlotTap(int index) {
    if (_hasBookedThisMonth) {
      ToastUtils.showInfo(
        context,
        "You have already booked a slot for this month.",
      );
      return;
    }

    final slot = _slots[index];
    if (slot.isFull) return;

    setState(() {
      // Deselect others
      for (var s in _slots) s.isSelected = false;
      // Select tapped
      _slots[index].isSelected = true;
    });

    _showBookingConfirmation(_slots[index]);
  }

  Future<void> _processBooking(VisitSlot slot) async {
    // Mock API Request Payload
    final requestPayload = {
      "userId": "CURRENT_USER_ID", // TODO: Replace with actual ID
      "date": DateFormat('yyyy-MM-dd').format(_selectedDate),
      "time": slot.time,
    };
    debugPrint("\n--- [BACKEND REQUEST] ---");
    debugPrint("POST /api/visits/book");
    debugPrint(requestPayload.toString());
    debugPrint("-------------------------\n");

    // 1. Save to local storage (mock API)
    final prefs = await SharedPreferences.getInstance();
    final currentMonthKey = 'visit_booking_2024_${_selectedDate.month}';
    final bookingValue = "${_selectedDate.toIso8601String()}|${slot.time}";
    await prefs.setString(currentMonthKey, bookingValue);

    // 2. Update State
    setState(() {
      _hasBookedThisMonth = true;
      _userBookingDate = _selectedDate;
      _userBookingTime = slot.time;
      slot.bookedCount++;
    });

    // 3. Show QR Code
    if (mounted) {
      Navigator.pop(context); // Close confirmation dialog
      _showSuccessQRDialog(slot);
    }
  }

  void _showBookingConfirmation(VisitSlot slot) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Confirm Booking", style: AppTheme.headingMedium),
            const SizedBox(height: 16),
            Text(
              "You are booking a visit on:",
              style: AppTheme.bodyMedium.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: AppTheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('EEEE, d MMMM yyyy').format(_selectedDate),
                  style: AppTheme.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  color: AppTheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  slot.time,
                  style: AppTheme.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _processBooking(slot),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Confirm & Generate pass",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessQRDialog(VisitSlot slot) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 64),
              const SizedBox(height: 16),
              Text("Booking Confirmed!", style: AppTheme.headingMedium),
              const SizedBox(height: 8),
              Text("Here is your entry pass", style: AppTheme.bodyMedium),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: QrImageView(
                  data:
                      "VISIT-2024-${_selectedDate.month}-${_selectedDate.day}-${slot.time}",
                  version: QrVersions.auto,
                  size: 200.0,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Done"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _viewExistingPass() {
    if (_userBookingDate == null || _userBookingTime == null) return;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Your Entry Pass", style: AppTheme.headingMedium),
              const SizedBox(height: 8),
              Text(
                "${DateFormat('d MMM yyyy').format(_userBookingDate!)} at $_userBookingTime",
                style: AppTheme.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: QrImageView(
                  data:
                      "VISIT-2024-${_userBookingDate!.month}-${_userBookingDate!.day}-$_userBookingTime",
                  version: QrVersions.auto,
                  size: 200.0,
                ),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showBookingHistory() async {
    final prefs = await SharedPreferences.getInstance();
    // Filter keys starting with 'visit_booking_'
    final keys = prefs
        .getKeys()
        .where((k) => k.startsWith('visit_booking_'))
        .toList();

    List<Map<String, dynamic>> bookings = [];
    for (var key in keys) {
      // Key: visit_booking_2024_12
      // Value: 2024-12-19T...|09:00 AM
      final value = prefs.getString(key);
      if (value != null && value.contains('|')) {
        final parts = value.split('|');
        bookings.add({'date': DateTime.parse(parts[0]), 'time': parts[1]});
      }
    }

    // Sort descending (newest first)
    bookings.sort(
      (a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime),
    );

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24.0),
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("My Bookings", style: AppTheme.headingMedium),
            const SizedBox(height: 16),
            Expanded(
              child: bookings.isEmpty
                  ? const Center(
                      child: Text(
                        "No bookings found",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: bookings.length,
                      itemBuilder: (context, index) {
                        final booking = bookings[index];
                        final date = booking['date'] as DateTime;
                        final time = booking['time'] as String;
                        final isPast = date.isBefore(
                          DateTime.now().subtract(const Duration(days: 1)),
                        );

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isPast
                                    ? Colors.grey[200]
                                    : AppTheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.calendar_today,
                                color: isPast ? Colors.grey : AppTheme.primary,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              DateFormat('MMM d, yyyy').format(date),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(time),
                            trailing: isPast
                                ? const Chip(
                                    label: Text(
                                      "Completed",
                                      style: TextStyle(fontSize: 10),
                                    ),
                                  )
                                : IconButton(
                                    icon: const Icon(
                                      Icons.qr_code,
                                      color: AppTheme.primary,
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context); // Close sheet
                                      _showHistoricalQR(date, time);
                                    },
                                  ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHistoricalQR(DateTime date, String time) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Entry Pass", style: AppTheme.headingMedium),
              const SizedBox(height: 8),
              Text(
                "${DateFormat('d MMM yyyy').format(date)} at $time",
                style: AppTheme.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: QrImageView(
                  data: "VISIT-2024-${date.month}-${date.day}-$time",
                  version: QrVersions.auto,
                  size: 200.0,
                ),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlotSummaryCard() {
    final totalCapacity = _slots.fold<int>(
      0,
      (sum, s) => sum + s.totalCapacity,
    );
    final totalBooked = _slots.fold<int>(0, (sum, s) => sum + s.bookedCount);
    final totalAvailable = (totalCapacity - totalBooked).clamp(
      0,
      totalCapacity,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Card(
        elevation: 6,
        shadowColor: Colors.black.withOpacity(0.12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.primary.withOpacity(0.10), Colors.white],
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
                          DateFormat('MMMM d, yyyy').format(_selectedDate),
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
                const SizedBox(height: 16),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Your Visit'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _showBookingHistory,
            tooltip: 'Booking History',
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => NavigationHelper.safePopOrNavigate(
            context,
            fallbackRoute: '/customer-dashboard',
          ),
        ),
      ),
      body: Column(
        children: [
          _buildSlotSummaryCard(),

          // 2. Date Strip
          _buildDateStrip(),

          const SizedBox(height: 24),

          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Available Slots (${_slots.fold(0, (sum, s) => sum + (s.totalCapacity - s.bookedCount))}/${_slots.fold(0, (sum, s) => sum + s.totalCapacity)})",
                          style: AppTheme.headingMedium,
                        ),
                        if (_hasBookedThisMonth)
                          TextButton.icon(
                            onPressed: _viewExistingPass,
                            icon: const Icon(Icons.qr_code),
                            label: const Text("View Pass"),
                          ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else
                      Expanded(child: _buildTimeGrid()),

                    const SizedBox(height: 20),
                    _buildLegend(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateStrip() {
    // Generate next 30 days as per requirement (future bookings only within 30 days)
    final List<DateTime> dates = List.generate(
      30,
      (index) => DateTime.now().add(Duration(days: index)),
    );

    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected =
              date.day == _selectedDate.day &&
              date.month == _selectedDate.month;

          return GestureDetector(
            onTap: () => _onDateSelected(date),
            child: Container(
              width: 60,
              margin: const EdgeInsets.only(right: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E').format(date),
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.grey,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (isSelected)
                    Container(
                      height: 3,
                      width: 20,
                      color: AppTheme.successGreen,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _slots.length,
      itemBuilder: (context, index) {
        final slot = _slots[index];
        bool isFull = slot.isFull;
        bool isSelected = slot.isSelected;
        int remaining = slot.totalCapacity - slot.bookedCount;

        Color bgColor = Colors.transparent;
        Color borderColor = AppTheme.successGreen.withOpacity(0.3);
        Color textColor = Colors.black87;
        Color subTextColor = Colors.grey[600]!;

        if (isFull) {
          bgColor = Colors.grey.shade100;
          borderColor = Colors.transparent;
          textColor = Colors.grey;
          subTextColor = Colors.grey;
        } else if (isSelected) {
          bgColor = AppTheme.successGreen;
          borderColor = AppTheme.successGreen;
          textColor = Colors.white;
          subTextColor = Colors.white.withValues(alpha: 0.9);
        }

        return InkWell(
          onTap: isFull ? null : () => _onSlotTap(index),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 1.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  slot.time.replaceAll(" AM", "\nAM").replaceAll(" PM", "\nPM"),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isFull ? "Full" : "$remaining Available",
                  style: TextStyle(
                    color: subTextColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildLegendItem(
            "Available",
            Colors.white,
            borderColor: AppTheme.successGreen.withOpacity(0.5),
          ),
          _buildLegendItem("Selected", AppTheme.successGreen),
          _buildLegendItem("Booked", Colors.grey.shade300),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, {Color? borderColor}) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: borderColor != null ? Border.all(color: borderColor) : null,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
