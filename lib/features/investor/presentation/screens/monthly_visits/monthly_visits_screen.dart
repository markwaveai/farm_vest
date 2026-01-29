import 'package:farm_vest/core/services/api_services.dart';
import 'package:farm_vest/core/services/visits_api_services.dart';
import 'package:farm_vest/core/utils/navigation_helper.dart';
import 'package:farm_vest/core/utils/toast_utils.dart';
import 'package:farm_vest/features/auth/presentation/providers/auth_provider.dart';
import 'package:farm_vest/features/auth/data/repositories/auth_repository.dart';
import 'package:farm_vest/features/investor/data/models/visit_model.dart';
import 'package:farm_vest/features/investor/data/models/visit_params.dart';
import 'package:farm_vest/features/investor/presentation/providers/visit_provider.dart';
import 'package:farm_vest/features/investor/presentation/widgets/monthly_visits/visit_date_strip.dart';
import 'package:farm_vest/features/investor/presentation/widgets/monthly_visits/visit_farm_selector.dart';
import 'package:farm_vest/features/investor/presentation/widgets/monthly_visits/visit_legend.dart';
import 'package:farm_vest/features/investor/presentation/widgets/monthly_visits/visit_slot_summary.dart';
import 'package:farm_vest/features/investor/presentation/widgets/monthly_visits/visit_time_grid.dart';
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
  InvestorFarm? _selectedFarm;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Fetch Farms
    final farmsAsync = ref.watch(investorFarmsProvider);

    // Auto-select if only one farm is available
    ref.listen<AsyncValue<List<InvestorFarm>>>(investorFarmsProvider, (
      previous,
      next,
    ) {
      next.whenData((farms) {
        if (farms.length == 1 && _selectedFarm == null) {
          setState(() {
            _selectedFarm = farms.first;
          });
        }
      });
    });

    // Handle initial load auto-selection
    if (_selectedFarm == null &&
        farmsAsync.hasValue &&
        farmsAsync.value != null &&
        farmsAsync.value!.length == 1) {
      Future.microtask(() {
        if (mounted && _selectedFarm == null) {
          setState(() {
            _selectedFarm = farmsAsync.value!.first;
          });
        }
      });
    }

    // Fetch Availability only if farm is selected
    AsyncValue<VisitAvailability>? availabilityAsync;
    if (_selectedFarm != null) {
      availabilityAsync = ref.watch(
        visitAvailabilityProvider(
          VisitAvailabilityParams(
            date: DateFormat('yyyy-MM-dd').format(_selectedDate),
            farmId: _selectedFarm!.farmId,
          ),
        ),
      );
    }

    // User History Request (to check if already booked)
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
          // Farm Selection Dropdown
          VisitFarmSelector(
            farmsAsync: farmsAsync,
            selectedFarm: _selectedFarm,
            onFarmSelected: (farm) {
              setState(() {
                _selectedFarm = farm;
                _selectedSlotTime = null; // Reset slot on farm change
              });
            },
            theme: theme,
          ),

          if (_selectedFarm != null && availabilityAsync != null) ...[
            // Summary Card
            VisitSlotSummary(
              asyncData: availabilityAsync,
              hasBooked: hasBookedThisMonth,
              selectedDate: _selectedDate,
            ),

            // Date Strip
            VisitDateStrip(
              selectedDate: _selectedDate,
              onDateSelected: (date) {
                setState(() {
                  _selectedDate = date;
                  _selectedSlotTime = null; // Reset selection
                });
              },
              theme: theme,
              isDark: isDark,
            ),

            const SizedBox(height: 24),

            // Slots Grid
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
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
                                color: isDark
                                    ? AppTheme.white
                                    : AppTheme.black87,
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
                      const SizedBox(height: 12),
                      Expanded(
                        child: availabilityAsync.when(
                          data: (data) => VisitTimeGrid(
                            availableSlots: data.availableSlots,
                            selectedSlotTime: _selectedSlotTime,
                            selectedDate: _selectedDate,
                            hasBookedThisMonth: hasBookedThisMonth,
                            isDark: isDark,
                            onSlotSelected: (time) {
                              setState(() {
                                _selectedSlotTime = time;
                              });
                              _showBookingConfirmation(time);
                            },
                            // key: theme,
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
                      const VisitLegend(),
                    ],
                  ),
                ),
              ),
            ),
          ] else if (_selectedFarm == null) ...[
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.agriculture, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      farmsAsync.isLoading
                          ? "Loading farms..."
                          : "Please select a farm to continue",
                      style: AppTheme.bodyLarge.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
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
              ),
              const SizedBox(height: 16),
              Text(
                "You are booking a visit at ${_selectedFarm?.farmName ?? ''} on:",
                style: AppTheme.bodyMedium.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_month_outlined,
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

    if (_selectedFarm == null) {
      ToastUtils.showError(context, "Please select a farm first");
      return;
    }

    // Format time to HH:mm if API expects that
    String formattedTime = time;
    try {
      final dt = DateFormat("HH:mm:ss").parse(time);
      formattedTime = DateFormat("HH:mm").format(dt);
    } catch (e) {
      // failed parse
    }

    final request = VisitBookingRequest(
      farmId: _selectedFarm!.farmId,
      startTime: formattedTime,
      visitDate: DateFormat('yyyy-MM-dd').format(_selectedDate),
    );

    Navigator.pop(context); // close confirmation sheet

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final repository = AuthRepository();
      final token = await repository.getToken();

      final visit = await VisitsApiServices.bookVisit(request, token!);

      if (!mounted) return;
      Navigator.pop(context); // close loading

      // Refresh history
      ref.invalidate(myVisitsProvider);
      // Refresh availability
      ref.invalidate(
        visitAvailabilityProvider(
          VisitAvailabilityParams(
            date: DateFormat('yyyy-MM-dd').format(_selectedDate),
            farmId: _selectedFarm!.farmId,
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
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
                const SizedBox(height: 8),
                Text(
                  (visit.farmName != null && visit.farmLocation != null)
                      ? "${visit.farmName}, ${visit.farmLocation}"
                      : (visit.farmName ??
                            visit.farmLocation ??
                            "Unknown Farm"),
                  style: AppTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                _buildQrCode(visit),
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
        data: visit.visitId,
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
                                  Icons.calendar_month_outlined,
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
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_formatTimeWithAmPm(visit.startTime)),
                                  if (visit.farmName != null ||
                                      visit.farmLocation != null)
                                    Text(
                                      (visit.farmName != null &&
                                              visit.farmLocation != null)
                                          ? "${visit.farmName}, ${visit.farmLocation}"
                                          : (visit.farmName ??
                                                visit.farmLocation ??
                                                ""),
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                ],
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
      final dt = DateFormat("HH:mm").parse(time);
      return DateFormat("h:mm a").format(dt);
    } catch (e) {
      try {
        final dt = DateFormat("HH:mm:ss").parse(time);
        return DateFormat("h:mm a").format(dt);
      } catch (e2) {
        return time;
      }
    }
  }
}
