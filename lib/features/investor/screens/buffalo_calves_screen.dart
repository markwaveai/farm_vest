import 'package:farm_vest/core/theme/app_constants.dart';
import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import '../models/unit_response.dart';
import '../widgets/buffalo_card.dart';

class BuffaloCalvesScreen extends StatefulWidget {
  final List<Animal> calves;
  final String parentId;
  final Animal? parent;

  const BuffaloCalvesScreen({
    super.key,
    required this.calves,
    required this.parentId,
    this.parent,
  });

  @override
  State<BuffaloCalvesScreen> createState() => _BuffaloCalvesScreenState();
}

class _BuffaloCalvesScreenState extends State<BuffaloCalvesScreen> {
  late Animal _rootNode;

  @override
  void initState() {
    super.initState();
    // Construct the root node with children if parent is provided
    if (widget.parent != null) {
      _rootNode = widget.parent!;
      // Ensure children are populated either from object or passed list
      if (_rootNode.children == null || _rootNode.children!.isEmpty) {
        // Create a copy or modify (since final, we reconstruct or attach dynamically)
        // Here we assume we can't modify the object easily, so we wraps it or handle in layout
        // For simplicity, we'll use a wrapper class for layout
      }
    } else {
      // Create a dummy root if parent missing (shouldn't happen based on prev steps)
      _rootNode = Animal(id: widget.parentId, children: widget.calves);
    }
  }

  @override
  Widget build(BuildContext context) {
    // We need to build a layout tree.
    // If parent is passed, we treat it as root. Returns a recursive widget structure.

    // Combine parent and passed calves if needed.
    // If widget.parent has children populated, use them.
    // Otherwise attach widget.calves to widget.parent.
 final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final effectiveRoot =
        widget.parent ?? Animal(id: widget.parentId, breedId: widget.parentId);
    // If the parent object doesn't have the children list populated but we have it in widget.calves:
    final rootChildren =
        (effectiveRoot.children != null && effectiveRoot.children!.isNotEmpty)
        ? effectiveRoot.children!
        : widget.calves;

    return Scaffold(
      backgroundColor:isDark ? AppTheme.darkSurfaceVariant : AppTheme.lightGrey,
      appBar: AppBar(
        title: Text('Lineage: ${widget.parent?.breedId ?? widget.parentId}'),
        centerTitle: true,
        backgroundColor:isDark ? AppTheme.darkSurfaceVariant : Colors.white,
        elevation: 1,
      ),
      body: InteractiveViewer(
        boundaryMargin: const EdgeInsets.all(100),
        minScale: 0.1,
        maxScale: 2.0,
        constrained: false, // Allow infinite scrolling space
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: _RecursiveTreeBuilder(
            root: effectiveRoot,
            childrenOverride: rootChildren,
          ),
        ),
      ),
    );
  }
}

class _RecursiveTreeBuilder extends StatelessWidget {
  final Animal root;
  final List<Animal>? childrenOverride;

  const _RecursiveTreeBuilder({required this.root, this.childrenOverride});

  @override
  Widget build(BuildContext context) {
    // 1. Calculate the list of children to render
    final children = childrenOverride ?? root.children ?? [];

    // 2. Build the parent card
    final parentWidget = _buildNode(context, root, isRoot: true);

    if (children.isEmpty) {
      return parentWidget;
    }

    // 3. Build children widgets recursively
    final childrenWidgets = children.map((child) {
      return _RecursiveTreeBuilder(root: child);
    }).toList();

    // 4. Layout
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        parentWidget,
        const SizedBox(height: 20), // Vertical spacing
        CustomPaint(
          size: Size(
            children.length * 220.0,
            40,
          ), // Approximate size for connector
          painter: _TreeConnectorPainter(
            childrenCount: children.length,
            stride: 220.0, // Assuming fixed width + padded children
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: childrenWidgets.map((childWidget) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
              ), // Horizontal gap
              child: childWidget,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNode(
    BuildContext context,
    Animal animal, {
    bool isRoot = false,
  }) {
    return Container(
      width: 200,
      height: 260,
      decoration: isRoot
          ? BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            )
          : null,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          BuffaloCard(
            farmName: animal.farmName ?? 'FarmVest Unit',
            location: animal.farmLocation ?? 'Location',
            id: animal.breedId ?? animal.id ?? 'Unknown',
            healthStatus: animal.healthStatus ?? 'Healthy',
            lastMilking: 'N/A', // Not relevant for tree view
            age: animal.ageYears != null ? '${animal.ageYears} yrs' : '-',
            breed: animal.breedId ?? '-',
            isGridView: true,
            showLiveButton: false, // Cleaner UI
            onTap: () {
              // Show details?
            },
            onCalvesTap:
                null, // Disable recursive navigation, we are already showing it
          ),
          // if (isRoot)
          //   Positioned(
          //     top: 0,
          //     right: 0,
          //     child: Container(
          //       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          //       decoration: BoxDecoration(
          //         color: AppTheme.primary,
          //         borderRadius: BorderRadius.circular(8),
          //       ),
          //       child: const Text(
          //         'ROOT',
          //         style: TextStyle(
          //           color: Colors.white,
          //           fontSize: 10,
          //           fontWeight: FontWeight.bold,
          //         ),
          //       ),
          //     ),
          //   ),
        ],
      ),
    );
  }
}

class _TreeConnectorPainter extends CustomPainter {
  final int childrenCount;
  final double stride;

  _TreeConnectorPainter({required this.childrenCount, required this.stride});

  @override
  void paint(Canvas canvas, Size size) {
    if (childrenCount == 0) return;

    final paint = Paint()
      ..color = AppTheme.mediumGrey
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final parentX = size.width / 2;
    final startY =
        -20.0; // Start lines from above the paint area (overlap the SizedBox gap)
    final midY = size.height / 2;
    final endY = size.height;

    // Draw vertical line from parent
    canvas.drawLine(Offset(parentX, startY), Offset(parentX, midY), paint);

    // Calculate width of the children row
    // We assume the children are centered globally.
    // But in the recursive structure, `size.width` here is passed as huge constraint.
    // Actually, getting the exact x-positions of children in a CustomPainter
    // without a sophisticated LayoutDelegate is tricky.
    //
    // ALTERNATIVE: Draw simple curves.
    // Since we are in a Column -> CustomPaint -> Row structure,
    // The CustomPaint size might not match the Row's exact width unless constrained.
    //
    // Simplified Logic for "Visualizer" look:
    // Just draw a line across.

    // We know the children are spaced by roughly `stride` (200 card + 20 pad).
    // The total width of children row is childrenCount * 220.

    final totalWidth = childrenCount * 220.0;
    final firstChildX =
        (size.width - totalWidth) / 2 + 110.0; // 110 = half stride
    final lastChildX =
        (size.width - totalWidth) / 2 + (childrenCount - 1) * 220.0 + 110.0;

    // Horizontal line
    canvas.drawLine(Offset(firstChildX, midY), Offset(lastChildX, midY), paint);

    // Vertical lines to children
    for (int i = 0; i < childrenCount; i++) {
      final childX = (size.width - totalWidth) / 2 + i * 220.0 + 110.0;
      canvas.drawLine(
        Offset(childX, midY),
        Offset(childX, endY + 0),
        paint,
      ); // +20 into the child top
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
