import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;
import 'dart:io';

import 'package:ffmpeg_kit_flutter/log.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:tactical_pad/database/database.dart';
import 'package:tactical_pad/views/pitch/components/animation.dart';
// import 'package:tactical_pad/views/pitch/components/ball_maker.dart';
// import 'package:tactical_pad/views/pitch/components/coach_maker.dart';
// import 'package:tactical_pad/views/pitch/components/cone_maker.dart';
import 'package:tactical_pad/views/pitch/components/create_project_dialogue.dart';
import 'package:tactical_pad/views/pitch/components/draw.dart';
import 'package:tactical_pad/views/pitch/components/makers.dart';
import 'package:tactical_pad/views/pitch/components/object_maker.dart';
import 'package:tactical_pad/views/pitch/components/object_menu.dart';
import 'package:tactical_pad/views/pitch/components/screen_recording.dart';
// import 'package:tactical_pad/views/pitch/components/player_maker_painter.dart';
import 'package:tactical_pad/views/pitch/components/timer_banner.dart';
import 'package:tactical_pad/views/pitch/components/video_player.dart';
import 'package:tactical_pad/views/pitch/frame_player.dart';
import 'package:tactical_pad/views/pitch/repository_screen.dart';
import 'package:tactical_pad/views/widgets/bottomsheet.dart';
import 'components/pitch_painter.dart';
import 'components/action_menu.dart';
import 'components/drawer_menu.dart';
import 'package:tactical_pad/models/project.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:video_player/video_player.dart';

class TacticalPad extends StatefulWidget {
  @override
  _TacticalPadState createState() => _TacticalPadState();
}

