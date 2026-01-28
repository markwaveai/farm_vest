import 'package:farm_vest/core/services/api_services.dart';
import 'package:farm_vest/core/utils/navigation_helper.dart';
import 'package:farm_vest/core/utils/toast_utils.dart';
import 'package:farm_vest/features/auth/presentation/providers/auth_provider.dart';
import 'package:farm_vest/features/auth/data/repositories/auth_repository.dart';
import 'package:farm_vest/features/investor/data/models/visit_model.dart';
import 'package:farm_vest/features/investor/data/models/visit_params.dart';
import 'package:farm_vest/features/investor/presentation/providers/visit_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:farm_vest/core/theme/app_theme.dart';

class MonthlyVisitsScreen extends ConsumerStatefulWidget {
  const MonthlyVisitsScreen({super.key});

  @override
  ConsumerState<MonthlyVisitsScreen> createState() =>
      _MonthlyVisitsScreenState();
}

class _MonthlyVisitsScreenState extends ConsumerState<MonthlyVisitsScreen> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedSlotTime;

  // Hardcoded constant as per user request context
  final String _farmLocation = "Kurnool";
  final String _locationId = "LOC-123";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // 1. Availability Request
    final availabilityAsync = ref.watch(
      visitAvailabilityProvider(
        VisitAvailabilityParams(
          date: DateFormat('yyyy-MM-dd').format(_selectedDate),
          location: _farmLocation,
        ),
      ),
    );

    // 2. User History Request (to check if already booked)
    final historyAsync = ref.watch(myVisitsProvider);

    bool hasBookedThisMonth = false;
    Visit? bookedVisit;

    // Check if booked this month
    historyAsync.whenData((visits) {
      for (var visit in visits) {
        try {
          final visitDate = DateTime.parse(visit.visitDate);
          if (visitDate.year == _selectedDate.year &&
              visitDate.month == _selectedDate.month) {
            hasBookedThisMonth = true;
            bookedVisit = visit;
            break;
          }
        } catch (e) {
          // ignore date parse error
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Your Visit'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => _showBookingHistory(),
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
          // Summary Card
          _buildSlotSummaryCard(availabilityAsync, hasBookedThisMonth),

          // Date Strip
          _buildDateStrip(theme, isDark),

          const SizedBox(height: 24),

          // Slots Grid
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                // color: Colors.white,
                color: theme.colorScheme.surface,
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
                          "Available Slots",
                          style: AppTheme.headingMedium.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        if (hasBookedThisMonth && bookedVisit != null)
                          TextButton.icon(
                            onPressed: () => _viewExistingPass(bookedVisit!),
                            icon: Icon(
                              Icons.qr_code,
                              size: 20,

                              color: isDark ? AppTheme.white : AppTheme.black87,
                            ),
                            label: Text(
                              "View Pass",
                              style: TextStyle(
                                color: isDark
                                    ? AppTheme.white
                                    : AppTheme.black87,

                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: availabilityAsync.when(
                        data: (data) => _buildTimeGrid(
                          data?.availableSlots ?? <String>[],
                          hasBookedThisMonth,
                          isDark,
                          theme,
                        ),
                        error: (e, s) => Center(
                          child: Text(
                            "Could not load slots. Please try again.",
                          ),
                        ),
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                      ),
                    ),
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

  Widget _buildSlotSummaryCard(
    AsyncValue<VisitAvailability?> asyncData,
    bool hasBooked,
  ) {
    int totalAvailable = 0;
    // We don't have total capacity info from API, so just show available
    asyncData.whenData((data) {
      if (data != null) {
        totalAvailable = data.availableSlots.length;
      }
    });

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
                    // Removed total capacity badging as API doesn't support it
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryPill(
                        title: 'Available Slots',
                        value: totalAvailable.toString(),
                        color: Colors.green,
                        icon: Icons.event_available,
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (hasBooked)
                      Expanded(
                        child: _buildSummaryPill(
                          title: 'Status',
                          value: 'Booked',
                          color: AppTheme.primary,
                          icon: Icons.check_circle,
                        ),
                      )
                    else
                      Expanded(
                        child: _buildSummaryPill(
                          title: 'Status',
                          value: 'Open',
                          color: Colors.orange,
                          icon: Icons.event,
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
        color: AppTheme.white,
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

  Widget _buildDateStrip(ThemeData theme, bool isDark) {
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
            onTap: () {
              setState(() {
                _selectedDate = date;
                _selectedSlotTime = null; // Reset selection
              });
            },
            child: Container(
              width: 60,
              margin: const EdgeInsets.only(right: 12),

              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E').format(date),
                    style: TextStyle(
                      color: isSelected
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurface.withOpacity(0.6),
                      //Colors.black : Colors.grey,
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
                      color: isSelected
                          ? AppTheme.mediumGrey
                          : (isDark ? AppTheme.white : AppTheme.black),

                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (isSelected)
                    Container(height: 3, width: 20, color: AppTheme.primary),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeGrid(
    List<String> availableSlots,
    bool hasBookedThisMonth,
    bool isDark,
    ThemeData theme,
  ) {
    if (availableSlots.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_busy, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              "No slots available",
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    final now = DateTime.now();
    final isToday =
        _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: availableSlots.length,
      itemBuilder: (context, index) {
        final time = availableSlots[index];
        bool isSelected = _selectedSlotTime == time;
        bool isExpired = false;

        // Parse time to check expiry
        DateTime? slotDateTime;
        try {
          final timeParts = time.split(':');
          if (timeParts.length >= 2) {
            slotDateTime = DateTime(
              _selectedDate.year,
              _selectedDate.month,
              _selectedDate.day,
              int.parse(timeParts[0]), // Hour
              int.parse(timeParts[1]), // Minute
            );
          }
        } catch (e) {
          // ignore parse error
        }

        if (isToday && slotDateTime != null && slotDateTime.isBefore(now)) {
          isExpired = true;
        }

        // Format time for display (09:00:00 -> 09:00 AM)
        String displayTime = time;
        try {
          // Assume time is HH:mm:ss
          final dt = DateFormat("HH:mm:ss").parse(time);
          displayTime = DateFormat("h:mm a").format(dt);
        } catch (e) {
          // keep as is
        }

        // Color bgColor = Colors.transparent;
        // Color borderColor = AppTheme.successGreen.withOpacity(0.3);
        // Color textColor = Colors.black87;
        Color bgColor = isDark ? Colors.grey.shade50 : Colors.transparent;
        Color borderColor = AppTheme.successGreen.withOpacity(0.3);
        Color textColor = isDark ? AppTheme.white : AppTheme.black87;
        if (isExpired) {
          //bgColor = Colors.grey.shade100;
          bgColor = isDark ? Colors.grey.shade600 : Colors.grey.shade100;
          borderColor = Colors.transparent;
          textColor = isDark ? AppTheme.white : AppTheme.black87;
        } else if (isSelected) {
          bgColor = AppTheme.successGreen;
          borderColor = AppTheme.successGreen;
          textColor = AppTheme.white;
        } else {
          bgColor = isDark ? AppTheme.white : Colors.transparent;
          borderColor = AppTheme.successGreen.withOpacity(0.3);
          textColor = AppTheme.black;
        }

        return InkWell(
          onTap: (isExpired || hasBookedThisMonth)
              ? (hasBookedThisMonth && !isExpired
                    ? () => ToastUtils.showInfo(
                        context,
                        "You have already booked a slot for this month.",
                      )
                    : null)
              : () {
                  setState(() {
                    _selectedSlotTime = time;
                  });
                  _showBookingConfirmation(time);
                },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 1.5),
            ),
            child: Text(
              displayTime,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
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
        color: AppTheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildLegendItem(
            "Available",
            AppTheme.white,
            borderColor: AppTheme.successGreen.withOpacity(0.5),
          ),
          _buildLegendItem("Selected", AppTheme.successGreen),
          _buildLegendItem(
            "Expired",
            Colors.grey.shade600,
            borderColor: Colors.transparent,
          ),
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

  void _showBookingConfirmation(String time) {
    String displayTime = time;
    try {
      final dt = DateFormat("HH:mm:ss").parse(time);
      displayTime = DateFormat("h:mm a").format(dt);
    } catch (e) {
      /*ignore*/
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      //builder: (context) => Padding(
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Confirm Booking",
                style: AppTheme.headingMedium.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
                //style: AppTheme.headingMedium,
              ),
              const SizedBox(height: 16),
              Text(
                "You are booking a visit on:",
                style: AppTheme.bodyMedium.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
                // style: AppTheme.bodyMedium.copyWith(color: Colors.grey[600]),
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
                      color: isDark ? AppTheme.white : AppTheme.black87,
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
                    displayTime,
                    style: AppTheme.bodyLarge.copyWith(
                      color: isDark ? AppTheme.white : AppTheme.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _processBooking(time),
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
        );
      },
    );
  }

  Future<void> _processBooking(String time) async {
    final authState = ref.read(authProvider);
    final mobile = authState.mobileNumber;

    if (mobile == null) {
      ToastUtils.showError(context, "User not identified");
      return;
    }

    // Format time to HH:mm if API expects that, but API docs example says "10:30".
    // Available slots are "09:00:00". I will use 09:00.
    String formattedTime = time;
    try {
      final dt = DateFormat("HH:mm:ss").parse(time);
      formattedTime = DateFormat("HH:mm").format(dt);
    } catch (e) {
      // failed parse
    }

    final request = VisitBookingRequest(
      farmLocation: _farmLocation,
      locationId: _locationId,
      startTime: formattedTime,
      userMobile: mobile,
      visitDate: DateFormat('yyyy-MM-dd').format(_selectedDate),
    );

    Navigator.pop(context); // close confirmation sheet
    // Show loading? or just await

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Get token from auth repository
      final repository = AuthRepository();
      final token = await repository.getToken();

      final visit = await ApiServices.bookVisit(request);

      if (!mounted) return;
      Navigator.pop(context); // close loading

      // Refresh history to show the new booking
      ref.invalidate(myVisitsProvider);
      // Refresh availability if needed
      ref.invalidate(
        visitAvailabilityProvider(
          VisitAvailabilityParams(
            date: DateFormat('yyyy-MM-dd').format(_selectedDate),
            location: _farmLocation,
          ),
        ),
      );

      _showSuccessQRDialog(visit);
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // close loading
      ToastUtils.showError(context, "Booking failed: ${e.toString()}");
    }
  }

  void _showSuccessQRDialog(Visit visit) {
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
              _buildQrCode(visit),
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

  void _viewExistingPass(Visit visit) {
    //print("visit id: ${visit.visitId}");
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          // prevents clipping
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Your Entry Pass",
                  style: AppTheme.headingMedium.copyWith(
                    color: isDark ? AppTheme.white : AppTheme.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "${visit.visitDate} at ${_formatTimeWithAmPm(visit.startTime)}",
                  style: AppTheme.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 24),
                _buildQrCode(visit), // keep QR white
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Close"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQrCode(Visit visit) {
    //   final qrData = visit.visitId?.toString().trim();

    // if (qrData == null || qrData.isEmpty) {
    //   return const Text(
    //     "QR code not available",
    //     style: TextStyle(
    //       color: Colors.red,
    //       fontWeight: FontWeight.bold,
    //     ),
    //   );
    // }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 10),
        ],
      ),
      child: QrImageView(
        // data: visit.visitId,
        data: visit.visitId, // Encoded visit ID for scanning
        version: QrVersions.auto,
        size: 200.0,
      ),
    );
  }

  void _showBookingHistory() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final historyAsync = ref.watch(myVisitsProvider);

          return Container(
            padding: const EdgeInsets.all(24.0),
            height: MediaQuery.of(context).size.height * 0.6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("My Bookings", style: AppTheme.headingMedium),
                    IconButton(
                      onPressed: () => ref.invalidate(myVisitsProvider),
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: historyAsync.when(
                    data: (visits) {
                      // Sort descending
                      final sortedVisits = List<Visit>.from(visits);
                      sortedVisits.sort(
                        (a, b) => b.visitDate.compareTo(a.visitDate),
                      );

                      if (sortedVisits.isEmpty) {
                        return const Center(
                          child: Text(
                            "No bookings found",
                            style: TextStyle(color: Colors.grey),
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: sortedVisits.length,
                        itemBuilder: (context, index) {
                          final visit = sortedVisits[index];
                          DateTime date;
                          try {
                            date = DateTime.parse(visit.visitDate);
                          } catch (e) {
                            date = DateTime.now();
                          }

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
                                  color: isPast
                                      ? Colors.grey
                                      : AppTheme.primary,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                DateFormat('MMM d, yyyy').format(date),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                _formatTimeWithAmPm(visit.startTime),
                              ),
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
                                        Navigator.pop(context);
                                        _viewExistingPass(visit);
                                      },
                                    ),
                            ),
                          );
                        },
                      );
                    },
                    error: (e, s) => Center(child: Text("Error: $e")),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatTimeWithAmPm(String time) {
    try {
      // Parse time in HH:mm format
      final dt = DateFormat("HH:mm").parse(time);
      // Return in h:mm a format (e.g., "9:00 AM")
      return DateFormat("h:mm a").format(dt);
    } catch (e) {
      // If parsing fails, return original
      return time;
    }
  }
}
