import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BuffaloCard extends StatelessWidget {
  final String farmName;
  final String location;
  final String id;
  final String healthStatus;
  final String lastMilking;
  final String age;
  final String breed;
  final bool isGridView;
  final VoidCallback? onTap;
  final VoidCallback? onCalvesTap;

  // Sample Murrah buffalo images
  static const List<String> murrahImages = [
    'assets/images/murrah1.jpg',
    'assets/images/murrah2.jpg',
    'assets/images/murrah3.jpg',
  ];
  const BuffaloCard({
    super.key,
    required this.farmName,
    required this.location,
    required this.id,
    required this.healthStatus,
    required this.lastMilking,
    required this.age,
    required this.breed,
    this.isGridView = true,
    this.onTap,
    this.onCalvesTap,
  });

  @override
  Widget build(BuildContext context) {
    // Use a consistent image for each buffalo based on its ID
    final imageUrl = murrahImages[id.hashCode % murrahImages.length];

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap:
            onTap ??
            () => context.go('/unit-details', extra: {'buffaloId': id}),
        borderRadius: BorderRadius.circular(16),
        child: isGridView
            ? _buildGridView(imageUrl, context)
            : _buildListView(imageUrl, context),
      ),
    );
  }

  Widget _buildGridView(String imageUrl, BuildContext context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Section
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Container(
                height: 120,
                decoration: BoxDecoration(color: Colors.grey[200]),
                child: _buildImageWidget(imageUrl),
              ),
            ),
            // Info Section
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatusChip(),
                      if (onCalvesTap != null)
                        GestureDetector(
                          onTap: onCalvesTap,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.blue.withOpacity(0.3),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.child_care,
                                  size: 14,
                                  color: Colors.blue,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Calves',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildLabelValueRow('ID', id),
                  const SizedBox(height: 4),
                  _buildLabelValueRow('Breed', breed),
                  const SizedBox(height: 4),
                  _buildLabelValueRow('Age', age),
                ],
              ),
            ),
          ],
        ),
        _buildActionButtons(context),
      ],
    );
  }

  // Modified to include Calves button
  Widget _buildActionButtons(BuildContext context) {
    return Positioned(
      top: 8,
      right: 8,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              // Navigate to live stream with buffalo ID
              context.go('/cctv-live', extra: {'buffaloId': id});
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.live_tv, size: 16, color: Colors.white),
                  SizedBox(width: 4),
                  Text(
                    'LIVE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(String imageUrl, BuildContext context) {
    return Stack(
      children: [
        Row(
          children: [
            // Image
            Container(
              width: 100,
              height: 100,
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[200],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildImageWidget(imageUrl),
              ),
            ),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatusChip(),
                        if (onCalvesTap != null)
                          GestureDetector(
                            onTap: onCalvesTap,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.blue.withOpacity(0.3),
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.child_care,
                                    size: 14,
                                    color: Colors.blue,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Calves',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildLabelValueRow('ID', id),
                    const SizedBox(height: 4),
                    _buildLabelValueRow('Breed', breed),
                    const SizedBox(height: 4),
                    _buildLabelValueRow('Age', age),
                  ],
                ),
              ),
            ),
            // Live button spacer/padding if needed, or overlay it
            const SizedBox(width: 60),
          ],
        ),
        _buildActionButtons(context),
      ],
    );
  }

  Widget _buildImageWidget(String imagePath) {
    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[200],
          child: const Center(
            child: Icon(Icons.image_not_supported, color: Colors.grey),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip() {
    Color statusColor = Colors.green;
    if (healthStatus.toLowerCase().contains('warning')) {
      statusColor = Colors.orange;
    } else if (healthStatus.toLowerCase().contains('critical')) {
      statusColor = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Text(
        healthStatus,
        style: TextStyle(
          color: statusColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildLabelValueRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}
