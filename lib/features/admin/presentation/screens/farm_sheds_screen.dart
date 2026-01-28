import 'package:farm_vest/core/services/api_services.dart';
import 'package:farm_vest/core/services/sheds_api_services.dart';
import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FarmShedsScreen extends StatefulWidget {
  final int farmId;
  final String farmName;

  const FarmShedsScreen({
    super.key,
    required this.farmId,
    required this.farmName,
  });

  @override
  State<FarmShedsScreen> createState() => _FarmShedsScreenState();
}

class _FarmShedsScreenState extends State<FarmShedsScreen> {
  List<Map<String, dynamic>> _sheds = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _fetchSheds();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchSheds({String? query}) async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token == null) return;

      final sheds = await ShedsApiServices.getShedList(
        token: token,
        farmId: widget.farmId,
        // name: query,
      );

      if (mounted) {
        setState(() {
          _sheds = sheds;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onSearch(String query) {
    _fetchSheds(query: query);
  }

  void _showEditCctvUrlDialog(Map<String, dynamic> shed) {
    final controller = TextEditingController(text: shed['cctv_url']);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update CCTV URL - ${shed['shed_name']}'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'CCTV Stream URL',
            hintText: 'e.g. rtsp://... or https://...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newUrl = controller.text.trim();
              try {
                final prefs = await SharedPreferences.getInstance();
                final token = prefs.getString('access_token');
                if (token == null) return;

                final success = await ShedsApiServices.updateShed(
                  token: token,
                  shedId: shed['id'] as int,
                  body: {'cctv_url': newUrl.isEmpty ? null : newUrl},
                );

                if (success && mounted) {
                  Navigator.pop(context);
                  _fetchSheds();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('CCTV URL updated')),
                  );
                }
              } catch (e) {
                // error handled by api service
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search sheds...',
                  border: InputBorder.none,
                ),
                onChanged: _onSearch,
              )
            : Text('${widget.farmName} Sheds'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.clear();
                  _fetchSheds();
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _sheds.isEmpty
          ? const Center(child: Text('No sheds found'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _sheds.length,
              itemBuilder: (context, index) {
                final shed = _sheds[index];
                return _buildShedCard(shed);
              },
            ),
    );
  }

  Widget _buildShedCard(Map<String, dynamic> shed) {
    final available = shed['available_positions'] ?? 0;
    final capacity = shed['capacity'] ?? 0;
    final currentBuffaloes = shed['current_buffaloes'] ?? 0;
    final cctvUrl = shed['cctv_url'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    shed['shed_name'] ?? 'Unknown Shed',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.dark,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    shed['shed_id'] ?? '',
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStat('Capacity', '$capacity'),
                const SizedBox(width: 24),
                _buildStat('Animals', '$currentBuffaloes'),
                const SizedBox(width: 24),
                _buildStat('Available', '$available'),
              ],
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CCTV Feed URL',
                        style: TextStyle(fontSize: 12, color: AppTheme.slate),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        cctvUrl ?? 'Not assigned',
                        style: TextStyle(
                          fontSize: 13,
                          color: cctvUrl != null
                              ? AppTheme.primary
                              : AppTheme.mediumGrey,
                          fontStyle: cctvUrl != null
                              ? FontStyle.normal
                              : FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _showEditCctvUrlDialog(shed),
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  color: AppTheme.primary,
                  tooltip: 'Update CCTV URL',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppTheme.slate),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.dark,
          ),
        ),
      ],
    );
  }
}
