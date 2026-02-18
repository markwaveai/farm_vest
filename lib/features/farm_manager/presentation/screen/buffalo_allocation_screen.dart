import 'package:farm_vest/core/services/animal_api_services.dart';
import 'package:farm_vest/core/services/sheds_api_services.dart';
import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/core/utils/app_enums.dart';
import 'package:farm_vest/features/auth/presentation/providers/auth_provider.dart';
import 'package:farm_vest/features/farm_manager/presentation/providers/farm_manager_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/farm_manager_dashboard_model.dart';
import '../../data/models/shed_model.dart';
import 'package:farm_vest/features/farm_manager/data/models/allocated_animal_details.dart';
import 'package:farm_vest/core/theme/app_constants.dart';

class BuffaloAllocationScreen extends ConsumerStatefulWidget {
  final int? initialFarmId;
  final int? initialShedId;
  final String? targetParkingId;
  final String? initialAnimalId;
  final bool hideAppBar;

  const BuffaloAllocationScreen({
    super.key,
    this.initialShedId,
    this.targetParkingId,
    this.initialAnimalId,
    this.initialFarmId,
    this.hideAppBar = false,
  });

  @override
  ConsumerState<BuffaloAllocationScreen> createState() =>
      _BuffaloAllocationScreenState();
}

