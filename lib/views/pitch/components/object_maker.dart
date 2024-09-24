// import 'package:flutter/material.dart';

// class ObjectMarker extends StatefulWidget {
//   final Offset position;
//   final Function(Offset) onDragEnd;
//   final String imageAsset;
//   final Function(Offset) onPositionChanged;
//   final double size; // New parameter to accept size

//   ObjectMarker({
//     required this.position,
//     required this.onDragEnd,
//     required this.imageAsset,
//     required this.onPositionChanged,
//     this.size = 40.0, // Default size
//   });

//   @override
//   _ObjectMarkerState createState() => _ObjectMarkerState();
// }

// class _ObjectMarkerState extends State<ObjectMarker> {
//   late Offset _position;

//   @override
//   void initState() {
//     super.initState();
//     _position = widget.position;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         DragTarget<Offset>(
//           onWillAccept: (data) => true,
//           onAccept: (data) {
//             setState(() {
//               _position = data;
//             });
//             widget.onDragEnd(data);
//             widget.onPositionChanged(data); // Pass the new position to parent
//           },
//           builder: (context, candidateData, rejectedData) {
//             return Container();
//           },
//         ),
//         Positioned(
//           left: _position.dx,
//           top: _position.dy,
//           child: Draggable(
//             feedback: RepaintBoundary(
//               child: buildObjectMarker(),
//             ),
//             childWhenDragging: Opacity(
//               opacity: 0,
//               child: buildObjectMarker(),
//             ),
//             onDragEnd: (details) {
//               print("causer of the actions===============>");
//               // Convert global coordinates to local coordinates
//               var renderBox = context.findRenderObject() as RenderBox;
//               final localOffset = renderBox.globalToLocal(details.offset);

//               // Adjust the local offset here to match the drop position
//               Offset adjustedOffset = Offset(
//                 localOffset.dx -
//                     0, // Adjust based on the widget size (half of 40)
//                 localOffset.dy - 0,
//               );

//               setState(() {
//                 _position = adjustedOffset;
//               });
//               widget.onPositionChanged(
//                   adjustedOffset); // Pass the new position to parent
//             },
//             child: buildObjectMarker(),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget buildObjectMarker() {
//     return Image.asset(
//       widget.imageAsset,
//       width: widget.size,
//       height: widget.size,
//     );
//   }
// }
import 'package:flutter/material.dart';

class ObjectMarker extends StatefulWidget {
  final Offset position;
  final Function(Offset) onDragEnd;
  final String imageAsset;
  final Function(Offset) onPositionChanged;
  final Function(double)? onSizeChanged;
  final double initialSize;
  final double canvasScale;
  final Offset canvasPanOffset;

  ObjectMarker({
    required this.position,
    required this.onDragEnd,
    required this.imageAsset,
    required this.onPositionChanged,
    this.onSizeChanged,
    this.initialSize = 40.0,
    required this.canvasScale,
    required this.canvasPanOffset,
  });

  @override
  _ObjectMarkerState createState() => _ObjectMarkerState();
}

class _ObjectMarkerState extends State<ObjectMarker> {
  late Offset _position;
  late double _size;
  double _scaleFactor = 1.0; // Track scale factor
  Offset _lastFocalPoint = Offset.zero; // Track last focal point for panning

  @override
  void initState() {
    super.initState();
    _position = widget.position;
    _size = widget.initialSize *
        widget.canvasScale; // Initial size based on canvas scale
  }

  @override
  Widget build(BuildContext context) {
    // Adjust position based on canvas scale and pan offset
    Offset adjustedPosition =
        (_position - widget.canvasPanOffset) * widget.canvasScale;

    return Positioned(
      left: adjustedPosition.dx,
      top: adjustedPosition.dy,
      child: Container(
        // color: Colors.transparent, // To capture gestures
        child: GestureDetector(
          onScaleUpdate: (details) {
            setState(() {
              // Update scale (zoom)
              _scaleFactor *= details.scale;

              // Clamp the scale factor to stay within min and max limits
              _scaleFactor = _scaleFactor.clamp(0.5, 3.0);

              // Update size based on new scale factor
              _size = widget.initialSize * _scaleFactor;

              // Handle panning (dragging) during scale gesture
              Offset delta = details.focalPoint - _lastFocalPoint;
              _position += delta / widget.canvasScale;

              _lastFocalPoint = details.focalPoint;
            });

            widget.onPositionChanged(_position);
          },
          onScaleEnd: (details) {
            _lastFocalPoint =
                Offset.zero; // Reset focal point after scaling ends
            // widget.onDragEnd(_position); // Notify parent when dragging ends
          },
          onScaleStart: (details) {
            _lastFocalPoint =
                details.focalPoint; // Set focal point when scaling starts
          },
          child: Image.asset(
            widget.imageAsset,
            width: _size,
            height: _size,
          ),
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(ObjectMarker oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Handle canvas scale change to update size
    if (oldWidget.canvasScale != widget.canvasScale) {
      setState(() {
        _size = widget.initialSize * widget.canvasScale * _scaleFactor;
      });
    }
  }
}
