import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tactical_pad/database/database.dart';
import 'package:tactical_pad/views/pitch/components/ball_maker.dart';
import 'package:tactical_pad/views/pitch/components/coach_maker.dart';
import 'package:tactical_pad/views/pitch/components/cone_maker.dart';
import 'package:tactical_pad/views/pitch/components/create_project_dialogue.dart';
import 'package:tactical_pad/views/pitch/components/player_maker_painter.dart';
import 'package:tactical_pad/views/pitch/components/timer_banner.dart';
import 'package:tactical_pad/views/pitch/frame_player.dart';
import 'package:tactical_pad/views/pitch/repository_screen.dart';
import 'components/pitch_painter.dart';
import 'components/action_menu.dart';
import 'components/drawer_menu.dart';
import 'package:tactical_pad/models/project.dart';

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
  String? _currentProjectName;
  Project? _currentProject;
  bool _isRecording = false;
  late Timer _recordingTimer;
  Duration _recordingTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    playerPositions = [];
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

  void _showCreateProjectDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CreateProjectDialog(
          onProjectCreated: _onProjectCreated,
        );
      },
    );
  }

  void _onProjectCreated(String projectName) {
    setState(() {
      _currentProject = Project(
        id: UniqueKey().toString(),
        name: projectName,
        createdAt: DateTime.now(),
        playerPositions: [],
        coachPositions: [],
        conePositions: [],
        ballPositions: [],
      );

      DatabaseHelper().insertProject({
        'id': _currentProject!.id,
        'name': _currentProject!.name,
        'createdAt': _currentProject!.createdAt.toIso8601String(),
        'updatedAt': _currentProject!.updatedAt?.toIso8601String(),
      });

      _startRecording();
    });
  }

  Future<void> _playbackFrames() async {
    if (_currentProject == null) return;

    for (var frame in _currentProject!.recordedFrames) {
      // Update positions based on frame data
      setState(() {
        playerPositions = frame['playerPositions'];
        coachPositions = frame['coachPositions'];
        conePositions = frame['conePositions'];
        ballPositions = frame['ballPositions'];
      });
      await Future.delayed(Duration(milliseconds: 100)); // Delay between frames
    }
  }

  void _startRecording() {
    if (!_isRecording) {
      setState(() {
        _isRecording = true;
        _recordingTime = Duration.zero;
      });
      _recordingTimer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
        if (!_isRecording) {
          timer.cancel();
        } else {
          // Capture the current state as a frame
          _currentProject?.recordTimeframe(
            playerPositions,
            coachPositions,
            conePositions,
            ballPositions,
          );
          setState(() {
            _recordingTime = _recordingTime + Duration(seconds: 1);
          });
        }
      });
    }
  }

  void _stopRecording() {
    if (_isRecording) {
      setState(() {
        _isRecording = false;
      });
    }
  }

  void _saveProject() {
    if (_currentProject == null) return;

    _currentProject!.playerPositions = playerPositions;
    _currentProject!.coachPositions = coachPositions;
    _currentProject!.conePositions = conePositions;
    _currentProject!.ballPositions = ballPositions;

    DatabaseHelper().updateProject({
      'id': _currentProject!.id,
      'name': _currentProject!.name,
      'playerPositions': jsonEncode(
          playerPositions.map((e) => {'dx': e.dx, 'dy': e.dy}).toList()),
      'coachPositions': jsonEncode(
          coachPositions.map((e) => {'dx': e.dx, 'dy': e.dy}).toList()),
      'conePositions': jsonEncode(
          conePositions.map((e) => {'dx': e.dx, 'dy': e.dy}).toList()),
      'ballPositions': jsonEncode(
          ballPositions.map((e) => {'dx': e.dx, 'dy': e.dy}).toList()),
      'recordedFrames': jsonEncode(_currentProject!.recordedFrames),
      'updatedAt': DateTime.now().toIso8601String(),
    });
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
      } else if (action == 'new_project') {
        _showCreateProjectDialog();
      } else if (action == 'save_project') {
        _saveProject();
      } else if (action == 'load_project') {
        // Implement loading logic
      } else if (action == 'record_timeframe') {
        // _currentProject?.recordTimeframe();
      } else if (action == 'Draw Line') {
        // Implement draw line functionality
      } else if (action == 'repositories') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                RepositoryScreen(projectId: _currentProject?.id ?? ''),
          ),
        );
      } else if (action == 'Erase Objects') {
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

  void showPlayback(BuildContext context, List<Map<String, dynamic>> frames) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FramePlaybackWidget(frames: frames),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tactical Pad'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 166, 92, 245),
                Color.fromARGB(255, 116, 100, 218)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: _onActionSelected,
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(value: 'new_project', child: Text('New Project')),
                PopupMenuItem(
                    value: 'save_project', child: Text('Save Project')),
                PopupMenuItem(
                    value: 'load_project', child: Text('Load Project')),
                PopupMenuItem(
                    value: 'record_timeframe', child: Text('Record Timeframe')),
              ];
            },
          ),
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveProject,
          ),
          IconButton(
            icon: Icon(Icons.play_arrow),
            onPressed: () {
              if (_currentProject != null) {
                print(_currentProject!.recordedFrames);
                showPlayback(context, _currentProject!.recordedFrames);
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.stop),
            onPressed: _isRecording ? _stopRecording : null,
          ),
          IconButton(
            icon: Icon(Icons.play_arrow),
            onPressed: !_isRecording ? _startRecording : null,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                      'lib/assets/paddle-pitch.jpeg'), // Replace with your image path
                  fit: BoxFit.cover, // Adjust this as needed
                ),
              ),
              child: Stack(
                children: [
                  // CustomPaint(
                  //   size: Size(constraints.maxWidth, constraints.maxHeight),
                  //   painter: PaddleCourtPainter(),
                  // ),
                  ...playerPositions.map((position) {
                    return Positioned(
                      left: position.dx,
                      top: position.dy,
                      child: PlayerMarker(
                        position: position,
                        onDragEnd: (offset) {
                          setState(() {
                            playerPositions[playerPositions.indexOf(position)] =
                                offset;
                          });
                        },
                      ),
                    );
                  }).toList(),
                  ...coachPositions.map((position) {
                    return Positioned(
                      left: position.dx,
                      top: position.dy,
                      child: CoachMarker(
                        position: position,
                        onDragEnd: (offset) {
                          setState(() {
                            coachPositions[coachPositions.indexOf(position)] =
                                offset;
                          });
                        },
                      ),
                    );
                  }).toList(),
                  ...conePositions.map((position) {
                    return Positioned(
                      left: position.dx,
                      top: position.dy,
                      child: ConeMarker(
                        position: position,
                        onDragEnd: (offset) {
                          setState(() {
                            conePositions[conePositions.indexOf(position)] =
                                offset;
                          });
                        },
                      ),
                    );
                  }).toList(),
                  ...ballPositions.map((position) {
                    return Positioned(
                      left: position.dx,
                      top: position.dy,
                      child: BallMarker(
                        position: position,
                        onDragEnd: (offset) {
                          setState(() {
                            ballPositions[ballPositions.indexOf(position)] =
                                offset;
                          });
                        },
                      ),
                    );
                  }).toList(),
                  if (_isRecording) TimerBanner(),
                  // TimerBanner(duration: _recordingTime),
                ],
              ),
            ),
          );
        },
      ),
      drawer: DrawerMenu(onActionSelected: _onActionSelected),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 166, 92, 245),
              Color.fromARGB(255, 116, 100, 218)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.add),
              label: 'Actions',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.library_books),
              label: 'Repositories',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
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
