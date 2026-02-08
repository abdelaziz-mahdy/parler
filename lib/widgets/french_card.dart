import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class FrenchCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? color;
  final Border? border;

  const FrenchCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.color,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final cardDecoration = BoxDecoration(
      color: color ?? AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      border: border,
      boxShadow: [
        BoxShadow(
          color: AppColors.cardShadow,
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );

    if (onTap != null) {
      return Padding(
        padding: margin ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        child: Material(
          color: color ?? AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          elevation: 0,
          child: Ink(
            decoration: cardDecoration,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: padding ?? const EdgeInsets.all(20),
                child: child,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: padding ?? const EdgeInsets.all(20),
      decoration: cardDecoration,
      child: child,
    );
  }
}
