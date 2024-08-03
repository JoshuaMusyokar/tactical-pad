import 'package:flutter/material.dart';

class ConeMarker extends StatelessWidget {
  final Offset position;
  final Function(Offset) onDragEnd;

  ConeMarker({required this.position, required this.onDragEnd});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: Draggable(
        feedback: buildConeMarker(),
        childWhenDragging: Container(),
        onDraggableCanceled: (velocity, offset) {
          onDragEnd(offset);
        },
        child: buildConeMarker(),
      ),
    );
  }

  Widget buildConeMarker() {
    return Image.asset(
      'lib/assets/cone.png',
      width: 40,
      height: 80,
    );
  }
}
