import 'package:flutter/material.dart';
import 'responsive_layout.dart';

class InvoiceSplitLayout extends StatelessWidget {
  final Widget leftSide;
  final Widget rightSide;

  const InvoiceSplitLayout({
    super.key,
    required this.leftSide,
    required this.rightSide,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Side (Form)
        Expanded(
          flex: 1,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000), // Allow full width usage
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: GlassContainer(
                  padding: const EdgeInsets.all(32),
                  child: leftSide,
                ),
              ),
            ),
          ),
        ),
        // Right Side (Preview/Summary)
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: GlassContainer( // Wrap right side in glass too for consistency
              padding: const EdgeInsets.all(32),
              child: rightSide,
            ),
          ),
        ),
      ],
    );
  }
}
// ... rest of file content ... or add to existing
