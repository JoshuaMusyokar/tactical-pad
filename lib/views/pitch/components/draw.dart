import 'package:flutter/material.dart';
import 'dart:math' as math;

class DrawingPainter extends CustomPainter {
  final List<DrawingObject> objects;

  DrawingPainter(this.objects);

  @override
  bool hitTest(Offset position) {
    return false; // Ensures CustomPainter doesn't block gestures
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (var object in objects) {
      switch (object.type) {
        case DrawingType.line:
          _drawLine(canvas, object);
          break;
        case DrawingType.arrow:
          _drawArrow(canvas, object);
          break;
        case DrawingType.circle:
          _drawCircle(canvas, object);
          break;
        case DrawingType.text:
          _drawText(canvas, object);
          break;
      }
    }
  }

  void _drawLine(Canvas canvas, DrawingObject object) {
    if (object.points.length < 2) return;
    final paint = Paint()
      ..color = object.color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(object.points.first, object.points.last, paint);
  }

  void _drawArrow(Canvas canvas, DrawingObject object) {
    if (object.points.length < 2) return;
    final paint = Paint()
      ..color = object.color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final start = object.points.first;
    final end = object.points.last;

    // Draw the line
    canvas.drawLine(start, end, paint);

    // Calculate the arrowhead
    final double arrowSize = 15;
    final double angle = math.atan2(end.dy - start.dy, end.dx - start.dx);
    final double x = math.cos(angle);
    final double y = math.sin(angle);

    final Offset tip = end;
    final Offset corner1 = Offset(end.dx - arrowSize * x + arrowSize * y,
        end.dy - arrowSize * y - arrowSize * x);
    final Offset corner2 = Offset(end.dx - arrowSize * x - arrowSize * y,
        end.dy - arrowSize * y + arrowSize * x);

    // Draw the arrowhead
    final Path path = Path();
    path.moveTo(tip.dx, tip.dy);
    path.lineTo(corner1.dx, corner1.dy);
    path.lineTo(corner2.dx, corner2.dy);
    path.close();
    canvas.drawPath(path, paint..style = PaintingStyle.fill);
  }

  void _drawCircle(Canvas canvas, DrawingObject object) {
    if (object.points.isEmpty) return;
    final paint = Paint()
      ..color = object.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final center = object.points.first;
    final radius = object.points.length > 1
        ? (object.points.last - center).distance
        : 20.0; // Default radius if only one point
    canvas.drawCircle(center, radius, paint);
  }

  void _drawText(Canvas canvas, DrawingObject object) {
    if (object.points.isEmpty || object.text == null) return;
    final textSpan = TextSpan(
      text: object.text,
      style: TextStyle(
          color: object.color, fontSize: 24, fontWeight: FontWeight.bold),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, object.points.first);
  }

  // Erase function
  void erase(Offset position, double tolerance) {
    objects.removeWhere((object) {
      switch (object.type) {
        case DrawingType.line:
          return _isPointNearLine(position, object.points, tolerance);
        case DrawingType.arrow:
          return _isPointNearLine(position, object.points, tolerance);
        case DrawingType.circle:
          return _isPointNearCircle(position, object.points, tolerance);
        case DrawingType.text:
          return _isPointNearText(position, object.points.first, tolerance);
      }
      return false;
    });
  }

  bool _isPointNearLine(
      Offset point, List<Offset> linePoints, double tolerance) {
    for (int i = 0; i < linePoints.length - 1; i++) {
      final p1 = linePoints[i];
      final p2 = linePoints[i + 1];
      final distance = _distanceToSegment(point, p1, p2);
      if (distance < tolerance) return true;
    }
    return false;
  }

  bool _isPointNearCircle(
      Offset point, List<Offset> circlePoints, double tolerance) {
    if (circlePoints.length < 2) return false;
    final center = circlePoints.first;
    final radius = (circlePoints.last - center).distance;
    final distance = (point - center).distance;
    return (distance - radius).abs() < tolerance;
  }

  bool _isPointNearText(Offset point, Offset textPosition, double tolerance) {
    final distance = (point - textPosition).distance;
    return distance < tolerance;
  }

  double _distanceToSegment(Offset p, Offset v, Offset w) {
    final l2 = (w - v).distanceSquared;
    if (l2 == 0.0) return (p - v).distance;
    final t = ((p - v).dx * (w - v).dx + (p - v).dy * (w - v).dy) / l2;
    if (t < 0.0) return (p - v).distance;
    if (t > 1.0) return (p - w).distance;
    final projection =
        Offset(v.dx + t * (w.dx - v.dx), v.dy + t * (w.dy - v.dy));
    return (p - projection).distance;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

enum DrawingType { line, arrow, circle, text }

class DrawingObject {
  final DrawingType type;
  final List<Offset> points;
  final Color color;
  final String? text;

  DrawingObject({
    required this.type,
    required this.points,
    required this.color,
    this.text,
  });
}
