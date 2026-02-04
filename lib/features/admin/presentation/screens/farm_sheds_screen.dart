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
                    shed['sheds.id'] ?? '',
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
