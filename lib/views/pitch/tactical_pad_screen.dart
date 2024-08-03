import 'package:flutter/material.dart';
import 'package:tactical_pad/views/pitch/components/ball_maker.dart';
import 'package:tactical_pad/views/pitch/components/bottom_navigations.dart';
import 'package:tactical_pad/views/pitch/components/coach_maker.dart';
import 'package:tactical_pad/views/pitch/components/cone_maker.dart';
import 'package:tactical_pad/views/pitch/components/player_maker_painter.dart';
import 'components/pitch_painter.dart';
import 'components/action_menu.dart';
import 'components/drawer_menu.dart';

class TacticalPad extends StatefulWidget {
  @override
  _TacticalPadState createState() => _TacticalPadState();
}

class _TacticalPadState extends State<TacticalPad> {
  late List<Offset> playerPositions;
  late List<Offset> coachPositions;
  late List<Offset> conePositions;
  late List<Offset> ballPositions;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    playerPositions =
        List.generate(11, (index) => Offset(100 + (index * 30.0), 100));
    coachPositions = [];
    conePositions = [];
    ballPositions = [];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      _showActionMenu();
    }
  }

  void _showActionMenu() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ActionMenu(onActionSelected: _onActionSelected);
      },
    );
  }

  void _onActionSelected(String action) {
    Navigator.pop(context); // Close the bottom sheet
    setState(() {
      if (action == 'Add Player') {
        playerPositions.add(const Offset(100, 100));
      } else if (action == 'Add Coach') {
        coachPositions.add(const Offset(100, 100));
      } else if (action == 'Add Cone') {
        conePositions.add(const Offset(100, 100));
      } else if (action == 'Add Ball') {
        ballPositions.add(const Offset(100, 100));
      } else if (action == 'Draw Line') {
        // Implement draw line functionality
      } else if (action == 'Erase Objects') {
        // Implement erase objects functionality
        playerPositions.clear();
        coachPositions.clear();
        conePositions.clear();
        ballPositions.clear();
      } else if (action == 'Save Formation') {
        // Implement save formation functionality
      } else if (action == 'Load Formation') {
        // Implement load formation functionality
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tactical Pad'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              CustomPaint(
                size: Size(constraints.maxWidth, constraints.maxHeight),
                painter: PaddleCourtPainter(),
              ),
              ...playerPositions.asMap().entries.map((entry) {
                int idx = entry.key;
                Offset position = entry.value;
                return PlayerMarker(
                  position: position,
                  onDragEnd: (offset) {
                    setState(() {
                      playerPositions[idx] = offset;
                    });
                  },
                );
              }).toList(),
              ...coachPositions.asMap().entries.map((entry) {
                int idx = entry.key;
                Offset position = entry.value;
                return CoachMarker(
                  position: position,
                  onDragEnd: (offset) {
                    setState(() {
                      coachPositions[idx] = offset;
                    });
                  },
                );
              }).toList(),
              ...conePositions.asMap().entries.map((entry) {
                int idx = entry.key;
                Offset position = entry.value;
                return ConeMarker(
                  position: position,
                  onDragEnd: (offset) {
                    setState(() {
                      conePositions[idx] = offset;
                    });
                  },
                );
              }).toList(),
              ...ballPositions.asMap().entries.map((entry) {
                int idx = entry.key;
                Offset position = entry.value;
                return BallMarker(
                  position: position,
                  onDragEnd: (offset) {
                    setState(() {
                      ballPositions[idx] = offset;
                    });
                  },
                );
              }).toList(),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomMenuBar(onActionSelected: _onActionSelected),

      // bottomNavigationBar: OrientationBuilder(
      //   builder: (context, orientation) {
      //     return orientation == Orientation.landscape
      //         ? BottomMenuBar(onActionSelected: _onActionSelected)
      //         : SizedBox.shrink();
      //   },
      // ),
      drawer: OrientationBuilder(
        builder: (context, orientation) {
          return orientation == Orientation.portrait
              ? DrawerMenu(onActionSelected: _onActionSelected)
              : SizedBox.shrink();
        },
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:tactical_pad/views/pitch/components/bottom_navigations.dart';
// import 'package:tactical_pad/views/pitch/components/player_maker_painter.dart';
// import 'components/pitch_painter.dart';
// import 'package:flutter/material.dart';
// import 'package:tactical_pad/views/pitch/components/player_maker_painter.dart';
// import 'components/pitch_painter.dart';
// import 'components/action_menu.dart';
// import 'components/drawer_menu.dart';

// class TacticalPad extends StatefulWidget {
//   @override
//   _TacticalPadState createState() => _TacticalPadState();
// }

// class _TacticalPadState extends State<TacticalPad> {
//   late List<Offset> playerPositions;
//   late List<Offset> coachPositions;
//   late List<Offset> conePositions;
//   late List<Offset> ballPositions;
//   int _selectedIndex = 0;

//   @override
//   void initState() {
//     super.initState();
//     playerPositions =
//         List.generate(11, (index) => Offset(100 + (index * 30.0), 100));
//     coachPositions = [];
//     conePositions = [];
//     ballPositions = [];
//   }

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//     if (index == 0) {
//       _showActionMenu();
//     }
//   }

//   void _showActionMenu() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return ActionMenu(onActionSelected: _onActionSelected);
//       },
//     );
//   }

//   void _onActionSelected(String action) {
//     setState(() {
//       if (action == 'Add Player') {
//         playerPositions.add(const Offset(100, 100));
//       } else if (action == 'Add Coach') {
//         coachPositions.add(const Offset(100, 100));
//       } else if (action == 'Add Cone') {
//         conePositions.add(const Offset(100, 100));
//       } else if (action == 'Add Ball') {
//         ballPositions.add(const Offset(100, 100));
//       } else if (action == 'Draw Line') {
//         // Implement draw line functionality
//       } else if (action == 'Erase Objects') {
//         // Implement erase objects functionality
//         playerPositions.clear();
//         coachPositions.clear();
//         conePositions.clear();
//         ballPositions.clear();
//       } else if (action == 'Save Formation') {
//         // Implement save formation functionality
//       } else if (action == 'Load Formation') {
//         // Implement load formation functionality
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Tactical Pad'),
//       ),
//       body: LayoutBuilder(
//         builder: (context, constraints) {
//           return Stack(
//             children: [
//               CustomPaint(
//                 size: Size(constraints.maxWidth, constraints.maxHeight),
//                 painter: PaddleCourtPainter(),
//               ),
//               ...playerPositions.asMap().entries.map((entry) {
//                 int idx = entry.key;
//                 Offset position = entry.value;
//                 return Positioned(
//                   left: position.dx,
//                   top: position.dy,
//                   child: Draggable(
//                     feedback: buildPlayerMarker(),
//                     childWhenDragging: Container(),
//                     onDraggableCanceled: (velocity, offset) {
//                       setState(() {
//                         playerPositions[idx] = offset;
//                       });
//                     },
//                     child: buildPlayerMarker(),
//                   ),
//                 );
//               }).toList(),
//               ...coachPositions.asMap().entries.map((entry) {
//                 int idx = entry.key;
//                 Offset position = entry.value;
//                 return Positioned(
//                   left: position.dx,
//                   top: position.dy,
//                   child: Draggable(
//                     feedback: buildCoachMarker(),
//                     childWhenDragging: Container(),
//                     onDraggableCanceled: (velocity, offset) {
//                       setState(() {
//                         coachPositions[idx] = offset;
//                       });
//                     },
//                     child: buildCoachMarker(),
//                   ),
//                 );
//               }).toList(),
//               ...conePositions.asMap().entries.map((entry) {
//                 int idx = entry.key;
//                 Offset position = entry.value;
//                 return Positioned(
//                   left: position.dx,
//                   top: position.dy,
//                   child: Draggable(
//                     feedback: buildConeMarker(),
//                     childWhenDragging: Container(),
//                     onDraggableCanceled: (velocity, offset) {
//                       setState(() {
//                         conePositions[idx] = offset;
//                       });
//                     },
//                     child: buildConeMarker(),
//                   ),
//                 );
//               }).toList(),
//               ...ballPositions.asMap().entries.map((entry) {
//                 int idx = entry.key;
//                 Offset position = entry.value;
//                 return Positioned(
//                   left: position.dx,
//                   top: position.dy,
//                   child: Draggable(
//                     feedback: buildBallMarker(),
//                     childWhenDragging: Container(),
//                     onDraggableCanceled: (velocity, offset) {
//                       setState(() {
//                         ballPositions[idx] = offset;
//                       });
//                     },
//                     child: buildBallMarker(),
//                   ),
//                 );
//               }).toList(),
//             ],
//           );
//         },
//       ),
//       bottomNavigationBar: OrientationBuilder(
//         builder: (context, orientation) {
//           return orientation == Orientation.landscape
//               ? BottomMenuBar(onActionSelected: _onActionSelected)
//               : SizedBox.shrink();
//         },
//       ),
//       drawer: OrientationBuilder(
//         builder: (context, orientation) {
//           return orientation == Orientation.portrait
//               ? DrawerMenu(onActionSelected: _onActionSelected)
//               : SizedBox.shrink();
//         },
//       ),
//       // bottomNavigationBar: BottomNavigationBar(
//       //   items: const <BottomNavigationBarItem>[
//       //     BottomNavigationBarItem(
//       //       icon: Icon(Icons.add_circle),
//       //       label: 'Menu',
//       //     ),
//       //     BottomNavigationBarItem(
//       //       icon: Icon(Icons.save),
//       //       label: 'Save',
//       //     ),
//       //     BottomNavigationBarItem(
//       //       icon: Icon(Icons.settings),
//       //       label: 'Settings',
//       //     ),
//       //   ],
//       //   currentIndex: _selectedIndex,
//       //   selectedItemColor: Colors.amber[800],
//       //   onTap: _onItemTapped,
//       // ),
//     );
//   }

//   Widget buildPlayerMarker() {
//     return Image.asset(
//       'lib/assets/player.png',
//       width: 40,
//       height: 80,
//     );
//   }

//   Widget buildCoachMarker() {
//     return Image.asset(
//       'lib/assets/coach.png',
//       width: 40,
//       height: 80,
//     );
//   }

//   Widget buildConeMarker() {
//     return Image.asset(
//       'lib/assets/cone.png',
//       width: 40,
//       height: 80,
//     );
//   }

//   Widget buildBallMarker() {
//     return Image.asset(
//       'lib/assets/ball.png',
//       width: 40,
//       height: 40,
//     );
//   }
// }
