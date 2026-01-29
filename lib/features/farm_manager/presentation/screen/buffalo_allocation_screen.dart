import 'package:farm_vest/core/services/animal_api_services.dart';
import 'package:farm_vest/core/services/sheds_api_services.dart';
import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/core/utils/app_enums.dart';
import 'package:farm_vest/core/services/api_services.dart';
import 'package:farm_vest/features/auth/presentation/providers/auth_provider.dart';
import 'package:farm_vest/features/farm_manager/presentation/providers/farm_manager_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/farm_manager_dashboard_model.dart';
import '../../data/models/shed_model.dart';
import 'package:farm_vest/features/farm_manager/data/models/allocated_animal_details.dart';

class BuffaloAllocationScreen extends ConsumerStatefulWidget {
  final int? initialShedId;
  final String? targetParkingId;

  const BuffaloAllocationScreen({
    super.key,
    this.initialShedId,
    this.targetParkingId,
  });

  @override
  ConsumerState<BuffaloAllocationScreen> createState() =>
      _BuffaloAllocationScreenState();
}

class _BuffaloAllocationScreenState
    extends ConsumerState<BuffaloAllocationScreen> {
  // Local state to track allocations before finalizing
  // Key: "row-slot", Value: animalId
  Map<String, String> draftAllocations = {};
  String? selectedAnimalId;
  int? selectedShedId;
  int? selectedFarmId; // For Admin to select farm
  Future<List<Map<String, dynamic>>>? _farmsFuture;

  @override
  void initState() {
    super.initState();

    if (widget.initialShedId != null) {
      selectedShedId = widget.initialShedId;
    }

    Future.microtask(() {
      final authState = ref.read(authProvider);
      final userRole = authState.role;

      // Admin needs to select farm first
      if (userRole == UserType.admin) {
        setState(() {
          _farmsFuture = _fetchFarms(ref);
        });
      }

      // Only auto-fetch for Farm Manager and Supervisor
      // Admin needs to select farm first
      if (userRole != UserType.admin) {
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
      } else if (widget.initialShedId != null) {
        // For admin, we still might need to load the shed positions if initialShedId provided
        ref
            .read(farmManagerProvider.notifier)
            .fetchShedPositions(widget.initialShedId!);
      }
    });
  }

  void _onFarmSelected(int? farmId) {
    if (farmId == null) return;
    setState(() {
      selectedFarmId = farmId;
      selectedShedId = null;
      draftAllocations.clear();
      selectedAnimalId = null;
    });
    // Fetch sheds and animals for the selected farm
    ref.read(farmManagerProvider.notifier).fetchSheds(farmId: farmId);
    ref
        .read(farmManagerProvider.notifier)
        .fetchUnallocatedAnimals(farmId: farmId);
  }

  void _onShedSelected(int? shedId) {
    if (shedId == null) return;
    setState(() {
      selectedShedId = shedId;
      draftAllocations.clear();
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
    if (userRole == UserType.supervisor &&
        selectedShedId != null &&
        dashboardState.sheds.isNotEmpty) {
      final shed = dashboardState.sheds.firstWhere(
        (s) => s.id == selectedShedId,
        orElse: () => dashboardState.sheds.first,
      );
      appBarTitle = 'Shed: ${shed.shedName}';
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
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
            color: Colors.white.withValues(alpha: 0.2),
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
                if (userRole == UserType.admin) {
                  context.go('/admin-dashboard');
                } else if (userRole == UserType.supervisor) {
                  context.go('/supervisor-dashboard');
                } else {
                  context.go('/farm-manager-dashboard');
                }
              }
            },
          ),
        ),
        actions: [
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
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.check_rounded),
              onPressed: _finalizeAllocations,
              color: Colors.white,
            ),
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.primary.withValues(alpha: 0.9),
                AppTheme.primary.withValues(alpha: 0.0),
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
              AppTheme.primary.withValues(alpha: 0.05),
              Colors.blueGrey.shade50.withValues(alpha: 0.5),
            ],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 100), // Space for transparent AppBar
            // Farm Selector (Admin only)
            Consumer(
              builder: (context, ref, child) {
                final authState = ref.watch(authProvider);
                if (authState.role == UserType.admin) {
                  return _buildFarmSelector(ref);
                }
                return const SizedBox.shrink();
              },
            ),

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
                        color: AppTheme.grey1.withValues(alpha: 0.3),
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

              // Shed Grid
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
                  child: Row(
                    children: dashboardState
                        .currentShedAvailability!
                        .rows
                        .entries
                        .map((entry) {
                          return Expanded(
                            child: _buildGlassColumn(entry.key, entry.value),
                          );
                        })
                        .toList(),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFarmSelector(WidgetRef ref) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _farmsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Column(
              children: [
                Text(
                  'Error loading farms: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _farmsFuture = _fetchFarms(ref);
                    });
                  },
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final farms = snapshot.data ?? [];
        if (farms.isEmpty) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'No farms found. Access might be restricted.',
                    style: TextStyle(color: Colors.orange, fontSize: 13),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _farmsFuture = _fetchFarms(ref);
                    });
                  },
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
          );
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              isExpanded: true,
              hint: const Text('Select Farm'),
              value: selectedFarmId,
              items: farms.map((farm) {
                final farmId = int.tryParse(farm['id'].toString());
                return DropdownMenuItem<int>(
                  value: farmId,
                  child: Row(
                    children: [
                      const Icon(Icons.agriculture_rounded, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        farm['farm_name']?.toString() ?? 'Unnamed Farm',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: _onFarmSelected,
            ),
          ),
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _fetchFarms(WidgetRef ref) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null) throw Exception('No access token');

    return await ApiServices.getFarms(token: token);
  }

  Widget _buildShedSelector(FarmManagerDashboardState state) {
    final authState = ref.watch(authProvider);
    final userShedId = int.tryParse(authState.userData?.shedId ?? '');

    // Filter sheds for Supervisor role
    final List<Shed> displayedSheds =
        (authState.role == UserType.supervisor && userShedId != null)
        ? state.sheds.where((s) => s.id == userShedId).toList()
        : state.sheds;

    if (authState.role == UserType.supervisor && displayedSheds.length <= 1) {
      return const SizedBox.shrink();
    }

    final selectedShed = displayedSheds.isEmpty
        ? null
        : displayedSheds.firstWhere(
            (s) =>
                s.id ==
                (selectedShedId ??
                    (displayedSheds.isNotEmpty
                        ? displayedSheds.first.id
                        : null)),
            orElse: () => displayedSheds.first,
          );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  isExpanded: true,
                  hint: const Text('Select Shed'),
                  value: selectedShedId,
                  items: displayedSheds.map((shed) {
                    return DropdownMenuItem(
                      value: shed.id,
                      child: Row(
                        children: [
                          const Icon(Icons.warehouse_rounded, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '${shed.farmName} - ${shed.shedName}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${shed.availablePositions} left',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.grey1,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged:
                      (authState.role == UserType.supervisor &&
                          displayedSheds.length <= 1)
                      ? null // Disable if only one assigned shed
                      : _onShedSelected,
                ),
              ),
            ),
          ),
          if (selectedShedId != null && selectedShed != null) ...[
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.videocam_rounded, color: Colors.white),
                onPressed: () => _showCctvUrlDialog(selectedShed),
                tooltip: 'Set CCTV URL',
              ),
            ),
          ],
        ],
      ),
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
                            .fetchSheds(
                              farmId:
                                  selectedFarmId ??
                                  (ref.read(authProvider).role != UserType.admin
                                      ? null
                                      : selectedFarmId),
                            );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('CCTV Configuration Updated'),
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

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.1),
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
            'Allocated',
            '${totalOccupied + draftAllocations.length}',
            Icons.pets_rounded,
            AppTheme.successGreen,
          ),
          Container(height: 40, width: 1, color: Colors.grey.shade300),
          _buildPremiumStat(
            'Pending',
            '${(ref.read(farmManagerProvider).onboardedAnimalIds.length) - draftAllocations.length}',
            Icons.pending_actions_rounded,
            AppTheme.warningOrange,
          ),
        ],
      ),
    );
  }

  Widget _buildPendingAnimalsTray(List<dynamic> onboardedAnimals) {
    // Determine the ID to use for filtering. If map, use animal_id or rfid. If string, use string
    final pendingAnimals = onboardedAnimals.where((animal) {
      final id = (animal is Map)
          ? (animal['rfid_tag'] ??
                animal['rfid'] ??
                animal['rfid_tag_number'] ??
                animal['animal_id'])
          : animal.toString();
      return !draftAllocations.values.contains(id);
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
                    onboardedTime =
                        "${dt.day}/${dt.month} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
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
                            : AppTheme.primary.withValues(alpha: 0.2),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.1),
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
                            width: 40,
                            height: 40,
                            margin: const EdgeInsets.only(bottom: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: NetworkImage(imageUrl),
                                fit: BoxFit.cover,
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
                                ? Colors.white.withValues(alpha: 0.8)
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
                                  ? Colors.white.withValues(alpha: 0.8)
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
                color: AppTheme.dark.withValues(alpha: 0.9),
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
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            width: double.infinity,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    rowName,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppTheme.primary,
                      fontSize: 14,
                    ),
                  ),
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
    final draftAnimalId = draftAllocations[slotKey];
    final isBeingAllocated = draftAnimalId != null;
    final isTarget = widget.targetParkingId == posId;

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
                    ? AppTheme.primary.withValues(alpha: 0.3)
                    : Colors.grey.withValues(alpha: 0.2),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: (isOccupied || isBeingAllocated)
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isBeingAllocated
                    ? AppTheme.secondary
                    : isTarget
                    ? Colors.orange
                    : isOccupied
                    ? AppTheme.primary.withValues(alpha: 0.1)
                    : Colors.transparent,
                width: (isBeingAllocated || isTarget) ? 2 : 1.5,
              ),
              boxShadow: (isOccupied || isBeingAllocated)
                  ? [
                      BoxShadow(
                        color:
                            (isBeingAllocated
                                    ? AppTheme.secondary
                                    : AppTheme.primary)
                                .withValues(alpha: 0.15),
                        blurRadius: 12,
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
                        (s) => s.id.toString() == selectedShedId!,
                        orElse: () => sheds.first,
                      );
                      // Fallback just to avoid crash if not found, though unlikely if selectedShedId is set

                      final rowNum = rowName.replaceAll(RegExp(r'[^0-9]'), '');

                      final farmName = shed.farmName.toLowerCase().replaceAll(
                        ' ',
                        '',
                      );
                      final shedCode = shed.shedId;

                      final fullParkingId = '$farmName$shedCode$rowName$posId';

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

                        // final details = await AnimalApiServices.searchAnimals(
                        //   token: token,
                        //   query: fullParkingId,
                        // );

                        // if (mounted) {
                        //   _showAllocatedAnimalDetails(details);
                        // }
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
                      draftAllocations.remove(slotKey);
                    } else if (selectedAnimalId != null) {
                      // Allocate selected animal to this slot
                      draftAllocations[slotKey] = selectedAnimalId!;
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
                        const Icon(
                          Icons.pets,
                          size: 16,
                          color: AppTheme.primary,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          posId,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primary,
                          ),
                        ),
                      ] else if (isBeingAllocated) ...[
                        const Icon(
                          Icons.add_location_alt_rounded,
                          size: 16,
                          color: AppTheme.secondary,
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
                            fontWeight: FontWeight.w600,
                            color: AppTheme.grey1.withValues(alpha: 0.5),
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
        content: SingleChildScrollView(
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
              _buildDetailRow('Farm', data.farmDetails.farmName),
              _buildDetailRow('Shed', data.shedDetails.shedName),
              _buildDetailRow(
                'Row',
                'R${data.animalDetails.rowNumber?.toString() ?? "?"}',
              ),
              _buildDetailRow('Slot', data.animalDetails.parkingId ?? 'N/A'),
              _buildDetailRow('RFID Tag', data.animalDetails.rfidTagNumber),

              const SizedBox(height: 16),

              // Investor Details
              const Text(
                'Investor Details',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Divider(),
              _buildDetailRow('Name', data.investorDetails.fullName),
              _buildDetailRow('Mobile', data.investorDetails.mobile),

              // Farm Staff Details
              const SizedBox(height: 16),
              const Text(
                'Assigned Staff',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Divider(),

              // Farm Manager
              if (data.farmManager != null) ...[
                const SizedBox(height: 8),
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
              ],

              // Supervisor
              if (data.supervisor != null) ...[
                const SizedBox(height: 8),
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
              ],
            ],
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
    final onboardedAnimals = ref.read(farmManagerProvider).onboardedAnimalIds;

    if (draftAllocations.length < onboardedAnimals.length) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Incomplete Allocation'),
          content: Text(
            'You have ${onboardedAnimals.length - draftAllocations.length} animals left to allocate. Do you want to proceed anyway?',
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
    final selectedShed =
        dashboardState.sheds.where((s) => s.id == selectedShedId).firstOrNull ??
        (dashboardState.sheds.isNotEmpty ? dashboardState.sheds.first : null);

    if (selectedShed == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a shed first')),
        );
      }
      return;
    }

    // Convert draftAllocations to required format
    final List<Map<String, dynamic>> allocations = draftAllocations.entries.map(
      (e) {
        final parts = e.key.split('-'); // e.g. ["R1", "A4"]
        final rowId = parts[0]; // "R1"
        final slotId = parts[1]; // "A4"

        final String animalId = e.value;
        // Find the animal object to get the RFID tag
        final animalObj = onboardedAnimals.firstWhere(
          (a) {
            final aId = (a is Map)
                ? (a['rfid_tag'] ??
                      a['rfid'] ??
                      a['rfid_tag_number'] ??
                      a['animal_id'])
                : a.toString();
            return aId.toString() == animalId;
          },
          orElse: () => <String, dynamic>{}, // Return empty map if not found
        );

        String rfidTag = animalId; // Fallback to ID
        if (animalObj is Map) {
          rfidTag = (animalObj['rfid_tag'] ?? animalObj['rfid'] ?? animalId)
              .toString();
        }

        return {
          'rfid_tag_number': rfidTag,
          'parking_id': slotId, // Just the slot ID like "A4"
          'row_number': rowId, // Row ID as string like "R1"
        };
      },
    ).toList();

    final success = await ref
        .read(farmManagerProvider.notifier)
        .allocateAnimals(shedId: selectedShed.shedId, allocations: allocations);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Animals allocated successfully!'),
          backgroundColor: AppTheme.successGreen,
        ),
      );

      // Clear drafts
      setState(() {
        draftAllocations.clear();
      });

      // Refresh data to show updated slots and remove allocated animals
      if (selectedShedId != null) {
        ref
            .read(farmManagerProvider.notifier)
            .fetchShedPositions(selectedShedId!);
      }
      ref
          .read(farmManagerProvider.notifier)
          .fetchUnallocatedAnimals(farmId: selectedFarmId);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to allocate animals.'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }
}
