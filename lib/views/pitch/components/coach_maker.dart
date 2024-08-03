import 'package:flutter/material.dart';

class CoachMarker extends StatelessWidget {
  final Offset position;
  final Function(Offset) onDragEnd;

  CoachMarker({required this.position, required this.onDragEnd});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: Draggable(
        feedback: buildCoachMarker(),
        childWhenDragging: Container(),
        onDraggableCanceled: (velocity, offset) {
          onDragEnd(offset);
        },
        child: buildCoachMarker(),
      ),
    );
  }

  Widget buildCoachMarker() {
    return Image.asset(
      'lib/assets/coach.png',
      width: 40,
      height: 80,
    );
  }
}
