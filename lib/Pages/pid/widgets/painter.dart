import 'package:flutter/material.dart';
class EmptyGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeWidth = 1;

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    for (double x = 0; x <= size.width; x += size.width / 10) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += size.height / 10) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    final axisPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 2;
    canvas.drawLine(Offset(centerX, 0), Offset(centerX, size.height), axisPaint);
    canvas.drawLine(Offset(0, centerY), Offset(size.width, centerY), axisPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
