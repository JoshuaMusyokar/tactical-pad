// PopupMenuButton<String>(
          //   onSelected: _onActionSelected,
          //   itemBuilder: (BuildContext context) {
          //     return [
          //       PopupMenuItem(value: 'new_project', child: Text('New Project')),
          //       PopupMenuItem(
          //           value: 'save_project', child: Text('Save Project')),
          //       PopupMenuItem(
          //           value: 'load_project', child: Text('Load Project')),
          //       PopupMenuItem(
          //           value: 'record_timeframe', child: Text('Record Timeframe')),
          //     ];
          //   },
          // ),
  //           void showPlayback(BuildContext context, List<Map<String, dynamic>> frames) {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => FramePlaybackWidget(frames: frames),
  //     ),
  //   );
  // }
  // void _playAnimation() {
  //   if (_currentProject == null || _currentProject!.movementData.isEmpty)
  //     return;

  //   // Reset positions to initial state
  //   _animatedPositions = {
  //     'player': List.from(playerPositions),
  //     'coach': List.from(coachPositions),
  //     'cone': List.from(conePositions),
  //     'ball': List.from(ballPositions),
  //     // Initialize other object types
  //   };

  //   _animationController.forward(from: 0);
  //   final animationValue = _animationController.value;
  //   _animationController.addListener(() {
  //     // print('Animation Value: $animationValue');

  //     if (_currentProject == null) return;

  //     setState(() {
  //       for (var movement in _currentProject!.movementData) {
  //         String objectType = movement['objectType'];
  //         int objectIndex = movement['objectIndex'];
  //         Offset startPosition = Offset(
  //             movement['startPosition']['dx'], movement['startPosition']['dy']);
  //         Offset endPosition = Offset(
  //             movement['endPosition']['dx'], movement['endPosition']['dy']);

  //         Offset currentPosition =
  //             Offset.lerp(startPosition, endPosition, animationValue)!;
  //         _animatedPositions[objectType]![objectIndex] = currentPosition;

  //         if (objectType == 'player') {
  //           _animatedPositions['player']![objectIndex] = currentPosition;
  //         } else if (objectType == 'coach') {
  //           _animatedPositions['coach']![objectIndex] = currentPosition;
  //         } else if (objectType == 'cone') {
  //           _animatedPositions['cone']![objectIndex] = currentPosition;
  //         } else if (objectType == 'ball') {
  //           _animatedPositions['ball']![objectIndex] = currentPosition;
  //         }

  //         // print(
  //         //     'Updated $objectType $objectIndex to position: $currentPosition');
  //       }
  //     });
  //   });
  // }
// void _playAnimation() {
//     if (_currentProject == null || _currentProject!.movementData.isEmpty)
//       return;

//     _animationController.forward(from: 0);
//   }
// void playRecordedAnimation() {
//     if (_currentProject == null || _currentProject!.movementData.isEmpty)
//       return;

//     _currentProject!.movementData
//         .sort((a, b) => a['timestamp'].compareTo(b['timestamp']));
//     final int baseTimestamp = _currentProject!.movementData.first['timestamp'];

//     for (var movement in _currentProject!.movementData) {
//       final objectType = movement['objectType'];
//       final objectIndex = movement['objectIndex'];
//       final startPosition = Offset(
//         movement['startPosition']['dx'],
//         movement['startPosition']['dy'],
//       );
//       final endPosition = Offset(
//         movement['endPosition']['dx'],
//         movement['endPosition']['dy'],
//       );
//       final timestamp = movement['timestamp'];
//       final int delay = timestamp - baseTimestamp;

//       _scheduleAnimation(
//           objectType, objectIndex, startPosition, endPosition, delay);
//     }
//   }

//   void _scheduleAnimation(String objectType, int objectIndex,
//       Offset startPosition, Offset endPosition, int delay) {
//     setState(() {});
//     Future.delayed(Duration(milliseconds: delay), () {
//       _animateObject(objectType, startPosition, endPosition);
//       // _animateObject(objectType, objectIndex, startPosition, endPosition);
//     });
//   }

//   void _animateObject(String objectType, Offset start, Offset end,
//       {Curve curve = Curves.easeInOut}) {
//     // Initialize the animation position for the object type
//     if (!_animatedPositions.containsKey(objectType)) {
//       _animatedPositions[objectType] =
//           List.filled(10, start); // Adjust the size as needed
//     } else {
//       // Clear previous positions
//       _animatedPositions[objectType]!.clear();
//       for (int i = 0; i < 10; i++) {
//         _animatedPositions[objectType]!
//             .add(start); // Populate the list with the start position
//       }
//     }

//     _animationController.reset();
//     _animationController.duration =
//         const Duration(milliseconds: 500); // Customize the duration as needed

//     _animationController.addListener(() {
//       if (!mounted) return;
//       setState(() {
//         // Update the Offset values in the animation position list
//         for (int i = _animatedPositions[objectType]!.length - 1; i > 0; i--) {
//           _animatedPositions[objectType]![i] =
//               _animatedPositions[objectType]![i - 1];
//         }
//         _animatedPositions[objectType]![0] = Tween(begin: start, end: end)
//             .chain(CurveTween(curve: curve))
//             .evaluate(_animationController);
//       });
//     });

//     _animationController.forward().then((_) {
//       if (!mounted) return;
//       setState(() {
//         // Update the final position in the animation position list
//         _animatedPositions[objectType]![0] = end;
//       });
//       _animationController.dispose(); // Dispose of the controller when done
//     });
//   }
// void playRecordedAnimation() {
//     if (_currentProject == null || _currentProject!.movementData.isEmpty)
//       return;

//     _currentProject!.movementData
//         .sort((a, b) => a['timestamp'].compareTo(b['timestamp']));
//     final int baseTimestamp = _currentProject!.movementData.first['timestamp'];

//     // Reset all animated positions to their initial state
//     _animatedPositions = {
//       'player': List.from(playerPositions),
//       'coach': List.from(coachPositions),
//       'cone': List.from(conePositions),
//       'ball': List.from(ballPositions),
//       'strip': List.from(stripPositions),
//       'agility': List.from(agilityPositions),
//       'podelprit': List.from(podelpritPositions),
//       'basket': List.from(basketPositions),
//     };

//     for (var movement in _currentProject!.movementData) {
//       final objectType = movement['objectType'];
//       final objectIndex = movement['objectIndex'];
//       final startPosition = Offset(
//         movement['startPosition']['dx'],
//         movement['startPosition']['dy'],
//       );
//       final endPosition = Offset(
//         movement['endPosition']['dx'],
//         movement['endPosition']['dy'],
//       );
//       final timestamp = movement['timestamp'];
//       final int delay = timestamp - baseTimestamp;

//       _scheduleAnimation(
//           objectType, objectIndex, startPosition, endPosition, delay);
//     }
//   }

//   void _scheduleAnimation(String objectType, int objectIndex,
//       Offset startPosition, Offset endPosition, int delay) {
//     Future.delayed(Duration(milliseconds: 30), () {
//       _animateObject(objectType, objectIndex, startPosition, endPosition);
//     });
//   }

//   void _animateObject(
//       String objectType, int objectIndex, Offset start, Offset end) {
//     AnimationController controller = AnimationController(
//       duration: const Duration(milliseconds: 500),
//       vsync: this,
//     );

//     Animation<Offset> animation = Tween(begin: start, end: end)
//         .animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

//     animation.addListener(() {
//       if (!mounted) return;
//       setState(() {
//         _animatedPositions[objectType]![objectIndex] = animation.value;
//       });
//     });

//     controller.forward().then((_) {
//       controller.dispose();
//     });
//   }