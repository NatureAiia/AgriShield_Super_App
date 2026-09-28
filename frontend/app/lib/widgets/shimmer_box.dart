import 'package:flutter/material.dart';
import '../theme.dart';

/// A skeleton placeholder with a sliding highlight — reduces perceived
/// latency while a first sensor reading or satellite fetch is in flight,
/// instead of a bare "—" or a spinner. No extra package: a small
/// AnimationController driving a moving gradient.
class ShimmerBox extends StatefulWidget {
  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerBox({super.key, this.width, this.height = 16, this.borderRadius});

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = context.colors.outline;
    final highlight = context.colors.onSurface.withValues(alpha: 0.06);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value; // 0..1, loops
        return ClipRRect(
          borderRadius: widget.borderRadius ?? BorderRadius.circular(6),
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(-1.5 + 3 * t, 0),
                end: Alignment(-0.5 + 3 * t, 0),
                colors: [base.withValues(alpha: 0.35), highlight, base.withValues(alpha: 0.35)],
              ),
            ),
          ),
        );
      },
    );
  }
}
