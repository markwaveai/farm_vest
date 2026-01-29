import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/features/admin/presentation/providers/admin_provider.dart';

class FarmSelectorInput extends ConsumerStatefulWidget {
  final int? selectedFarmId;
  final ValueChanged<int?> onChanged;
  final String label;

  const FarmSelectorInput({
    super.key,
    required this.selectedFarmId,
    required this.onChanged,
    this.label = 'Select a farm unit',
  });

  @override
  ConsumerState<FarmSelectorInput> createState() => _FarmSelectorInputState();
}

class _FarmSelectorInputState extends ConsumerState<FarmSelectorInput> {
  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProvider);
    final selectedFarm = adminState.farms.firstWhere(
      (f) => f['id'] == widget.selectedFarmId,
      orElse: () => {},
    );
    final selectedName = selectedFarm['farm_name'] as String? ?? '';

    return InkWell(
      onTap: () => _showSelectionSheet(context),
      child: InputDecorator(
        decoration: InputDecoration(
          hintText: widget.label,
          prefixIcon: const Icon(
            Icons.agriculture_rounded,
            size: 22,
            color: AppTheme.primary,
          ),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
          ),
          suffixIcon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
        ),
        child: Text(
          selectedName.isNotEmpty ? selectedName : widget.label,
          style: TextStyle(
            fontWeight: selectedName.isNotEmpty
                ? FontWeight.w600
                : FontWeight.normal,
            fontSize: 15,
            color: selectedName.isNotEmpty ? AppTheme.dark : Colors.black54,
          ),
        ),
      ),
    );
  }

  void _showSelectionSheet(BuildContext context) async {
    final result = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FarmSelectionSheet(),
    );

    if (result != null) {
      widget.onChanged(result);
    }
  }
}

class FarmSelectionSheet extends ConsumerStatefulWidget {
  const FarmSelectionSheet({super.key});

  @override
  ConsumerState<FarmSelectionSheet> createState() => _FarmSelectionSheetState();
}

class _FarmSelectionSheetState extends ConsumerState<FarmSelectionSheet> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(adminProvider.notifier).fetchFarms(page: 1);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollEndNotification &&
        notification.metrics.pixels >=
            notification.metrics.maxScrollExtent - 50) {
      final state = ref.read(adminProvider);
      if (!state.isLoading) {
        _currentPage++;
        ref
            .read(adminProvider.notifier)
            .fetchFarms(
              page: _currentPage,
              query: _searchController.text.trim(),
            );
      }
    }
    return false;
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _currentPage = 1;
      ref.read(adminProvider.notifier).fetchFarms(page: 1, query: query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      "Select Farm",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: "Search farms...",
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: state.isLoading && state.farms.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : NotificationListener<ScrollNotification>(
                        onNotification: _handleScrollNotification,
                        child: ListView.separated(
                          controller: scrollController,
                          itemCount:
                              state.farms.length + (state.isLoading ? 1 : 0),
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            if (index == state.farms.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            }
                            final farm = state.farms[index];
                            return ListTile(
                              title: Text(
                                farm['farm_name'] ?? 'Unknown',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                farm['location'] ?? '',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              onTap: () {
                                Navigator.pop(context, farm['id']);
                              },
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
