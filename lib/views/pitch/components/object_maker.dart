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

  ObjectMarker({
    required this.position,
    required this.onDragEnd,
    required this.imageAsset,
    required this.onPositionChanged,
    this.onSizeChanged,
    this.initialSize = 40.0,
  });

  @override
  _ObjectMarkerState createState() => _ObjectMarkerState();
}

class _ObjectMarkerState extends State<ObjectMarker> {
  late Offset _position;
  late double _size;

  @override
  void initState() {
    super.initState();
    _position = widget.position;
    _size = widget.initialSize;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        DragTarget<Offset>(
          onWillAccept: (data) => true,
          onAccept: (data) {
            setState(() {
              _position = data;
            });
            widget.onDragEnd(data);
            widget.onPositionChanged(data);
          },
          builder: (context, candidateData, rejectedData) {
            return Container();
          },
        ),
        Positioned(
          left: _position.dx,
          top: _position.dy,
          child: GestureDetector(
            onScaleStart: (details) {
              // Store the initial size when scaling starts
              _size = widget.initialSize;
            },
            onScaleUpdate: (details) {
              setState(() {
                _size = widget.initialSize * details.scale;
                _size = _size.clamp(20.0, 100.0);
              });
              print('Scale factor: ${details.scale}, Size: $_size');
              if (widget.onSizeChanged != null) {
                widget.onSizeChanged!(_size);
              }
            },
            child: Draggable(
              feedback: RepaintBoundary(
                child: buildObjectMarker(),
              ),
              childWhenDragging: Opacity(
                opacity: 0,
                child: buildObjectMarker(),
              ),
              onDragEnd: (details) {
                var renderBox = context.findRenderObject() as RenderBox;
                final localOffset = renderBox.globalToLocal(details.offset);
                Offset adjustedOffset = Offset(
                  localOffset.dx - _size / 2,
                  localOffset.dy - _size / 2,
                );
                setState(() {
                  _position = adjustedOffset;
                });
                widget.onPositionChanged(adjustedOffset);
              },
              child: buildObjectMarker(),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildObjectMarker() {
    return Image.asset(
      widget.imageAsset,
      width: _size,
      height: _size,
    );
  }
}
