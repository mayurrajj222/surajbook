import 'package:flutter/material.dart';

class ThreeDContainer extends StatelessWidget {
  final Widget child;
  final double depth;
  final double borderRadius;
  final Color? color;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final double borderWidth;
  final Color? borderColor;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final bool glass;
  final double? width;
  final double? height;

  const ThreeDContainer({
    super.key,
    required this.child,
    this.depth = 6.0,
    this.borderRadius = 20.0,
    this.color,
    this.gradient,
    this.onTap,
    this.borderWidth = 1.5,
    this.borderColor,
    this.padding = const EdgeInsets.all(16.0),
    this.margin = EdgeInsets.zero,
    this.glass = false,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? (glass ? Colors.white.withOpacity(0.8) : Colors.white),
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor ?? (glass ? Colors.white.withOpacity(0.5) : const Color(0xFFE2E8F0)),
          width: borderWidth,
        ),
        boxShadow: depth > 0
            ? [
                // Primary deep shadow
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  offset: Offset(0, depth * 1.5),
                  blurRadius: depth * 2.5,
                  spreadRadius: -depth * 0.3,
                ),
                // Secondary close shadow for physical anchoring
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  offset: Offset(0, depth * 0.6),
                  blurRadius: depth * 1.0,
                  spreadRadius: -depth * 0.2,
                ),
                // Top white glow reflection (3D bevel)
                BoxShadow(
                  color: Colors.white.withOpacity(0.9),
                  offset: const Offset(0, -2),
                  blurRadius: 0,
                  spreadRadius: 1,
                ),
              ]
            : [
                // Inset / Sunken effect or no shadow
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  offset: const Offset(0, 1),
                  blurRadius: 2,
                  spreadRadius: 0,
                ),
              ],
      ),
      padding: padding,
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: card,
      );
    }

    return card;
  }
}
