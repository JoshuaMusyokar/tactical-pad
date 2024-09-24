// import 'package:flutter/material.dart';
// import 'dart:math' as math;

// class DrawingPainter extends CustomPainter {
//   final List<DrawingObject> objects;

//   DrawingPainter(this.objects);

//   @override
//   bool hitTest(Offset position) {
//     return false; // Ensures CustomPainter doesn't block gestures
//   }

//   @override
//   void paint(Canvas canvas, Size size) {
//     for (var object in objects) {
//       switch (object.type) {
//         case DrawingType.line:
//           _drawLine(canvas, object);
//           break;
//         case DrawingType.arrow:
//           _drawArrow(canvas, object);
//           break;
//         case DrawingType.circle:
//           _drawCircle(canvas, object);
//           break;
//         case DrawingType.text:
//           _drawText(canvas, object);
//           break;
//       }
//     }
//   }

//   void _drawLine(Canvas canvas, DrawingObject object) {
//     if (object.points.length < 2) return;
//     final paint = Paint()
//       ..color = object.color
//       ..strokeWidth = 2
//       ..strokeCap = StrokeCap.round;
//     canvas.drawLine(object.points.first, object.points.last, paint);
//   }

//   void _drawArrow(Canvas canvas, DrawingObject object) {
//     if (object.points.length < 2) return;
//     final paint = Paint()
//       ..color = object.color
//       ..strokeWidth = 2
//       ..strokeCap = StrokeCap.round;

//     final start = object.points.first;
//     final end = object.points.last;

//     // Draw the line
//     canvas.drawLine(start, end, paint);

//     // Calculate the arrowhead
//     final double arrowSize = 15;
//     final double angle = math.atan2(end.dy - start.dy, end.dx - start.dx);
//     final double x = math.cos(angle);
//     final double y = math.sin(angle);

//     final Offset tip = end;
//     final Offset corner1 = Offset(end.dx - arrowSize * x + arrowSize * y,
//         end.dy - arrowSize * y - arrowSize * x);
//     final Offset corner2 = Offset(end.dx - arrowSize * x - arrowSize * y,
//         end.dy - arrowSize * y + arrowSize * x);

//     // Draw the arrowhead
//     final Path path = Path();
//     path.moveTo(tip.dx, tip.dy);
//     path.lineTo(corner1.dx, corner1.dy);
//     path.lineTo(corner2.dx, corner2.dy);
//     path.close();
//     canvas.drawPath(path, paint..style = PaintingStyle.fill);
//   }

//   void _drawCircle(Canvas canvas, DrawingObject object) {
//     if (object.points.isEmpty) return;
//     final paint = Paint()
//       ..color = object.color
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 2;
//     final center = object.points.first;
//     final radius = object.points.length > 1
//         ? (object.points.last - center).distance
//         : 20.0; // Default radius if only one point
//     canvas.drawCircle(center, radius, paint);
//   }

//   void _drawText(Canvas canvas, DrawingObject object) {
//     if (object.points.isEmpty || object.text == null) return;
//     final textSpan = TextSpan(
//       text: object.text,
//       style: TextStyle(
//           color: object.color, fontSize: 24, fontWeight: FontWeight.bold),
//     );
//     final textPainter = TextPainter(
//       text: textSpan,
//       textDirection: TextDirection.ltr,
//     );
//     textPainter.layout();
//     textPainter.paint(canvas, object.points.first);
//   }

//   // Erase function
//   void erase(Offset position, double tolerance) {
//     objects.removeWhere((object) {
//       switch (object.type) {
//         case DrawingType.line:
//           return _isPointNearLine(position, object.points, tolerance);
//         case DrawingType.arrow:
//           return _isPointNearLine(position, object.points, tolerance);
//         case DrawingType.circle:
//           return _isPointNearCircle(position, object.points, tolerance);
//         case DrawingType.text:
//           return _isPointNearText(position, object.points.first, tolerance);
//       }
//       return false;
//     });
//   }

//   bool _isPointNearLine(
//       Offset point, List<Offset> linePoints, double tolerance) {
//     for (int i = 0; i < linePoints.length - 1; i++) {
//       final p1 = linePoints[i];
//       final p2 = linePoints[i + 1];
//       final distance = _distanceToSegment(point, p1, p2);
//       if (distance < tolerance) return true;
//     }
//     return false;
//   }

//   bool _isPointNearCircle(
//       Offset point, List<Offset> circlePoints, double tolerance) {
//     if (circlePoints.length < 2) return false;
//     final center = circlePoints.first;
//     final radius = (circlePoints.last - center).distance;
//     final distance = (point - center).distance;
//     return (distance - radius).abs() < tolerance;
//   }

//   bool _isPointNearText(Offset point, Offset textPosition, double tolerance) {
//     final distance = (point - textPosition).distance;
//     return distance < tolerance;
//   }

