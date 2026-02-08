import 'package:flutter/material.dart';

/// Responsive breakpoints and utilities.
/// Use as an extension on BuildContext, same pattern as [AdaptiveColors].
extension Responsive on BuildContext {
  double get _width => MediaQuery.sizeOf(this).width;

  /// Phone: < 600px
  bool get isCompact => _width < 600;

  /// Tablet: 600–1199px
  bool get isMedium => _width >= 600 && _width < 1200;

  /// Desktop: >= 1200px
  bool get isExpanded => _width >= 1200;

  /// Maximum content width for the current breakpoint.
  double get contentMaxWidth {
    if (isCompact) return 600;
    if (isMedium) return 900;
    return 1200;
  }

  /// Grid column count for category-style grids.
  int get gridColumns {
    if (isCompact) return 2;
    if (isMedium) return 3;
    return 4;
  }

  /// Horizontal padding that scales with screen size.
  double get horizontalPadding {
    if (isCompact) return 20;
    if (isMedium) return 32;
    return 40;
  }
}

/// Wraps [child] in a centered ConstrainedBox so content doesn't stretch
/// across the full width on tablet / desktop.
class ContentConstraint extends StatelessWidget {
  final double? maxWidth;
  final Widget child;

  const ContentConstraint({super.key, this.maxWidth, required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? context.contentMaxWidth,
        ),
        child: child,
      ),
    );
  }
}