class _BuffaloAllocationScreenState
    extends ConsumerState<BuffaloAllocationScreen> {
  // Local state to track allocations before finalizing
  // Key: shedId, Value: { "row-slot": animalId }
  Map<int, Map<String, String>> allDraftAllocations = {};
  String? selectedAnimalId;
  int? selectedShedId;
  int? selectedFarmId; // To track the selected farm
  final ScrollController _shedScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.initialFarmId != null) {
      selectedFarmId = widget.initialFarmId;
    }

    if (widget.initialShedId != null) {
      selectedShedId = widget.initialShedId;
    }
    if (widget.initialAnimalId != null) {
      selectedAnimalId = widget.initialAnimalId;
    }

    Future.microtask(() {
      // Clear stale state from previous visits
      ref.read(farmManagerProvider.notifier).resetAllocationState();

      final authState = ref.read(authProvider);
      final farmId = int.tryParse(authState.userData?.farmId ?? '');
      ref.read(farmManagerProvider.notifier).fetchSheds(farmId: farmId);
      ref
          .read(farmManagerProvider.notifier)
          .fetchUnallocatedAnimals(farmId: farmId);

      if (selectedShedId != null) {
        ref
            .read(farmManagerProvider.notifier)
            .fetchShedPositions(selectedShedId!);
      }
    });

    _shedScrollController.addListener(() {
      if (_shedScrollController.position.pixels >=
          _shedScrollController.position.maxScrollExtent - 200) {
        final authState = ref.read(authProvider);
        final farmId = int.tryParse(authState.userData?.farmId ?? '');
        ref.read(farmManagerProvider.notifier).fetchMoreSheds(farmId: farmId);
      }
    });
  }

  @override
  void dispose() {
    _shedScrollController.dispose();
    super.dispose();
  }

  void _onShedSelected(int? shedId) {
    if (shedId == null) return;
    setState(() {
      selectedShedId = shedId;
      selectedAnimalId = null;
    });
    ref.read(farmManagerProvider.notifier).fetchShedPositions(shedId);
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(farmManagerProvider);
    final onboardedAnimals = dashboardState.onboardedAnimalIds;
    final authState = ref.watch(authProvider);
    final userRole = authState.role;

    // Auto-select first shed if available and none selected
    ref.listen<FarmManagerDashboardState>(farmManagerProvider, (
      previous,
      next,
    ) {
      if (selectedShedId == null && next.sheds.isNotEmpty && !next.isLoading) {
        final userShedId = int.tryParse(authState.userData?.shedId ?? '');

        int? autoShedId;
        if (userRole == UserType.supervisor && userShedId != null) {
          try {
            final supervisorShed = next.sheds.firstWhere(
              (s) => s.id == userShedId,
            );
            autoShedId = supervisorShed.id;
          } catch (_) {}
        }

        // If still no autoShedId and we only have one shed, or it's first load
        if (autoShedId == null) {
          if (userRole == UserType.supervisor) {
            autoShedId = next.sheds.first.id;
          } else if (next.sheds.length == 1) {
            autoShedId = next.sheds.first.id;
          }
        }

        if (autoShedId != null && selectedShedId == null) {
          _onShedSelected(autoShedId);
        }
      }
    });

    // Initial check for already loaded state
    if (selectedShedId == null &&
        !dashboardState.isLoading &&
        dashboardState.sheds.isNotEmpty) {
      final userShedId = int.tryParse(authState.userData?.shedId ?? '');
      int? autoShedId;
      if (userRole == UserType.supervisor && userShedId != null) {
        try {
          final supervisorShed = dashboardState.sheds.firstWhere(
            (s) => s.id == userShedId,
          );
          autoShedId = supervisorShed.id;
        } catch (_) {}
      }

      if (autoShedId == null &&
          (userRole == UserType.supervisor ||
              dashboardState.sheds.length == 1)) {
        autoShedId = dashboardState.sheds.first.id;
      }

      if (autoShedId != null) {
        Future.microtask(() => _onShedSelected(autoShedId!));
      }
    }

    String appBarTitle = 'Shed Allocation';
    if (userRole == UserType.farmManager &&
        selectedShedId != null &&
        dashboardState.sheds.isNotEmpty) {
      final shed = dashboardState.sheds.firstWhere(
        (s) => s.id == selectedShedId,
        orElse: () => dashboardState.sheds.first,
      );
      appBarTitle = 'Shed: ${shed.shedName}';
    }

    return Scaffold(
      extendBodyBehindAppBar: !widget.hideAppBar,
      appBar: widget.hideAppBar
          ? null
          : AppBar(
              title: Text(
                appBarTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              centerTitle: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: Container(
                margin: const EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      if (userRole == UserType.supervisor) {
                        context.go('/supervisor-dashboard');
                      } else {
                        context.go('/farm-manager-dashboard');
                      }
                    }
                  },
                ),
              ),
              actions: [
                if (selectedShedId != null &&
                    dashboardState.sheds.isNotEmpty &&
                    !dashboardState.isLoading)
                  IconButton(
                    icon: const Icon(
                      Icons.videocam_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      final shed = dashboardState.sheds.firstWhere(
                        (s) => s.id == selectedShedId,
                      );
                      _showCctvUrlDialog(shed);
                    },
                  ),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                  onPressed: () {
                    if (selectedShedId != null) {
                      ref
                          .read(farmManagerProvider.notifier)
                          .fetchShedPositions(selectedShedId!);
                    }
                  },
                ),
                // Finalize button visible for both Manager and Supervisor
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.check_rounded),
                    onPressed: _finalizeAllocations,
                    color: Colors.blueGrey,
                  ),
                ),
              ],
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppTheme.primary.withOpacity(0.9),
                      AppTheme.primary.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primary.withOpacity(0.05),
              Colors.blueGrey.shade50.withOpacity(0.5),
            ],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 100), // Space for transparent AppBar
            // Shed Selector
            _buildShedSelector(dashboardState),

            if (selectedShedId == null)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.warehouse_rounded,
                        size: 64,
                        color: AppTheme.grey1.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Please select a shed to start allocation',
                        style: TextStyle(color: AppTheme.grey1, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              )
            else if (dashboardState.isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (dashboardState.currentShedAvailability != null) ...[
              // Header Stats Card
              _buildStatsHeader(dashboardState.currentShedAvailability!),

              // Pending Animals Tray visible for both Manager and Supervisor
              if (onboardedAnimals.isNotEmpty)
                _buildPendingAnimalsTray(onboardedAnimals),

              // Shed Grid - Row Carousel
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 12, 0, 24),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    itemCount:
                        dashboardState.currentShedAvailability!.rows.length,
                    itemBuilder: (context, index) {
                      final entry = dashboardState
                          .currentShedAvailability!
                          .rows
                          .entries
                          .elementAt(index);
                      return SizedBox(
                        width: MediaQuery.of(context).size.width * 0.45,
                        child: _buildGlassColumn(entry.key, entry.value),
                      );
                    },
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildShedSelector(FarmManagerDashboardState state) {
    final authState = ref.watch(authProvider);
    final userShedId = int.tryParse(authState.userData?.shedId ?? '');

    // Filter sheds for Supervisor role: only show their assigned shed
    final List<Shed> displayedSheds =
        (authState.role == UserType.supervisor && userShedId != null)
        ? state.sheds.where((s) => s.id == userShedId).toList()
        : state.sheds;

    // If it's a supervisor or there's only one shed, hide the selector
    if (authState.role == UserType.supervisor || displayedSheds.length <= 1) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text(
            'SELECT SHED UNIT',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppTheme.grey1,
              letterSpacing: 1.2,
            ),
          ),
        ),
        SizedBox(
          height: 80,
          child: ListView.builder(
            controller: _shedScrollController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: displayedSheds.length + (state.hasMoreSheds ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == displayedSheds.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }

              final shed = displayedSheds[index];
              final isSelected = selectedShedId == shed.id;

              return Padding(
                padding: const EdgeInsets.only(right: 12, bottom: 8),
                child: GestureDetector(
                  onTap: () => _onShedSelected(shed.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 150,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primary : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: (isSelected ? AppTheme.primary : Colors.black)
                              .withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primary
                            : AppTheme.primary.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          shed.shedName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: isSelected ? Colors.white : AppTheme.dark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${shed.availablePositions} left',
                          style: TextStyle(
                            fontSize: 10,
                            color: isSelected
                                ? Colors.white.withOpacity(0.9)
                                : AppTheme.grey1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showCctvUrlDialog(Shed shed) {
    // Initial State - Config
    final Map<String, dynamic> config = Map.from(
      shed.cameraConfig ?? {'groups': []},
    );
    if (config['groups'] == null) config['groups'] = [];
    final List<dynamic> groups = List.from(config['groups']);

    // Ensure groups list has size 15 for 300 capacity (20 per group)
    while (groups.length < 15) {
      groups.add({'urls': []});
    }

    int selectedGroupIdx = -1; // -1 = Global Fallback

    // Controllers
    final c1 = TextEditingController(text: shed.cctvUrl);
    final c2 = TextEditingController(text: shed.cctvUrl2);
    final c3 = TextEditingController(text: shed.cctvUrl3);
    final c4 = TextEditingController(text: shed.cctvUrl4);

    // Temp storage for Global values to persist edits before saving
    String? globalC1 = shed.cctvUrl;
    String? globalC2 = shed.cctvUrl2;
    String? globalC3 = shed.cctvUrl3;
    String? globalC4 = shed.cctvUrl4;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            void saveCurrentToMemory() {
              if (selectedGroupIdx == -1) {
                globalC1 = c1.text.trim().isEmpty ? null : c1.text.trim();
                globalC2 = c2.text.trim().isEmpty ? null : c2.text.trim();
                globalC3 = c3.text.trim().isEmpty ? null : c3.text.trim();
                globalC4 = c4.text.trim().isEmpty ? null : c4.text.trim();
              } else {
                groups[selectedGroupIdx] = {
                  'urls': [
                    c1.text.trim().isEmpty ? null : c1.text.trim(),
                    c2.text.trim().isEmpty ? null : c2.text.trim(),
                    c3.text.trim().isEmpty ? null : c3.text.trim(),
                    c4.text.trim().isEmpty ? null : c4.text.trim(),
                  ],
                };
              }
            }

            return AlertDialog(
              title: const Text('Assign CCTV Angles'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Configure Global (Default) cameras or specific blocks (20 animals each).',
                      style: TextStyle(fontSize: 12, color: AppTheme.grey1),
                    ),
                    const SizedBox(height: 12),
                    DropdownButton<int>(
                      value: selectedGroupIdx,
                      isExpanded: true,
                      items: [
                        const DropdownMenuItem(
                          value: -1,
                          child: Text("Global (Default)"),
                        ),
                        ...List.generate(
                          15,
                          (i) => DropdownMenuItem(
                            value: i,
                            child: Text(
                              "Block ${i + 1} (Slots ${i * 20 + 1}-${(i + 1) * 20})",
                            ),
                          ),
                        ),
                      ],
                      onChanged: (val) {
                        if (val == null) return;
                        saveCurrentToMemory();
                        setState(() {
                          selectedGroupIdx = val;
                          if (val == -1) {
                            c1.text = globalC1 ?? '';
                            c2.text = globalC2 ?? '';
                            c3.text = globalC3 ?? '';
                            c4.text = globalC4 ?? '';
                          } else {
                            final g = groups[val];
                            final urls = (g['urls'] as List?) ?? [];
                            c1.text = (urls.length > 0 ? urls[0] : '') ?? '';
                            c2.text = (urls.length > 1 ? urls[1] : '') ?? '';
                            c3.text = (urls.length > 2 ? urls[2] : '') ?? '';
                            c4.text = (urls.length > 3 ? urls[3] : '') ?? '';
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildCctvField(c1, 'Angle 1'),
                    const SizedBox(height: 8),
                    _buildCctvField(c2, 'Angle 2'),
                    const SizedBox(height: 8),
                    _buildCctvField(c3, 'Angle 3'),
                    const SizedBox(height: 8),
                    _buildCctvField(c4, 'Angle 4'),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    c1.text = 'http://161.97.182.208:8888/stream1/index.m3u8';
                    c2.text = 'http://161.97.182.208:8888/stream2/index.m3u8';
                    c3.text = 'http://161.97.182.208:8888/stream3/index.m3u8';
                    c4.text = 'http://161.97.182.208:8888/stream4/index.m3u8';
                  },
                  child: const Text('Fill Test URLs'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    saveCurrentToMemory();
                    // Construct body
                    final body = {
                      'cctv_url': globalC1,
                      'cctv_url_2': globalC2,
                      'cctv_url_3': globalC3,
                      'cctv_url_4': globalC4,
                      'camera_config': {'groups': groups},
                    };

                    try {
                      final prefs = await SharedPreferences.getInstance();
                      final token = prefs.getString('access_token');
                      if (token == null) return;

                      final success = await ShedsApiServices.updateShed(
                        token: token,
                        shedId: shed.id,
                        body: body,
                      );

                      if (success && mounted) {
                        Navigator.pop(context);
                        ref
                            .read(farmManagerProvider.notifier)
                            .fetchSheds(farmId: selectedFarmId ?? null);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('CCTV Configuration Updated'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Failed to update configuration'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } catch (e) {
                      // Ignore
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildCctvField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: 'rtsp://... or https://...',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildStatsHeader(ShedPositionResponse availability) {
    int totalOccupied = 0;
    availability.rows.values.forEach((r) => totalOccupied += r.filled.length);

    final currentDraft = allDraftAllocations[selectedShedId] ?? {};
    final totalAllocatedInAllSheds = allDraftAllocations.values.fold(
      0,
      (sum, draft) => sum + draft.length,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.8)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildPremiumStat(
            'Capacity',
            '${availability.totalPositions}',
            Icons.grid_view_rounded,
            Colors.blue,
          ),
          Container(height: 40, width: 1, color: Colors.grey.shade300),
          _buildPremiumStat(
            'Shed Pick',
            '${totalOccupied + currentDraft.length}',
            Icons.pets_rounded,
            AppTheme.successGreen,
          ),
          Container(height: 40, width: 1, color: Colors.grey.shade300),
          _buildPremiumStat(
            'Total Draft',
            '$totalAllocatedInAllSheds',
            Icons.assignment_turned_in_rounded,
            AppTheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildPendingAnimalsTray(List<dynamic> onboardedAnimals) {
    // Determine the ID to use for filtering. If map, use animal_id or rfid. If string, use string
    final allAllocatedIds = allDraftAllocations.values
        .expand((d) => d.values)
        .toSet();

    final pendingAnimals = onboardedAnimals.where((animal) {
      final id = (animal is Map)
          ? (animal['rfid_tag'] ??
                animal['rfid'] ??
                animal['rfid_tag_number'] ??
                animal['animal_id'])
          : animal.toString();
      return !allAllocatedIds.contains(id.toString());
    }).toList();

    return Container(
      height: 120, // Increased height for investor name
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Select Animal to Allocate',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.grey1,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: pendingAnimals.length,
              itemBuilder: (context, index) {
                final animalData = pendingAnimals[index];

                // Extract Identifiers
                // Extract Identifiers - Prioritize RFID/Tag for uniqueness in UI
                final String id = (animalData is Map)
                    ? (animalData['rfid_tag'] ??
                              animalData['rfid'] ??
                              animalData['rfid_tag_number'] ??
                              animalData['animal_id'] ??
                              animalData.toString())
                          .toString()
                    : animalData.toString();

                final String displayRfid = (animalData is Map)
                    ? (animalData['rfid_tag'] ?? animalData['rfid'] ?? id)
                          .toString()
                    : id;

                final String investorName = (animalData is Map)
                    ? (animalData['investor_name'] ?? 'Unknown')
                    : 'Unassigned';

                // Onboarded Date Parsing
                final String onboardedAtRaw = (animalData is Map)
                    ? (animalData['onboarded_at'] ?? '')
                    : '';
                String onboardedTime = '';
                if (onboardedAtRaw.isNotEmpty) {
                  try {
                    final dt = DateTime.parse(onboardedAtRaw).toLocal();
                    int hour = dt.hour;
                    final String amPm = hour >= 12 ? 'PM' : 'AM';
                    if (hour > 12) hour -= 12;
                    if (hour == 0) hour = 12;
                    onboardedTime =
                        "${dt.day}/${dt.month} $hour:${dt.minute.toString().padLeft(2, '0')} $amPm";
                  } catch (_) {}
                }

                String? imageUrl;
                if (animalData is Map &&
                    animalData['images'] is List &&
                    (animalData['images'] as List).isNotEmpty) {
                  imageUrl = animalData['images'][0];
                }

                final isSelected = selectedAnimalId == id;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedAnimalId = isSelected ? null : id;
                    });
                  },
                  child: Container(
                    width: 100, // Widened for name
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primary : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primary
                            : AppTheme.primary.withOpacity(0.2),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (imageUrl != null)
                          Container(
                            width: 80,
                            height: 45,
                            margin: const EdgeInsets.only(bottom: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: isSelected
                                  ? Colors.white.withOpacity(0.1)
                                  : Colors.grey.shade50,
                              image: DecorationImage(
                                image: NetworkImage(imageUrl),
                                fit: BoxFit.contain,
                              ),
                            ),
                          )
                        else
                          Icon(
                            Icons.pets_rounded,
                            color: isSelected ? Colors.white : AppTheme.primary,
                            size: 20,
                          ),
                        if (imageUrl == null) const SizedBox(height: 4),
                        Text(
                          displayRfid.contains('-')
                              ? displayRfid.split('-').last
                              : displayRfid,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : AppTheme.dark,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          investorName.split(' ').first,
                          style: TextStyle(
                            fontSize: 9,
                            color: isSelected
                                ? Colors.white.withOpacity(0.8)
                                : AppTheme.grey1,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (onboardedTime.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            onboardedTime,
                            style: TextStyle(
                              fontSize: 8,
                              color: isSelected
                                  ? Colors.white.withOpacity(0.8)
                                  : AppTheme.grey1,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumStat(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.dark.withOpacity(0.9),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppTheme.grey1,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildGlassColumn(String rowName, RowAvailability rowData) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            width: double.infinity,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.videocam_rounded,
                      size: 14,
                      color: AppTheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        'ROW $rowName',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: AppTheme.primary,
                          fontSize: 12,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(backgroundColor: Colors.red, radius: 3),
                    SizedBox(width: 6),
                    Text(
                      'LIVE FEED',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.grey1,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: rowData.available.length + rowData.filled.length,
                itemBuilder: (context, slotIndex) {
                  // Reconstruct position ID (e.g., A1, B2)
                  // Note: The API returns lists. Let's find if this position is filled.
                  // For UI simplicity, we'll map indices to the lists.
                  final allPositions = [
                    ...rowData.filled,
                    ...rowData.available,
                  ];
                  allPositions.sort((String a, String b) {
                    final numA =
                        int.tryParse(a.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
                    final numB =
                        int.tryParse(b.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
                    return numA.compareTo(numB);
                  });

                  // Ensure we don't go out of bounds
                  if (slotIndex >= allPositions.length) return const SizedBox();

                  final posId = allPositions[slotIndex];
                  final isFilled = rowData.filled.contains(posId);
                  final details = ref
                      .read(farmManagerProvider)
                      .currentShedAvailability
                      ?.slotDetails[posId];

                  return _buildModernSlotItem(
                    rowName,
                    posId,
                    isFilled,
                    details != null ? Map<String, dynamic>.from(details) : null,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernSlotItem(
    String rowName,
    String posId,
    bool isOccupied, [
    Map<String, dynamic>? details,
  ]) {
    final slotKey = '$rowName-$posId';
    final currentDraft = allDraftAllocations[selectedShedId] ?? {};
    final draftAnimalId = currentDraft[slotKey];
    final isBeingAllocated = draftAnimalId != null;

    final String targetId = (widget.targetParkingId ?? '').trim().toUpperCase();
    final String currentPos = posId.trim().toUpperCase();
    final String currentRowPos = '$rowName$currentPos'.toUpperCase();

    // Check if target ID matches (exact, endsWith, or contains Row+Slot)
    final isTarget =
        targetId.isNotEmpty &&
        (targetId == currentPos ||
            targetId.endsWith(currentPos) ||
            targetId.endsWith('-$currentPos') ||
            targetId.contains(currentRowPos));

    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: 0,
            child: Center(
              child: Container(
                width: 2,
                color: (isOccupied || isBeingAllocated)
                    ? AppTheme.primary.withOpacity(0.3)
                    : Colors.grey.withOpacity(0.2),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: (isOccupied || isBeingAllocated)
                  ? Colors.white
                  : Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),

              border: Border.all(
                color: isBeingAllocated
                    ? AppTheme.secondary
                    : isTarget
                    ? Colors
                          .green // Highlight target with GREEN
                    : isOccupied
                    ? AppTheme.primary.withOpacity(0.1)
                    : Colors.transparent,
                width: (isBeingAllocated || isTarget)
                    ? 3
                    : 1.5, // Thicker border for target
              ),
              boxShadow: (isOccupied || isBeingAllocated || isTarget)
                  ? [
                      BoxShadow(
                        color:
                            (isBeingAllocated
                                    ? AppTheme.secondary
                                    : isTarget
                                    ? Colors
                                          .green // GREEN shadow for target
                                    : AppTheme.primary)
                                .withValues(
                                  alpha: 0.3,
                                ), // Stronger shadow for target
                        blurRadius: isTarget ? 16 : 12,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : [],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  if (isOccupied) {
                    debugPrint('Tapped occupied slot: $posId');

                    try {
                      // Lookup selected shed to get name/code
                      if (selectedShedId == null) return;
                      final sheds = ref.read(farmManagerProvider).sheds;
                      final shed = sheds.firstWhere(
                        (s) => s.id == selectedShedId!,
                        orElse: () => sheds.first,
                      );

                      final rowNum = rowName;

                      final token = await ref
                          .read(authProvider.notifier)
                          .getToken();
                      if (token != null && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Fetching animal details...'),
                            duration: Duration(milliseconds: 500),
                          ),
                        );

                        final detailsMap =
                            await AnimalApiServices.getAnimalByPosition(
                              token: token,
                              farmId: shed.farmId,
                              shedId: shed.id,
                              rowNumber: rowNum,
                              parkingId: posId,
                            );

                        if (mounted && detailsMap != null) {
                          final details = AllocatedAnimalDetails.fromJson(
                            detailsMap,
                          );
                          _showAllocatedAnimalDetails(details);
                        }
                      }
                    } catch (e) {
                      debugPrint("Error fetching details: $e");
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to load details: $e')),
                        );
                      }
                    }
                    return;
                  }

                  setState(() {
                    if (isBeingAllocated) {
                      // Remove from draft
                      if (allDraftAllocations.containsKey(selectedShedId)) {
                        allDraftAllocations[selectedShedId]!.remove(slotKey);
                        if (allDraftAllocations[selectedShedId]!.isEmpty) {
                          allDraftAllocations.remove(selectedShedId);
                        }
                      }
                    } else if (selectedAnimalId != null &&
                        selectedShedId != null) {
                      // Allocate selected animal to this slot
                      if (!allDraftAllocations.containsKey(selectedShedId)) {
                        allDraftAllocations[selectedShedId!] = {};
                      }
                      allDraftAllocations[selectedShedId]![slotKey] =
                          selectedAnimalId!;
                      selectedAnimalId = null;
                    }
                  });
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isOccupied) ...[
                        Icon(
                          Icons.pets,
                          size: 16,
                          color: isTarget ? Colors.green : AppTheme.primary,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          posId,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: isTarget ? Colors.green : AppTheme.primary,
                          ),
                        ),
                      ] else if (isBeingAllocated) ...[
                        Icon(
                          Icons.add_location_alt_rounded,
                          size: 16,
                          color: isTarget ? Colors.green : AppTheme.secondary,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          draftAnimalId.split('-').last,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.secondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ] else ...[
                        Text(
                          posId,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isTarget
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: isTarget
                                ? Colors.red
                                : AppTheme.grey1.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAllocatedAnimalDetails(AllocatedAnimalDetails data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Allocated Animal Details'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Animal Details
                const Text(
                  'Animal Information',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Divider(),
                if (data.animalDetails.images.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 0.5,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          data.animalDetails.images.first,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(
                                child: Icon(
                                  Icons.error_outline,
                                  color: Colors.grey,
                                ),
                              ),
                        ),
                      ),
                    ),
                  ),
                _buildDetailRow(
                  'Animal ID',
                  data.animalDetails.animalId.toString(),
                ),
                _buildDetailRow('Breed', data.animalDetails.breedName ?? 'N/A'),
                _buildDetailRow('Status', data.animalDetails.status ?? 'N/A'),
                _buildDetailRow(
                  'Health Status',
                  data.animalDetails.healthStatus ?? 'N/A',
                ),
                _buildDetailRow(
                  'Age (Months)',
                  data.animalDetails.ageMonths?.toString() ?? 'N/A',
                ),
                _buildDetailRow('RFID Tag', data.animalDetails.rfidTagNumber),
                _buildDetailRow('Ear Tag', data.animalDetails.earTag ?? 'N/A'),
                _buildDetailRow('Row', data.animalDetails.rowNumber ?? 'N/A'),
                _buildDetailRow('Slot', data.animalDetails.parkingId ?? 'N/A'),
                _buildDetailRow(
                  'Onboarded',
                  AppConstants.formatDateTime(data.animalDetails.onboardedAt),
                ),

                const SizedBox(height: 16),

                // Investor Details
                const Text(
                  'Investor Details',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Divider(),
                _buildDetailRow('Name', data.investorDetails.fullName),
                _buildDetailRow('Mobile', data.investorDetails.mobile),
                _buildDetailRow('Email', data.investorDetails.email ?? 'N/A'),

                const SizedBox(height: 16),

                // Farm & Shed Details
                const Text(
                  'Location Details',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Divider(),
                _buildDetailRow('Farm', data.farmDetails.farmName),
                _buildDetailRow('Location', data.farmDetails.location),
                _buildDetailRow('Shed', data.shedDetails.shedName),
                _buildDetailRow(
                  'Current Buffaloes',
                  data.shedDetails.buffaloesCount.toString(),
                ),
                _buildDetailRow(
                  'Capacity',
                  data.shedDetails.capacity.toString(),
                ),

                const SizedBox(height: 16),

                // Assigned Staff
                const Text(
                  'Assigned Staff',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Divider(),

                if (data.farmManager != null) ...[
                  const Text(
                    'Farm Manager',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppTheme.primary,
                    ),
                  ),
                  _buildDetailRow('Name', data.farmManager!.fullName),
                  _buildDetailRow('Mobile', data.farmManager!.mobile),
                  const SizedBox(height: 8),
                ],

                if (data.supervisor != null) ...[
                  const Text(
                    'Supervisor',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppTheme.primary,
                    ),
                  ),
                  _buildDetailRow('Name', data.supervisor!.fullName),
                  _buildDetailRow('Mobile', data.supervisor!.mobile),
                  const SizedBox(height: 8),
                ],

                if (data.doctor != null) ...[
                  const Text(
                    'Doctor',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppTheme.primary,
                    ),
                  ),
                  _buildDetailRow('Name', data.doctor!.fullName),
                  _buildDetailRow('Mobile', data.doctor!.mobile),
                  const SizedBox(height: 8),
                ],

                if (data.assistantDoctor != null) ...[
                  const Text(
                    'Assistant Doctor',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppTheme.primary,
                    ),
                  ),
                  _buildDetailRow('Name', data.assistantDoctor!.fullName),
                  _buildDetailRow('Mobile', data.assistantDoctor!.mobile),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                color: AppTheme.grey1,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _finalizeAllocations() async {
    final totalDraftCount = allDraftAllocations.values.fold(
      0,
      (sum, draft) => sum + draft.length,
    );

    // 1. Validate Selection
    if (totalDraftCount == 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No animals selected for allocation'),
            backgroundColor: AppTheme.warningOrange,
          ),
        );
      }
      return;
    }

    final onboardedAnimals = ref.read(farmManagerProvider).onboardedAnimalIds;

    // 2. Incomplete Allocation Warning
    if (totalDraftCount < onboardedAnimals.length) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Incomplete Allocation'),
          content: Text(
            'You have ${onboardedAnimals.length - totalDraftCount} animals left to allocate. Do you want to proceed anyway?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Proceed'),
            ),
          ],
        ),
      );
      if (confirm != true) return;
    }

    final dashboardState = ref.read(farmManagerProvider);
    bool overallSuccess = true;
    int successCount = 0;
    int failCount = 0;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final shedsToProcess = allDraftAllocations.keys.toList();

      for (final shedId in shedsToProcess) {
        final currentShedDraft = allDraftAllocations[shedId]!;
        final selectedShed = dashboardState.sheds
            .where((s) => s.id == shedId)
            .firstOrNull;

        if (selectedShed == null) {
          failCount++;
          continue;
        }

        bool shedAllSuccess = true;

        for (var e in currentShedDraft.entries) {
          final parts = e.key.split('-'); // e.g. ["R1", "A4"]
          final rowId = parts[0]; // "R1"
          final slotId = parts[1]; // "A4"

          final String draftIdentifier = e.value;
          final animalObj = onboardedAnimals.firstWhere((a) {
            final aId = (a is Map)
                ? (a['rfid_tag'] ??
                      a['rfid'] ??
                      a['rfid_tag_number'] ??
                      a['animal_id'])
                : a.toString();
            return aId.toString() == draftIdentifier;
          }, orElse: () => <String, dynamic>{});

          // Get numeric animal_id/id
          String realAnimalId = draftIdentifier;
          if (animalObj is Map) {
            realAnimalId =
                (animalObj['animal_id'] ?? animalObj['id'] ?? draftIdentifier)
                    .toString();
          }

          // Clean rowNumber (e.g. "R1" -> "1")
          final cleanRowNumber = rowId.replaceAll(RegExp(r'[^0-9]'), '');

          final success = await ref
              .read(farmManagerProvider.notifier)
              .allocateAnimals(
                shedId: shedId.toString(),
                rowNumber: rowId,
                animalId: realAnimalId,
                parkingId: slotId,
              );

          if (!success) {
            shedAllSuccess = false;
          }
        }

        if (shedAllSuccess) {
          successCount++;
        } else {
          overallSuccess = false;
          failCount++;
        }
      }
    } catch (e) {
      overallSuccess = false;
    }

    if (mounted) Navigator.pop(context); // Close loading dialog

    if (successCount > 0 && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            overallSuccess
                ? 'All animals allocated successfully across $successCount sheds!'
                : 'Allocated in $successCount sheds. $failCount sheds failed.',
          ),
          backgroundColor: overallSuccess
              ? AppTheme.successGreen
              : AppTheme.warningOrange,
        ),
      );

      // Clear all drafts
      setState(() {
        allDraftAllocations.clear();
      });

      // Refresh data
      if (selectedShedId != null) {
        ref
            .read(farmManagerProvider.notifier)
            .fetchShedPositions(selectedShedId!);
      }
      ref
          .read(farmManagerProvider.notifier)
          .fetchUnallocatedAnimals(farmId: selectedFarmId);
    } else if (mounted) {
      final error = ref.read(farmManagerProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Failed to allocate animals to any shed.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
