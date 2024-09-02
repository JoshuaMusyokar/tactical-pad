// import 'package:flutter/material.dart';
// import 'package:tactical_pad/models/project.dart';
// import 'package:tactical_pad/views/pitch/components/makers.dart';

// class AnimationScreen extends StatefulWidget {
//   final Project project;

//   AnimationScreen({Key? key, required this.project}) : super(key: key);

//   @override
//   _AnimationScreenState createState() => _AnimationScreenState();
// }

// class _AnimationScreenState extends State<AnimationScreen> with TickerProviderStateMixin {
//   late AnimationController _animationController;
//   late List<MovementData> _sortedMovements;
//   late int _totalDuration;
//   Map<String, Map<int, Offset>> _currentPositions = {};

//   @override
//   void initState() {
//     super.initState();
//     _initializeAnimation();
//   }

//   void _initializeAnimation() {
//     List<Map<String, dynamic>> movements = widget.project.movementHistory;

//     if (movements.isEmpty) return;

//     // Extract and sort movements by timestamp
//     _sortedMovements = movements.map((data) => MovementData.fromMap(data)).toList()
//       ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

//     // Set duration based on the time difference between first and last movement
//     _totalDuration = _sortedMovements.last.timestamp - _sortedMovements.first.timestamp;

//     _animationController = AnimationController(
//       vsync: this,
//       duration: Duration(milliseconds: _totalDuration),
//     )..addListener(() {
//         setState(() {
//           _updatePositions();
//         });
//       });

//     // Initialize current positions from the first movement for each object
//     for (var movement in _sortedMovements) {
//       var objectType = movement.objectType;
//       var index = movement.index;
//       if (!_currentPositions.containsKey(objectType)) {
//         _currentPositions[objectType] = {};
//       }
//       _currentPositions[objectType]![index] = movement.oldPosition;
//     }

//     _animationController.forward(); // Start the animation
//   }

//   void _updatePositions() {
//     var currentTime = _animationController.value * _totalDuration +
//         _sortedMovements.first.timestamp;

//     // Find the latest movement before the current time
//     for (var movement in _sortedMovements) {
//       if (movement.timestamp <= currentTime) {
//         var objectType = movement.objectType;
//         var index = movement.index;
//         var oldPosition = movement.oldPosition;
//         var newPosition = movement.newPosition;

//         // Interpolate position
//         var progress = (currentTime - movement.timestamp) / (_totalDuration - movement.timestamp);

//         if (_currentPositions[objectType] != null) {
//           _currentPositions[objectType]![index] = Offset.lerp(oldPosition, newPosition, progress) ?? oldPosition;
//         }
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Animation: ${widget.project.name}'),
//         actions: [
//           IconButton(
//             icon: Icon(_animationController.isAnimating ? Icons.pause : Icons.play_arrow),
//             onPressed: () {
//               if (_animationController.isAnimating) {
//                 _animationController.stop();
//               } else {
//                 _animationController.forward(from: _animationController.value);
//               }
//               setState(() {});
//             },
//           ),
//           IconButton(
//             icon: Icon(Icons.replay),
//             onPressed: () {
//               _animationController.reset();
//               _initializeAnimation(); // Reset positions to initial state
//               setState(() {});
//             },
//           ),
//         ],
//       ),
//       body: Container(
//         width: double.infinity,
//         height: double.infinity,
//         decoration: const BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage('lib/assets/paddle-pitch.jpeg'),
//             fit: BoxFit.fill,
//           ),
//         ),
//         child: Stack(
//           children: [
//             ..._buildMarkers(
//                 'player',
//                 (pos) => PlayerMarker(
//                       position: pos,
//                       onPositionChanged: (Offset) {},
//                       onDragEnd: (Offset) {},
//                     )),
//             ..._buildMarkers(
//                 'coach',
//                 (pos) => CoachMarker(
//                       position: pos,
//                       onPositionChanged: (Offset) {},
//                       onDragEnd: (Offset) {},
//                     )),
//             ..._buildMarkers(
//                 'cone',
//                 (pos) => ConeMarker(
//                       position: pos,
//                       onPositionChanged: (Offset) {},
//                       onDragEnd: (Offset) {},
//                     )),
//             ..._buildMarkers(
//                 'ball',
//                 (pos) => BallMarker(
//                       position: pos,
//                       onPositionChanged: (Offset) {},
//                       onDragEnd: (Offset) {},
//                     )),
//             ..._buildMarkers(
//                 'agility',
//                 (pos) => AgilityMarker(
//                       position: pos,
//                       onPositionChanged: (Offset) {},
//                       onDragEnd: (Offset) {},
//                     )),
//             ..._buildMarkers(
//                 'strip',
//                 (pos) => StripMarker(
//                       position: pos,
//                       onPositionChanged: (Offset) {},
//                       onDragEnd: (Offset) {},
//                     )),
//             ..._buildMarkers(
//                 'basket',
//                 (pos) => BasketMarker(
//                       position: pos,
//                       onPositionChanged: (Offset) {},
//                       onDragEnd: (Offset) {},
//                     )),
//           ],
//         ),
//       ),
//     );
//   }

//   List<Widget> _buildMarkers(String type, Widget Function(Offset) markerBuilder) {
//     return _currentPositions[type]?.entries.map((entry) => markerBuilder(entry.value)).toList() ?? [];
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }
// }

// class MovementData {
//   final String objectType;
//   final int index;
//   final Offset oldPosition;
//   final Offset newPosition;
//   final int timestamp;

//   MovementData({
//     required this.objectType,
//     required this.index,
//     required this.oldPosition,
//     required this.newPosition,
//     required this.timestamp,
//   });

//    factory MovementData.fromMap(Map<String, dynamic> map) {
//     return MovementData(
//       objectType: map['objectType'],
//       index: map['index'],
//       oldPosition: Offset(map['oldPosition']['dx'].toDouble(), map['oldPosition']['dy'].toDouble())),
//       newPosition: Offset(map['newPosition']['dx'].toDouble(), map['newPosition']['dy'].toDouble())),
//       timestamp: map['timestamp'],
//     );
//   }
// }