class _TacticalPadState extends State<TacticalPad>
    with TickerProviderStateMixin {
  late List<Offset> playerFivePositions;
  late List<Offset> playerFourPositions;
  late List<Offset> playerSixPositions;
  late List<Offset> playerPositions;
  late List<Offset> coachPositions;
  late List<Offset> conePositions;
  late List<Offset> ballPositions;
  late List<Offset> stripPositions;
  late List<Offset> agilityPositions;
  late List<Offset> podelpritPositions;
  late List<Offset> basketPositions;
  late List<Offset> lowConePositions;
  bool _isEraseMode = false;
  int _selectedIndex = 0;
  String? _currentProjectName;
  Project? _currentProject;
  bool _isRecording = false;
  // late Timer _recordingTimer;
  Duration _recordingTime = Duration.zero;
  late Map<String, List<Offset>> _positions;
  late Map<String, List<Offset>> _animatedPositions;

  late AnimationController _animationController;
  late Animation<double> _animation;
  DrawingType? _currentDrawingType;
  List<DrawingObject> _drawingObjects = [];
  List<Offset> _currentDrawingPoints = [];
  Color _currentDrawingColor = Colors.red;
  TextEditingController _textEditingController = TextEditingController();
  GlobalKey _repaintBoundaryKey = GlobalKey();
  List<ui.Image> _frames = [];
  String? _videoPath;
  VideoPlayerController? _videoPlayerController;
  bool _isVideoOverlayVisible = false;

  String _debugInfo = '';
  // bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);

    // Initialize all position lists
    playerPositions = [];
    playerFourPositions = [];
    playerFivePositions = [];
    playerSixPositions = [];
    coachPositions = [];
    conePositions = [];
    ballPositions = [];
    stripPositions = [];
    agilityPositions = [];
    podelpritPositions = [];
    basketPositions = [];
    lowConePositions = [];

    // Initialize _positions and _animatedPositions
    _positions = {
      'player': playerPositions,
      'player_4': playerPositions,
      'player_5': playerPositions,
      'player_6': playerPositions,
      'coach': coachPositions,
      'cone': conePositions,
      'ball': ballPositions,
      'strip': stripPositions,
      'agility': agilityPositions,
      'podelprit': podelpritPositions,
      'basket': basketPositions,
      'low_cone': lowConePositions,
    };

    _animatedPositions = Map.fromEntries(_positions.entries
        .map((entry) => MapEntry(entry.key, List<Offset>.from(entry.value))));

    // ... other initializations ...
  }

  void _handleErase(Offset position) {
    setState(() {
      final painter = DrawingPainter(_drawingObjects);
      painter.erase(position, 10.0); // Adjust the tolerance as needed
    });
  }

  void _showCreateProjectDialog() {
    print('_showCreateProjectDialog');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CreateProjectDialog(
          onProjectCreated: _onProjectCreated,
        );
      },
    );
  }

  void _toggleVideoOverlay() {
    setState(() {
      _isVideoOverlayVisible = !_isVideoOverlayVisible;
    });
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
        // lowConePositions:[],
        ballPositions: [],
      );

      DatabaseHelper().insertProject({
        'id': _currentProject!.id,
        'name': _currentProject!.name,
        'createdAt': _currentProject!.createdAt.toIso8601String(),
        'updatedAt': _currentProject!.updatedAt?.toIso8601String(),
      });

      // _startRecording();
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

  void playAnimation() {
    if (_currentProject == null || _currentProject!.movementHistory.isEmpty) {
      print("No project or movement history to animate.");
      return;
    }

    print("Starting animation...");
    int currentIndex = 0;
    var movements = _currentProject!.movementHistory;

    // Calculate total duration
    var totalDuration =
        movements.last['timestamp'] - movements.first['timestamp'];
    _animationController.duration = Duration(milliseconds: totalDuration);

    print("Animation duration set to $totalDuration milliseconds");

    _animationController.forward(from: 0);
    _animationController.addListener(() {
      var currentTime = movements.first['timestamp'] +
          (_animationController.value * totalDuration).round();

      print("Animation progress: ${_animationController.value}");
      print("Current time: $currentTime");

      while (currentIndex < movements.length &&
          movements[currentIndex]['timestamp'] <= currentTime) {
        var movement = movements[currentIndex];
        var objectType = movement['objectType'];
        var index = movement['index'];
        Offset newPosition;

        // Debugging movement details
        print(
            "Processing movement: objectType=$objectType, index=$index, oldPosition=${movement['oldPosition']}, newPosition=${movement['newPosition']}, timestamp=${movement['timestamp']}");
        print(
            "current index: =$currentIndex, movement length-1=${movements.length - 1}");

        // Check if there's a next movement to interpolate
        if (currentIndex <= movements.length - 1) {
          var nextMovement = movements[currentIndex + 1];
          var t = (currentTime - movement['timestamp']) /
              (nextMovement['timestamp'] - movement['timestamp']);
          t = t.clamp(0.0, 1.0); // Ensure t is between 0 and 1
          newPosition = Offset.lerp(movement['oldPosition'] as Offset,
              movement['newPosition'] as Offset, t)!;

          print(
              "Interpolating between ${movement['oldPosition']} and ${movement['newPosition']} with t=$t");
        } else {
          newPosition = movement['newPosition'] as Offset;
          print("Using final position: $newPosition");
        }

        // Update position in the state
        setState(() {
          if (_animatedPositions.containsKey(objectType) &&
              index < _animatedPositions[objectType]!.length) {
            _animatedPositions[objectType]![index] = newPosition;
            print("Updated $objectType at index $index to $newPosition");
          } else {
            print("Failed to update position for $objectType at index $index");
          }
        });

        // Move to the next movement if the current time is ahead
        if (movements[currentIndex]['timestamp'] <= currentTime) {
          currentIndex++;
          print("Moving to next movement");
        }
      }

      print("Current animated positions: ${_animatedPositions['player']}");
    });

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        print("Animation completed");
      }
    });
  }

  void _onActionSelected(String action) {
    // Navigator.pop(context); // Close the bottom sheet
    print(action);
    setState(() {
      if (action == 'player') {
        playerPositions.add(const Offset(100, 100));
      } else if (action == 'coach') {
        coachPositions.add(const Offset(100, 100));
      } else if (action == 'player_4') {
        playerFourPositions.add(const Offset(100, 100));
      } else if (action == 'player_5') {
        playerFivePositions.add(const Offset(100, 100));
      } else if (action == 'player_6') {
        playerSixPositions.add(const Offset(100, 100));
      } else if (action == 'cone') {
        conePositions.add(const Offset(100, 100));
      } else if (action == 'ball') {
        ballPositions.add(const Offset(100, 100));
      } else if (action == 'agility') {
        agilityPositions.add(const Offset(100, 100));
      } else if (action == 'strip') {
        stripPositions.add(const Offset(100, 100));
      } else if (action == 'basket') {
        basketPositions.add(const Offset(100, 100));
      } else if (action == 'podelprit') {
        podelpritPositions.add(const Offset(100, 100));
      } else if (action == 'low_cone') {
        lowConePositions.add(const Offset(100, 100));
      } else if (action == 'new_project') {
        _showCreateProjectDialog();
        // Navigator.of(context).pop();
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
      } else if (action == 'erase') {
        playerPositions.clear();
        coachPositions.clear();
        conePositions.clear();
        ballPositions.clear();
        _drawingObjects.clear();
      } else if (action == 'Save Formation') {
        // Implement save formation functionality
      } else if (action == 'Load Formation') {
        // Implement load formation functionality
      }
    });
  }

  void _showActionMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return buildFancyModalBottomSheet(context, _onActionSelected);
      },
    );
  }

  void _startDrawing(DrawingType type) {
    setState(() {
      _currentDrawingType = type;
      _currentDrawingPoints.clear();
    });
  }

  void _onPanStart(DragStartDetails details) {
    if (_currentDrawingType != null) {
      setState(() {
        _currentDrawingPoints.add(details.localPosition);
      });
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_currentDrawingType != null) {
      setState(() {
        _currentDrawingPoints.add(details.localPosition);
      });
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (_currentDrawingType != null) {
      setState(() {
        if (_currentDrawingType == DrawingType.text) {
          _showTextInputDialog();
        } else {
          _finishDrawing();
        }
      });
    }
  }

  void _finishDrawing() {
    if (_currentDrawingPoints.isNotEmpty) {
      _drawingObjects.add(DrawingObject(
        type: _currentDrawingType!,
        points: List.from(_currentDrawingPoints),
        color: _currentDrawingColor,
      ));
      _currentDrawingPoints.clear();
      _currentDrawingType = null;
    }
  }

  void _showTextInputDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter Text'),
          content: TextField(
            controller: _textEditingController,
            decoration: InputDecoration(hintText: 'Enter your text here'),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
                _currentDrawingPoints.clear();
                _currentDrawingType = null;
              },
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                _addTextObject();
              },
            ),
          ],
        );
      },
    );
  }

  void _addTextObject() {
    if (_currentDrawingPoints.isNotEmpty &&
        _textEditingController.text.isNotEmpty) {
      _drawingObjects.add(DrawingObject(
        type: DrawingType.text,
        points: [_currentDrawingPoints.first],
        text: _textEditingController.text,
        color: _currentDrawingColor,
      ));
      _textEditingController.clear();
      _currentDrawingPoints.clear();
      _currentDrawingType = null;
    }
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _currentDrawingColor,
              onColorChanged: (color) {
                setState(() {
                  _currentDrawingColor = color;
                });
              },
            ),
          ),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // New methods for screen recording
  Future<void> _captureFrame() async {
    RenderRepaintBoundary boundary = _repaintBoundaryKey.currentContext!
        .findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    _frames.add(image);
  }

  Future<void> _startRecording() async {
    setState(() {
      _isRecording = true;
    });
    while (_isRecording) {
      await _captureFrame();
      await Future.delayed(Duration(milliseconds: 33)); // Approx. 30 fps
    }
  }

  Future<void> _stopRecording() async {
    setState(() {
      _isRecording = false;
    });
    await _compileFramesToVideo();
  }

  Future<void> _compileFramesToVideo() async {
    try {
      Directory tempDir = await getTemporaryDirectory();
      String framesDir = '${tempDir.path}/frames';
      await Directory(framesDir).create(recursive: true);
      print('Saving frames to $framesDir');

      // Save each frame as an image
      for (int i = 0; i < _frames.length; i++) {
        final image = _frames[i];
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        final file =
            File('$framesDir/frame_${i.toString().padLeft(4, '0')}.png');
        await file.writeAsBytes(byteData!.buffer.asUint8List());
      }
      print('Frames saved. Total frames: ${_frames.length}');

      // Check first few frame files
      print('First few frame files:');
      for (int i = 0; i < min(_frames.length, 5); i++) {
        File frame =
            File('$framesDir/frame_${i.toString().padLeft(4, '0')}.png');
        print('${frame.path} exists: ${await frame.exists()}');
      }

      // Compile images into video
      Directory appDocDir = await getApplicationDocumentsDirectory();
      _videoPath = "${appDocDir.path}/output.mp4";

      print('Compiling video to $_videoPath');

      // Simplified FFmpeg command
      // String command =
      //     "-y -framerate 30 -i '$framesDir/frame_%04d.png' -c:v libx264 -pix_fmt yuv420p '$_videoPath'";
      // String command =
      //     "-y -framerate 30 -i '$framesDir/frame_%04d.png' -c:v mpeg4 '$_videoPath'";
      String command =
          "-y -framerate 30 -i '${framesDir}/frame_%04d.png' -c:v mpeg4 -pix_fmt yuv420p -movflags +faststart '${_videoPath}'";

      // Execute FFmpeg command
      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();
      final output = await session.getOutput();
      final logs = await session.getLogs();

      print('FFmpeg output: $output');
      print('FFmpeg logs:');
      for (Log log in logs) {
        print('${log.getLevel()} - ${log.getMessage()}');
      }

      if (ReturnCode.isSuccess(returnCode)) {
        print('Video compiled successfully');
      } else {
        print('Error compiling video. Return code: $returnCode');
      }

      // Check if the file exists and its size
      File videoFile = File(_videoPath!);
      if (await videoFile.exists()) {
        print('Video file exists at $_videoPath');
        print('File size: ${await videoFile.length()} bytes');
      } else {
        print('Video file does not exist at $_videoPath');
      }

      // Clear the frames
      _frames.clear();
    } catch (e) {
      print('Error in compileFramesToVideo: $e');
    }
  }

  Future<void> _playVideo() async {
    print('Attempting to play video');
    if (_videoPath != null) {
      File videoFile = File(_videoPath!);
      if (await videoFile.exists()) {
        print('Video file found at $_videoPath');
        try {
          _videoPlayerController = VideoPlayerController.file(videoFile)
            ..initialize().then((_) {
              setState(() {});
              _videoPlayerController!.play();
              print('Video playing');
            });
        } catch (e) {
          print('Error playing video: $e');
        }
      } else {
        print('Video file not found at $_videoPath');
      }
    } else {
      print('Video path is null');
    }
  }

  void _updateDebugInfo(String info) {
    setState(() {
      _debugInfo = info;
    });
  }

  @override
  void dispose() {
    // Remove the listener before disposing of the animation controller
    _animationController.removeListener(() {});
    _animationController.dispose();
    // _recordingTimer.cancel(); // Cancel the timer if it's still running
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(_debugInfo);
    void _onItemTapped(int index) {
      setState(() {
        _selectedIndex = index;
      });
      if (index == 0) {
        _showActionMenu(context);
      }
    }

    final padding = MediaQuery.of(context).size.height * 0.12;
    // List<Offset> positionsToUse = playerPositions;
    List<Offset> positionsToUse = _animationController.isAnimating
        ? _animatedPositions['player']!
        : playerPositions;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'PLP Tactical Board',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2E74B8), Color(0xFF2A5D83)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.save, color: Colors.white),
            onPressed: _saveProject,
          ),
          IconButton(
            icon: Icon(
              _isRecording ? Icons.stop : Icons.fiber_manual_record,
              color: Colors.white,
            ),
            onPressed: () async {
              if (_isRecording) {
                await _stopRecording();
              } else {
                await _startRecording();
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.play_arrow, color: Colors.white),
            onPressed: () {
              _playVideo;
              _toggleVideoOverlay();
            },
          ),
        ],
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
      ),
      backgroundColor: const Color(0xFF2A5D83),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            child: RepaintBoundary(
              key: _repaintBoundaryKey,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('lib/assets/paddle-pitch.jpeg'),
                    // image: AssetImage('lib/assets/padel-pitch-3.png'),
                    // image: AssetImage('lib/assets/padel-pitch-2.png'),
                    // image: AssetImage('lib/assets/padel-pitch-1.png'),
                    fit: BoxFit.fill,
                  ),
                ),
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onPanStart: _onPanStart,
                  onPanUpdate: _onPanUpdate,
                  onPanEnd: _onPanEnd,
                  child: Stack(
                    children: [
                      CustomPaint(
                        painter: DrawingPainter(_drawingObjects),
                        child: Container(),
                      ),
                      // Display player markers
                      ...positionsToUse.map((position) {
                        return PlayerMarker(
                          position: position,
                          onDragEnd: (offset) {
                            setState(() {
                              int index = playerPositions.indexOf(position);
                              if (index != -1) {
                                _currentProject?.recordMovement(
                                    'player', index, position, offset);
                                playerPositions[index] = offset;
                              }
                            });
                          },
                          onPositionChanged: (newPosition) {
                            _currentProject?.addCoordinate(
                                newPosition, 'player');
                            // setState(() {
                            //   playerPositions[index] = newPosition;
                            //   _currentProject?.recordMovement(
                            //       'player', index, position, newPosition);
                            // });
                          },
                        );
                      }).toList(),
                      // Display player markers
                      ...playerFourPositions.map((position) {
                        return PlayerFourMarker(
                          position: position,
                          onDragEnd: (offset) {
                            setState(() {
                              int index = playerFourPositions.indexOf(position);
                              if (index != -1) {
                                _currentProject?.recordMovement(
                                    'player', index, position, offset);
                                playerPositions[index] = offset;
                              }
                            });
                          },
                          onPositionChanged: (newPosition) {
                            _currentProject?.addCoordinate(
                                newPosition, 'player_4');
                            // setState(() {
                            //   playerPositions[index] = newPosition;
                            //   _currentProject?.recordMovement(
                            //       'player', index, position, newPosition);
                            // });
                          },
                        );
                      }).toList(),
                      // Display player markers
                      ...playerFivePositions.map((position) {
                        return PlayerFiveMarker(
                          position: position,
                          onDragEnd: (offset) {
                            setState(() {
                              int index = playerFivePositions.indexOf(position);
                              if (index != -1) {
                                _currentProject?.recordMovement(
                                    'player', index, position, offset);
                                playerPositions[index] = offset;
                              }
                            });
                          },
                          onPositionChanged: (newPosition) {
                            _currentProject?.addCoordinate(
                                newPosition, 'player_5');
                            // setState(() {
                            //   playerPositions[index] = newPosition;
                            //   _currentProject?.recordMovement(
                            //       'player', index, position, newPosition);
                            // });
                          },
                        );
                      }).toList(),
                      // Display player markers
                      ...playerSixPositions.map((position) {
                        return PlayerSixMarker(
                          position: position,
                          onDragEnd: (offset) {
                            setState(() {
                              int index = playerSixPositions.indexOf(position);
                              if (index != -1) {
                                _currentProject?.recordMovement(
                                    'player_6', index, position, offset);
                                playerSixPositions[index] = offset;
                              }
                            });
                          },
                          onPositionChanged: (newPosition) {
                            _currentProject?.addCoordinate(
                                newPosition, 'player_6');
                            // setState(() {
                            //   playerPositions[index] = newPosition;
                            //   _currentProject?.recordMovement(
                            //       'player', index, position, newPosition);
                            // });
                          },
                        );
                      }).toList(),

                      // Display coach markers
                      ...coachPositions.map((position) {
                        return CoachMarker(
                          position: position,
                          onDragEnd: (offset) {
                            setState(() {
                              coachPositions[coachPositions.indexOf(position)] =
                                  offset;
                            });
                          },
                          onPositionChanged: (newPosition) {
                            int index = playerPositions.indexOf(position);
                            _currentProject?.addCoordinate(
                                newPosition, 'coach');
                          },
                        );
                      }).toList(),

                      // Display cone markers
                      ...conePositions.map((position) {
                        return ConeMarker(
                          position: position,
                          onDragEnd: (offset) {
                            setState(() {
                              conePositions[conePositions.indexOf(position)] =
                                  offset;
                            });
                          },
                          onPositionChanged: (newPosition) {
                            int index = playerPositions.indexOf(position);
                            _currentProject?.addCoordinate(newPosition, 'cone');
                          },
                        );
                      }).toList(),
                      // Display low cone markers
                      ...lowConePositions.map((position) {
                        return LowConeMarker(
                          position: position,
                          onDragEnd: (offset) {
                            setState(() {
                              lowConePositions[
                                  lowConePositions.indexOf(position)] = offset;
                            });
                          },
                          onPositionChanged: (newPosition) {
                            int index = lowConePositions.indexOf(position);
                            _currentProject?.addCoordinate(
                                newPosition, 'low_cone');
                          },
                        );
                      }).toList(),

                      // Display ball markers
                      ...ballPositions.map((position) {
                        return BallMarker(
                          position: position,
                          onDragEnd: (offset) {
                            setState(() {
                              ballPositions[ballPositions.indexOf(position)] =
                                  offset;
                            });
                          },
                          onPositionChanged: (newPosition) {
                            int index = playerPositions.indexOf(position);
                            _currentProject?.addCoordinate(newPosition, 'ball');
                          },
                        );
                      }).toList(),
                      ...agilityPositions.map((position) {
                        return AgilityMarker(
                          position: position,
                          onDragEnd: (offset) {
                            setState(() {
                              agilityPositions[
                                  agilityPositions.indexOf(position)] = offset;
                            });
                          },
                          onPositionChanged: (newPosition) {
                            int index = playerPositions.indexOf(position);
                            _currentProject?.addCoordinate(
                                newPosition, 'agility');
                          },
                        );
                      }).toList(),
                      // ...podelpritPositions.map((position) {
                      //   return Podelprit(
                      //     position: position,
                      //     onDragEnd: (offset) {
                      //       setState(() {
                      //         podelpritPositions[
                      //             podelpritPositions.indexOf(position)] = offset;
                      //       });
                      //     },
                      //     onPositionChanged: (newPosition) {
                      //       int index = playerPositions.indexOf(position);
                      //       setState(() {
                      //         playerPositions[index] = newPosition;
                      //         _currentProject?.recordMovement(
                      //             'player', index, position, newPosition);
                      //       });
                      //     },
                      //   );
                      // }).toList(),
                      ...basketPositions.map((position) {
                        return BasketMarker(
                          position: position,
                          onDragEnd: (offset) {
                            setState(() {
                              basketPositions[
                                  basketPositions.indexOf(position)] = offset;
                            });
                          },
                          onPositionChanged: (newPosition) {
                            int index = playerPositions.indexOf(position);
                            _currentProject?.addCoordinate(
                                newPosition, 'basket');
                          },
                        );
                      }).toList(),
                      ...stripPositions.map((position) {
                        return StripMarker(
                          position: position,
                          onDragEnd: (offset) {
                            setState(() {
                              stripPositions[stripPositions.indexOf(position)] =
                                  offset;
                            });
                          },
                          onPositionChanged: (newPosition) {
                            int index = playerPositions.indexOf(position);
                            _currentProject?.addCoordinate(
                                newPosition, 'strip');
                          },
                        );
                      }).toList(),
                      if (_isVideoOverlayVisible &&
                          _videoPlayerController != null &&
                          _videoPlayerController!.value.isInitialized)
                        Positioned.fill(
                          child: ProGameVideoPlayer(
                            controller: _videoPlayerController!,
                            onClose: _toggleVideoOverlay,
                          ),
                        ),

                      // TimerBanner(duration: _recordingTime),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        color: Color(0xFF2E74B8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: Icon(Icons.line_style),
              onPressed: () => _startDrawing(DrawingType.line),
            ),
            IconButton(
              icon: Icon(Icons.arrow_forward),
              onPressed: () => _startDrawing(DrawingType.arrow),
            ),
            IconButton(
              icon: Icon(Icons.circle_outlined),
              onPressed: () => _startDrawing(DrawingType.circle),
            ),
            IconButton(
              icon: Icon(Icons.text_fields),
              onPressed: () => _startDrawing(DrawingType.text),
            ),
            IconButton(
              icon: Icon(Icons.color_lens),
              onPressed: () => _showColorPicker(),
            ),
          ],
        ),
      ),
      drawer: DrawerMenu(onActionSelected: _onActionSelected),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     _showCreateProjectDialog();
      //   },
      //   child: Icon(Icons.add_business_sharp),
      // ),
    );
  }
}