//   double _distanceToSegment(Offset p, Offset v, Offset w) {
//     final l2 = (w - v).distanceSquared;
//     if (l2 == 0.0) return (p - v).distance;
//     final t = ((p - v).dx * (w - v).dx + (p - v).dy * (w - v).dy) / l2;
//     if (t < 0.0) return (p - v).distance;
//     if (t > 1.0) return (p - w).distance;
//     final projection =
//         Offset(v.dx + t * (w.dx - v.dx), v.dy + t * (w.dy - v.dy));
//     return (p - projection).distance;
//   }

//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) => true;
// }

// enum DrawingType { line, arrow, circle, text }

// class DrawingObject {
//   final DrawingType type;
//   final List<Offset> points;
//   final Color color;
//   final String? text;

//   DrawingObject({
//     required this.type,
//     required this.points,
//     required this.color,
//     this.text,
//   });
// }
import 'dart:math' as math;
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

enum DrawingType { line, arrow, circle, text }

class DrawingObject {
  DrawingType type;
  List<Offset> points;
  Color color;
  String? text;
  Rect? boundingBox;
  static const double hitTestPadding = 10.0;

  DrawingObject({
    required this.type,
    required this.points,
    required this.color,
    this.text,
  }) {
    _updateBoundingBox();
  }

  bool containsPoint(Offset point) {
    if (boundingBox == null) return false;

    final contains = boundingBox!.contains(point);
    print(
        "Checking if point $point is inside bounding box $boundingBox: $contains");
    return contains;
  }

  void _updateBoundingBox() {
    if (points.isNotEmpty) {
      double minX = points[0].dx;
      double minY = points[0].dy;
      double maxX = points[0].dx;
      double maxY = points[0].dy;

      for (var point in points) {
        minX = math.min(minX, point.dx);
        minY = math.min(minY, point.dy);
        maxX = math.max(maxX, point.dx);
        maxY = math.max(maxY, point.dy);
      }

      // Special handling for arrows
      if (type == DrawingType.arrow && points.length >= 2) {
        // Arrow bounding box includes both the start and end points
        minX = math.min(minX, points[0].dx);
        minY = math.min(minY, points[0].dy);
        maxX = math.max(maxX, points[1].dx);
        maxY = math.max(maxY, points[1].dy);
      }

      boundingBox = Rect.fromLTRB(minX, minY, maxX, maxY);
      print("Calculating bounding box for type: $type with points: $points");
    }
  }

  void translate(Offset delta) {
    points =
        points.map((point) => point.translate(delta.dx, delta.dy)).toList();
    _updateBoundingBox();
  }
}

class DrawingPainter extends CustomPainter {
  final List<DrawingObject> objects;
  final DrawingObject? selectedObject;
  final Offset? dragOffset;

  DrawingPainter(this.objects, {this.selectedObject, this.dragOffset});

  @override
  void paint(Canvas canvas, Size size) {
    for (var object in objects) {
      if (object == selectedObject && dragOffset != null) {
        canvas.save();
        canvas.translate(dragOffset!.dx, dragOffset!.dy);
      }

      _drawObject(canvas, object);

      if (object == selectedObject && dragOffset != null) {
        canvas.restore();
      }
    }
  }

  void _drawObject(Canvas canvas, DrawingObject object) {
    final paint = Paint()
      ..color = object.color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    switch (object.type) {
      case DrawingType.line:
        canvas.drawPoints(PointMode.polygon, object.points, paint);
        break;
      case DrawingType.arrow:
        _drawArrow(canvas, object, paint);
        break;
      case DrawingType.circle:
        if (object.points.length >= 2) {
          final center = object.points.first;
          final radius = (object.points.last - center).distance;
          canvas.drawCircle(center, radius, paint);
        }
        break;
      case DrawingType.text:
        _drawText(canvas, object);
        break;
    }
  }

  void _drawArrow(Canvas canvas, DrawingObject object, Paint paint) {
    if (object.points.length < 2) return;

    canvas.drawPoints(PointMode.polygon, object.points, paint);

    final start = object.points[object.points.length - 2];
    final end = object.points.last;

    final arrowSize = 15.0;
    final angle = (end - start).direction;

    final arrowPath = Path()
      ..moveTo(end.dx, end.dy)
      ..lineTo(end.dx - arrowSize * cos(angle - pi / 6),
          end.dy - arrowSize * sin(angle - pi / 6))
      ..lineTo(end.dx - arrowSize * cos(angle + pi / 6),
          end.dy - arrowSize * sin(angle + pi / 6))
      ..close();

    canvas.drawPath(arrowPath, paint..style = PaintingStyle.fill);
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

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  DrawingObject? getObjectAtPoint(Offset point) {
    for (var object in objects.reversed) {
      if (object.containsPoint(point)) {
        return object;
      }
    }
    return null;
  }
}
