import 'package:flutter/material.dart';

class ThreeDButton extends StatefulWidget {
  final Widget? child;
  final String? text;
  final VoidCallback? onPressed;
  final Gradient? gradient;
  final Color? color;
  final Color textColor;
  final double borderRadius;
  final double depth;
  final double? width;
  final double height;
  final IconData? icon;
  final Color? borderColor;

  final EdgeInsetsGeometry? padding;

  const ThreeDButton({
    super.key,
    this.child,
    this.text,
    required this.onPressed,
    this.gradient,
    this.color,
    this.textColor = Colors.white,
    this.borderRadius = 16.0,
    this.depth = 6.0,
    this.width,
    this.height = 54.0,
    this.icon,
    this.borderColor,
    this.padding,
  }) : assert(child != null || text != null);

  @override
  State<ThreeDButton> createState() => _ThreeDButtonState();
}

class _ThreeDButtonState extends State<ThreeDButton> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null) {
      setState(() => _isPressed = true);
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onPressed != null) {
      setState(() => _isPressed = false);
      widget.onPressed!();
    }
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final hasGradient = widget.gradient != null || widget.color == null;
    final buttonColor = widget.color ?? const Color(0xFFE11D48); // Default rose-red accent
    final activeDepth = _isPressed ? 1.0 : widget.depth;
    final scale = _isPressed ? 0.96 : 1.0;

    final defaultPadding = widget.padding ??
        (widget.child != null || (widget.width != null && widget.width! <= widget.height)
            ? EdgeInsets.zero
            : const EdgeInsets.symmetric(horizontal: 6.0));

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        curve: Curves.easeOut,
        width: widget.width,
        height: widget.height,
        transform: Matrix4.identity()..scale(scale),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: hasGradient ? null : buttonColor,
          gradient: hasGradient
              ? (widget.gradient ??
                  const LinearGradient(
                    colors: [Color(0xFFF43F5E), Color(0xFFBE123C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ))
              : null,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(
            color: widget.borderColor ?? Colors.white.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: [
            // Dark bottom shadow (the 3D height)
            BoxShadow(
              color: (widget.color ?? const Color(0xFFBE123C)).withOpacity(0.4),
              offset: Offset(0, activeDepth),
              blurRadius: _isPressed ? 2.0 : activeDepth * 1.5,
              spreadRadius: -1,
            ),
            // White highlight bevel on top
            BoxShadow(
              color: Colors.white.withOpacity(0.25),
              offset: const Offset(0, -2),
              blurRadius: 0,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Center(
          child: Padding(
            padding: defaultPadding,
            child: widget.child ??
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, color: widget.textColor, size: 18),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        widget.text!,
                        maxLines: 1,
                        style: TextStyle(
                          color: widget.textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
          ),
        ),
      ),
    );
  }
}
