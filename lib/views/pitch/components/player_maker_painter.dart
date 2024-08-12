import 'package:flutter/material.dart';

class PlayerMarker extends StatelessWidget {
  final Offset position;
  final Function(Offset) onDragEnd;

  PlayerMarker({required this.position, required this.onDragEnd});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: Draggable(
        feedback: buildPlayerMarker(),
        childWhenDragging: Container(),
        onDraggableCanceled: (velocity, offset) {
          onDragEnd(offset);
        },
        child: buildPlayerMarker(),
      ),
    );
  }

  Widget buildPlayerMarker() {
    return Image.asset(
      'lib/assets/player.jpeg',
      width: 40,
      height: 80,
    );
  }
}

// import 'package:flutter/material.dart';

// class PlayerPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.blue
//       ..style = PaintingStyle.fill;

//     // Draw the head
//     canvas.drawCircle(
//         Offset(size.width / 2, size.height / 8), size.width / 8, paint);

//     // Draw the body
//     final bodyPath = Path()
//       ..moveTo(size.width / 2, size.height / 4)
//       ..lineTo(size.width / 4, size.height / 2)
//       ..lineTo(3 * size.width / 4, size.height / 2)
//       ..close();
//     canvas.drawPath(bodyPath, paint);

//     // Draw the arms
//     canvas.drawLine(Offset(size.width / 4, size.height / 2),
//         Offset(size.width / 4 - size.width / 8, 3 * size.height / 4), paint);
//     canvas.drawLine(
//         Offset(3 * size.width / 4, size.height / 2),
//         Offset(3 * size.width / 4 + size.width / 8, 3 * size.height / 4),
//         paint);

//     // Draw the legs
//     canvas.drawLine(Offset(size.width / 2, size.height / 2),
//         Offset(size.width / 4, size.height), paint);
//     canvas.drawLine(Offset(size.width / 2, size.height / 2),
//         Offset(3 * size.width / 4, size.height), paint);
//   }

//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) {
//     return false;
//   }
// }
