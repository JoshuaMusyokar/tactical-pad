import 'package:flutter/material.dart';

class PaddleCourtPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double margin = 20;
    final double borderWidth = 8;
    final double fenceHeight = 40;
    final double postSpacing = 50;

    final courtPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final borderPaint = Paint()
      ..color = Colors.grey[800]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final fencePaint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final postPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    // Draw the court background with margins
    canvas.drawRect(
        Rect.fromLTWH(
            margin, margin, size.width - 2 * margin, size.height - 2 * margin),
        courtPaint);

    // Draw the artificial borders around the court
    canvas.drawRect(
        Rect.fromLTWH(
            margin, margin, size.width - 2 * margin, size.height - 2 * margin),
        borderPaint);

    // Draw outer lines inside the borders
    final double innerMargin = margin + borderWidth / 2;
    canvas.drawRect(
        Rect.fromLTWH(innerMargin, innerMargin, size.width - 2 * innerMargin,
            size.height - 2 * innerMargin),
        linePaint);

    // Draw center line (net)
    canvas.drawLine(Offset(innerMargin, size.height / 2),
        Offset(size.width - innerMargin, size.height / 2), linePaint);

    // Draw service lines
    canvas.drawLine(Offset(size.width / 2, innerMargin),
        Offset(size.width / 2, size.height / 2 - innerMargin), linePaint);
    canvas.drawLine(Offset(size.width / 2, size.height / 2 + innerMargin),
        Offset(size.width / 2, size.height - innerMargin), linePaint);

    // Draw service boxes (left and right)
    canvas.drawLine(Offset(innerMargin, size.height / 4),
        Offset(size.width - innerMargin, size.height / 4), linePaint);
    canvas.drawLine(Offset(innerMargin, size.height * 3 / 4),
        Offset(size.width - innerMargin, size.height * 3 / 4), linePaint);

    // Draw the walls (optional)
    canvas.drawLine(Offset(margin, margin),
        Offset(margin, size.height - margin), fencePaint);
    canvas.drawLine(Offset(size.width - margin, margin),
        Offset(size.width - margin, size.height - margin), fencePaint);
    canvas.drawLine(Offset(margin, margin), Offset(size.width - margin, margin),
        fencePaint);
    canvas.drawLine(Offset(margin, size.height - margin),
        Offset(size.width - margin, size.height - margin), fencePaint);

    // Draw raised fences with posts
    for (double i = margin; i < size.width - margin; i += postSpacing) {
      canvas.drawLine(
          Offset(i, margin - fenceHeight), Offset(i, margin), fencePaint);
      canvas.drawLine(
          Offset(i, size.height - margin), Offset(i, size.height - margin + fenceHeight), fencePaint);
      canvas.drawCircle(Offset(i, margin), 2, postPaint);
      canvas.drawCircle(Offset(i, size.height - margin), 2, postPaint);
    }
    for (double i = margin; i < size.height - margin; i += postSpacing) {
      canvas.drawLine(
          Offset(margin - fenceHeight, i), Offset(margin, i), fencePaint);
      canvas.drawLine(
          Offset(size.width - margin, i), Offset(size.width - margin + fenceHeight, i), fencePaint);
      canvas.drawCircle(Offset(margin, i), 2, postPaint);
      canvas.drawCircle(Offset(size.width - margin, i), 2, postPaint);
    }

    // Draw fence horizontal lines
    final double fenceSpacing = 20.0;
    for (double i = margin - fenceHeight; i < size.height - margin + fenceHeight; i += fenceSpacing) {
      canvas.drawLine(Offset(margin - fenceHeight, i), Offset(size.width - margin + fenceHeight, i), fencePaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
