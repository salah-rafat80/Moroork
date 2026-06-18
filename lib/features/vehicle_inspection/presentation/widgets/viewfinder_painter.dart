import 'package:flutter/material.dart';
import 'package:traffic/core/constants/colors.dart';

/// Draws four green corner brackets to create a camera viewfinder frame.
class ViewfinderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double cornerLength;
  final double cornerRadius;

  ViewfinderPainter({
    Color? color,
    this.strokeWidth = 3.0,
    this.cornerLength = 30.0,
    this.cornerRadius = 12.0,
  }) : color = color ?? AppColors.primary;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;
    final cl = cornerLength;
    final r = cornerRadius;

    // ── Top-left corner ──
    final topLeft = Path()
      ..moveTo(0, cl)
      ..lineTo(0, r)
      ..quadraticBezierTo(0, 0, r, 0)
      ..lineTo(cl, 0);
    canvas.drawPath(topLeft, paint);

    // ── Top-right corner ──
    final topRight = Path()
      ..moveTo(w - cl, 0)
      ..lineTo(w - r, 0)
      ..quadraticBezierTo(w, 0, w, r)
      ..lineTo(w, cl);
    canvas.drawPath(topRight, paint);

    // ── Bottom-left corner ──
    final bottomLeft = Path()
      ..moveTo(0, h - cl)
      ..lineTo(0, h - r)
      ..quadraticBezierTo(0, h, r, h)
      ..lineTo(cl, h);
    canvas.drawPath(bottomLeft, paint);

    // ── Bottom-right corner ──
    final bottomRight = Path()
      ..moveTo(w - cl, h)
      ..lineTo(w - r, h)
      ..quadraticBezierTo(w, h, w, h - r)
      ..lineTo(w, h - cl);
    canvas.drawPath(bottomRight, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
