import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/core/utils/string_extensions.dart';
import 'package:farm_vest/features/investor/data/models/investor_animal_model.dart';
import 'package:flutter/material.dart';
import 'package:farm_vest/core/theme/app_constants.dart';
import '../widgets/dashboard/buffalo_card.dart';

class BuffaloCalvesScreen extends StatefulWidget {
  final List<InvestorAnimal> calves;
  final String parentId;
  final InvestorAnimal? parent;

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
  late InvestorAnimal _rootNode;

  @override
  void initState() {
    super.initState();
    // Construct the root node with children if parent is provided
    if (widget.parent != null) {
      _rootNode = widget.parent!;
    } else {
      // Create a dummy root if parent missing
      _rootNode = InvestorAnimal(
        animalId: widget.parentId,
        rfid: kHyphen, // Don't use ID as RFID
        images: const [],
        farmName: ('FarmVest Unit'.tr),
        farmLocation: '',
        shedName: ('Checking...'.tr),
        shedId: 0,
        animalType: ('Buffalo'.tr),
        healthStatus: ('Unknown'.tr),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Determine children to show
    final List<InvestorAnimal> rootChildren = widget.calves;

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.darkSurfaceVariant
          : AppTheme.lightGrey,
      appBar: AppBar(
        title: Text('Lineage: ${widget.parent?.rfid ?? widget.parentId}'.tr),
        centerTitle: true,
        backgroundColor: isDark ? AppTheme.darkSurfaceVariant : Colors.white,
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
            root: _rootNode,
            childrenOverride: rootChildren,
            isAbsoluteRoot: true, // Only true for the top-level parent
          ),
        ),
      ),
    );
  }
}

class _RecursiveTreeBuilder extends StatelessWidget {
  final InvestorAnimal root;
  final List<InvestorAnimal>? childrenOverride;
  final bool isAbsoluteRoot;

  const _RecursiveTreeBuilder({
    required this.root,
    this.childrenOverride,
    this.isAbsoluteRoot = false,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Calculate the list of children to render
    final children = childrenOverride ?? [];

    // 2. Build the parent card
    final parentWidget = _buildNode(context, root, isRoot: isAbsoluteRoot);

    if (children.isEmpty) {
      return parentWidget;
    }

    // 3. Build children widgets recursively
    final childrenWidgets = children.map((child) {
      return _RecursiveTreeBuilder(root: child, isAbsoluteRoot: false);
    }).toList();

    // 4. Layout
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        parentWidget,
        const SizedBox(height: 20), // Vertical spacing
        CustomPaint(
          size: Size(
            (children.isEmpty ? 1 : children.length) * 220.0,
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
    InvestorAnimal animal, {
    bool isRoot = false,
  }) {
    return Container(
      width: 200,
      height: 280, // Slightly taller for better fit
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
            animal: animal,
            isGridView: true,
            onTap: () {
              // Show details if needed
            },
            onCalvesTap: () async {
              // Future: fetch grandchildren
            },
            onInvoiceTap: () async {},
          ),
          if (isRoot)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'PARENT'.tr,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
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

    final totalWidth = childrenCount * 220.0;
    // Calculate first and last child X relative to center
    // We assume children are centered.
    // The width of the drawing area 'size.width' passed from CustomPaint is children.length * 220.
    // So parentX (size.width/2) is exactly the center of the children group.

    final firstChildX = (size.width - totalWidth) / 2 + 110.0;
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
