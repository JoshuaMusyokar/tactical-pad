import 'package:flutter/material.dart';

class BallMarker extends StatelessWidget {
  final Offset position;
  final Function(Offset) onDragEnd;

  BallMarker({required this.position, required this.onDragEnd});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: Draggable(
        feedback: buildBallMarker(),
        childWhenDragging: Container(),
        onDraggableCanceled: (velocity, offset) {
          onDragEnd(offset);
        },
        child: buildBallMarker(),
      ),
    );
  }

  Widget buildBallMarker() {
    return Image.asset(
      'lib/assets/ball.png',
      width: 40,
      height: 40,
    );
  }
}
