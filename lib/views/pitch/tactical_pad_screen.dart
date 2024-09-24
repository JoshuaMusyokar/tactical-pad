import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/gestures.dart';
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
import 'package:tactical_pad/views/pitch/components/custom-bottom.dart';
import 'package:tactical_pad/views/pitch/components/draw.dart';
import 'package:tactical_pad/views/pitch/components/makers.dart';
import 'package:tactical_pad/views/pitch/components/object_maker.dart';
import 'package:tactical_pad/views/pitch/components/object_menu.dart';
import 'package:tactical_pad/views/pitch/components/screen_recording.dart';
// import 'package:tactical_pad/views/pitch/components/player_maker_painter.dart';
import 'package:tactical_pad/views/pitch/components/timer_banner.dart';
import 'package:tactical_pad/views/pitch/components/video_player.dart';
import 'package:tactical_pad/views/pitch/components/zoomable.dart';
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
  DrawingObject? _selectedDrawingObject;
  Offset? _dragStartPosition;
  Offset? _dragOffset;
  // DrawingObject? selectedObject;

  bool _isEraseMode = false;
  int _selectedIndex = 0;
  String? _currentProjectName;
  Project? _currentProject;
  bool _isRecording = false;
  int _frameCount = 0;
  double _progress = 0.0;
  double _scale = 1.0;
  double _canvasScale = 1.0;
  Offset _canvasPanOffset = Offset.zero;
  // late Timer _recordingTimer;
  Duration _recordingTime = Duration.zero;
  late Map<String, List<Offset>> _positions;
  late Map<String, List<Offset>> _animatedPositions;
  TextEditingController _textController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _animation;
  DrawingType? _currentDrawingType;
  List<DrawingObject> _drawingObjects = [];
  List<Offset> _currentDrawingPoints = [];
  Color _currentDrawingColor = Colors.red;
  TextEditingController _textEditingController = TextEditingController();
  GlobalKey _repaintBoundaryKey = GlobalKey();
  List<ui.Image> _frames = [];
  bool isEraseMode = false;
  DrawingObject? _currentDrawingObject;
  String? _videoPath;
  VideoPlayerController? _videoPlayerController;
  bool _isVideoOverlayVisible = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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
      // painter.erase(position, 10.0); // Adjust the tolerance as needed
    });
  }

  Future<void> _initializeVideoPlayer() async {
    if (_videoPath != null && _videoPath!.isNotEmpty) {
      File videoFile = File(_videoPath!);
      if (await videoFile.exists()) {
        try {
          _videoPlayerController = VideoPlayerController.file(videoFile);
          await _videoPlayerController!.initialize();
          setState(() {}); // Trigger rebuild after initialization
        } catch (e) {
          print('Error initializing video player: $e');
          // Handle the error (e.g., show an error message to the user)
        }
      } else {
        print('Video file not found at $_videoPath');
        // Handle the case when the file doesn't exist
      }
    } else {
      print('Video path is null or empty');
      // Handle the case when there's no video path
    }
  }

  void _toggleVideoOverlay() async {
    if (_videoPlayerController == null ||
        !_videoPlayerController!.value.isInitialized) {
      await _initializeVideoPlayer();
    }

    if (_videoPlayerController != null &&
        _videoPlayerController!.value.isInitialized) {
      setState(() {
        _isVideoOverlayVisible = !_isVideoOverlayVisible;
      });

      if (_isVideoOverlayVisible) {
        _videoPlayerController!.play();
      } else {
        _videoPlayerController!.pause();
      }
    } else {
      // Show an error message or handle the case when video can't be played
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Unable to play video. Please try again later.')),
      );
    }
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
        // _showCreateProjectDialog();
        // Navigator.of(context).pop();
      } else if (action == 'save_project') {
        // _saveProject();
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

  // void _onPanStart(DragStartDetails details) {
  //   if (_currentDrawingType != null) {
  //     // Drawing a new object
  //     setState(() {
  //       _currentDrawingPoints.clear(); // Clear previous points
  //       _currentDrawingPoints.add(details.localPosition);
  //       _currentDrawingObject = DrawingObject(
  //         type: _currentDrawingType!,
  //         points: [details.localPosition],
  //         color: _currentDrawingColor,
  //       );
  //       _drawingObjects.add(_currentDrawingObject!);
  //     });
  //   } else {
  //     // Check if a drawing object was touched
  //     final hitObject = DrawingPainter(_drawingObjects)
  //         .getObjectAtPoint(details.localPosition);
  //     if (hitObject != null) {
  //       setState(() {
  //         _selectedDrawingObject = hitObject;
  //         _dragStartPosition = details.localPosition;
  //         _dragOffset = Offset.zero;
  //       });
  //     } else if (_currentDrawingType == DrawingType.text) {
  //       // Open text input dialog immediately
  //       _showTextInputDialog();
  //     }
  //   }
  // }

  void _onPanStart(DragStartDetails details) {
    RenderBox box = context.findRenderObject() as RenderBox;
    Offset localPosition = box.globalToLocal(details.globalPosition);
    print('onPanStart triggered at ${details.localPosition}');
    print('onPanStart triggered at G ${localPosition}');
    print('Current drawing type: $_currentDrawingType');

    if (_currentDrawingType != null) {
      // Start a new drawing
      setState(() {
        _currentDrawingPoints.clear(); // Clear previous points
        _currentDrawingPoints.add(details.localPosition);

        _selectedDrawingObject = DrawingObject(
          type: _currentDrawingType!,
          points: [details.localPosition],
          color: _currentDrawingColor,
        );
        _drawingObjects.add(_selectedDrawingObject!);
        print('New drawing object created: ${_selectedDrawingObject!.type}');
        print('Total objects: ${_drawingObjects.length}');
      });
    } else {
      // Check if an existing object was touched
      // final hitObject = DrawingPainter(_drawingObjects)
      //     .getObjectAtPoint(details.localPosition);
      final hitObject = _getTappedOObject(details.localPosition);
      print('Drag started at position: ${details.localPosition}');
      print('Selected hit object: ${hitObject}');
      _handleObjectDetection(details.localPosition);

      if (hitObject != null) {
        setState(() {
          _selectedDrawingObject = hitObject;
          _dragStartPosition = details.localPosition;
          _dragOffset = Offset.zero;
        });
        print('Selected existing object: ${_selectedDrawingObject!.type}');
        print('Drag started at position: $_dragStartPosition');
      } else {
        print('No object selected');
      }
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    print("Pan updated at: ${details.localPosition}");

    if (_currentDrawingType != null && _selectedDrawingObject != null) {
      // Continue drawing
      setState(() {
        _selectedDrawingObject!.points.add(details.localPosition);
        // _selectedDrawingObject!.updateBoundingBox();
      });
      print("Drawing: ${_selectedDrawingObject!.type}");
      print("Points count: ${_selectedDrawingObject!.points.length}");
    } else if (_selectedDrawingObject != null && _dragStartPosition != null) {
      // Dragging an existing object
      setState(() {
        final newOffset = details.localPosition - _dragStartPosition!;
        _dragOffset = newOffset;
      });
      print("Dragging: ${_selectedDrawingObject!.type}");
      print("Drag offset: $_dragOffset");
    } else {
      print("Pan update ignored: No active drawing or dragging");
    }
  }

  void _onPanEnd(DragEndDetails details) {
    print("Pan ended");
    if (_currentDrawingType != null) {
      if (_currentDrawingType == DrawingType.text) {
        // When drawing text, handle input dialog
        _showTextInputDialog();
      }
      // Finish drawing
      print("Finished drawing: ${_selectedDrawingObject!.type}");
      print("Final point count: ${_selectedDrawingObject!.points.length}");
      _currentDrawingType = null;
      _currentDrawingType = null;
    } else if (_selectedDrawingObject != null && _dragOffset != null) {
      // Apply the drag to the object
      setState(() {
        _selectedDrawingObject!.translate(_dragOffset!);
        print("Finished dragging: ${_selectedDrawingObject!.type}");
        print("Final position: ${_selectedDrawingObject!.points.first}");
        print("Final bounding box: ${_selectedDrawingObject!.boundingBox}");
        _selectedDrawingObject = null;
        _dragStartPosition = null;
        _dragOffset = null;
      });
    } else {
      print("Pan end ignored: No active drawing or dragging");
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

  void _handleObjectDetection(Offset point) {
    const double detectionRadius = 20.0;

    final hitObject = _getTappedOObject(point);
    if (hitObject != null) {
      print('Object detected: ${hitObject.type} at $point');
      _selectedDrawingObject = hitObject;
    } else {
      print('No object detected at $point');
      _selectedDrawingObject = null;
    }
  }

  bool _isPointInPolygon(Offset point, List<Offset> polygon) {
    int intersectCount = 0;
    for (int i = 0; i < polygon.length; i++) {
      final p1 = polygon[i];
      final p2 = polygon[(i + 1) % polygon.length];

      if ((point.dy > min(p1.dy, p2.dy)) &&
          (point.dy <= max(p1.dy, p2.dy)) &&
          (point.dx <= max(p1.dx, p2.dx)) &&
          (p1.dy != p2.dy)) {
        double xIntersect =
            (point.dy - p1.dy) * (p2.dx - p1.dx) / (p2.dy - p1.dy) + p1.dx;
        if (p1.dx == p2.dx || point.dx <= xIntersect) {
          intersectCount++;
        }
      }
    }
    return (intersectCount % 2 != 0); // Inside if odd, outside if even
  }

  Rect expandedBoundingBox(Rect boundingBox, double padding) {
    return boundingBox.inflate(padding); // Inflate by padding on all sides
  }
// bool _isPointInPolygon(Offset point, List<Offset> polygon) {
//   int intersectCount = 0;
//   for (int i = 0; i < polygon.length; i++) {
//     final p1 = polygon[i];
//     final p2 = polygon[(i + 1) % polygon.length];

//     if ((point.dy > min(p1.dy, p2.dy)) &&
//         (point.dy <= max(p1.dy, p2.dy)) &&
//         (point.dx <= max(p1.dx, p2.dx)) &&
//         (p1.dy != p2.dy)) {
//       double xIntersect = (point.dy - p1.dy) * (p2.dx - p1.dx) / (p2.dy - p1.dy) + p1.dx;
//       if (p1.dx == p2.dx || point.dx <= xIntersect) {
//         intersectCount++;
//       }
//     }
//   }
//   return (intersectCount % 2 != 0); // Inside if odd, outside if even
// }

  DrawingObject? _getTappedOObject(Offset point,
      {double detectionRadius = 50.0}) {
    print(
        '\nChecking for tapped object at $point with radius $detectionRadius');
    print('Total objects: ${_drawingObjects.length}');

    for (var object in _drawingObjects.reversed) {
      print('\nChecking object: ${object.type}');

      // Check if any point of the object is within the detection radius
      for (var objectPoint in object.points) {
        if ((objectPoint - point).distance <= detectionRadius) {
          print(
              'Object ${object.type} found within radius at point $objectPoint');
          return object;
        }
      }

      print('Object ${object.type} not within detection radius');
    }

    print('No object found within radius at point $point');
    return null;
  }

  DrawingObject? _getObjectByRegion(Offset point) {
    for (var object in _drawingObjects.reversed) {
      final center = object.boundingBox?.center;

      if (center != null) {
        double radius = 30.0; // Define object detection range (radius)

        // Check if the point is within the radius of the object
        if ((point - center).distanceSquared <= radius * radius) {
          print("Found object in region: ${object.type}");
          return object;
        }
      }
    }

    return null;
  }

  DrawingObject? _getClosestObject(Offset point) {
    const double detectionThreshold = 50.0; // Detection range for proximity

    DrawingObject? closestObject;
    double closestDistance = detectionThreshold; // Initial threshold

    for (var object in _drawingObjects.reversed) {
      // Calculate the distance between the gesture point and object center
      final center = object.boundingBox?.center;

      if (center != null) {
        double distance = (point - center).distance;
        if (distance < closestDistance) {
          closestDistance = distance;
          closestObject = object;
        }
      }
    }

    if (closestObject != null) {
      print("Closest object found: ${closestObject.type}");
    } else {
      print("No object within detection range.");
    }

    return closestObject;
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
                final text = _textEditingController.text;
                print('drawing points ${_currentDrawingPoints.isNotEmpty}');
                if (text.isNotEmpty && _currentDrawingPoints.isNotEmpty) {
                  _addTextObject(text); // Pass the text to the method
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _addTextObject(String text) {
    print('adding text');
    setState(() {
      _drawingObjects.add(DrawingObject(
        type: DrawingType.text,
        points: [_currentDrawingPoints.first],
        text: text,
        color: _currentDrawingColor,
      ));
      _textEditingController.clear();
      _currentDrawingPoints.clear();
      _currentDrawingType = null;
    });
  }

  void _onTapDown(TapDownDetails details) {
    RenderBox box = context.findRenderObject() as RenderBox;
    Offset localPosition = box.globalToLocal(details.globalPosition);

    print("Tap location: ${details.localPosition}");
    print("Tap Glocation: ${localPosition}");

    // Loop through the drawing objects to find the tapped one
    final tappedObject = _getTappedObject(details.localPosition);

    if (tappedObject != null) {
      print("Tapped on object: ${tappedObject.type}");
    } else {
      print("No object at this location");
    }

    if (isEraseMode) {
      if (tappedObject != null) {
        setState(() {
          _drawingObjects.remove(tappedObject); // Remove the tapped object
        });
      }
    } else {
      setState(() {
        _selectedDrawingObject = tappedObject; // Select the object
      });
    }
  }

  DrawingObject? _getTappedObject(Offset point) {
    const double radius = 20.0; // Define the radius for tap detection

    for (var object in _drawingObjects.reversed) {
      // Calculate the center point of the object's bounding box
      final center = object.boundingBox?.center;

      // Check if the bounding box exists and if the tap is within the radius
      if (center != null && (point - center).distance <= radius) {
        print("Found tapped object: ${object.type}");
        return object;
      }
    }
    return null;
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

  Future<void> _startRecording() async {
    setState(() {
      _isRecording = true;
      _frameCount = 0;
      _progress = 0.0;
    });

    while (_isRecording) {
      await _captureFrame();
      await Future.delayed(Duration(milliseconds: 33)); // ~30 fps
    }
  }

  Future<void> _stopRecording() async {
    setState(() {
      _isRecording = false;
    });
    _showProgressDialog();
    await _compileFramesToVideo();
    Navigator.of(context).pop(); // Dismiss progress dialog
    _showVideoPreview();
  }

  void _showVideoPreview() {
    if (_videoPath != null) {
      _videoPlayerController = VideoPlayerController.file(File(_videoPath!))
        ..initialize().then((_) {
          setState(() {});
          _videoPlayerController!.play();
        });

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: AspectRatio(
              aspectRatio: _videoPlayerController!.value.aspectRatio,
              child: VideoPlayer(_videoPlayerController!),
            ),
            actions: [
              TextButton(
                child: Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                  _videoPlayerController!.dispose();
                },
              ),
              TextButton(
                child: Text('Save'),
                onPressed: () {
                  // Implement save functionality
                  Navigator.of(context).pop();
                  _showSaveConfirmation();
                },
              ),
            ],
          );
        },
      );
    }
  }

  void _showSaveConfirmation() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Video saved successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showProgressDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Compiling video...'),
              SizedBox(height: 10),
              LinearProgressIndicator(value: _progress),
            ],
          ),
        );
      },
    );
  }

  void _eraseObject(DrawingObject object) {
    setState(() {
      _drawingObjects.remove(object);
    });
  }

  // void _addTextObject() {
  //   if (_currentDrawingPoints.isNotEmpty &&
  //       _textEditingController.text.isNotEmpty) {
  //     setState(() {
  //       _drawingObjects.add(DrawingObject(
  //         type: DrawingType.text,
  //         points: [_currentDrawingPoints.first],
  //         color: _currentDrawingColor,
  //         text: _textEditingController.text,
  //       ));
  //       _textEditingController.clear();
  //       _currentDrawingPoints.clear();
  //       _currentDrawingType = null;
  //     });
  //   }
  // }

  Future<void> _captureFrame() async {
    try {
      RenderRepaintBoundary boundary = _repaintBoundaryKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      _frames.add(image);
      setState(() {
        _frameCount++;
      });
    } catch (e) {
      print('Error capturing frame: $e');
    }
  }

  // Future<void> _compileFramesToVideo() async {
  //   try {
  //     Directory tempDir = await getTemporaryDirectory();
  //     String framesDir = '${tempDir.path}/frames';
  //     await Directory(framesDir).create(recursive: true);
  //     print('Saving frames to $framesDir');

  //     // Save each frame as an image
  //     for (int i = 0; i < _frames.length; i++) {
  //       final image = _frames[i];
  //       final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  //       final file =
  //           File('$framesDir/frame_${i.toString().padLeft(4, '0')}.png');
  //       await file.writeAsBytes(byteData!.buffer.asUint8List());
  //     }
  //     print('Frames saved. Total frames: ${_frames.length}');

  //     // Check first few frame files
  //     print('First few frame files:');
  //     for (int i = 0; i < min(_frames.length, 5); i++) {
  //       File frame =
  //           File('$framesDir/frame_${i.toString().padLeft(4, '0')}.png');
  //       print('${frame.path} exists: ${await frame.exists()}');
  //     }

  //     // Compile images into video
  //     Directory appDocDir = await getApplicationDocumentsDirectory();
  //     _videoPath = "${appDocDir.path}/output.mp4";

  //     print('Compiling video to $_videoPath');

  //     // Simplified FFmpeg command
  //     // String command =
  //     //     "-y -framerate 30 -i '$framesDir/frame_%04d.png' -c:v libx264 -pix_fmt yuv420p '$_videoPath'";
  //     // String command =
  //     //     "-y -framerate 30 -i '$framesDir/frame_%04d.png' -c:v mpeg4 '$_videoPath'";
  //     String command =
  //         "-y -framerate 30 -i '${framesDir}/frame_%04d.png' -c:v mpeg4 -pix_fmt yuv420p -movflags +faststart '${_videoPath}'";

  //     // Execute FFmpeg command
  //     final session = await FFmpegKit.execute(command);
  //     final returnCode = await session.getReturnCode();
  //     final output = await session.getOutput();
  //     final logs = await session.getLogs();

  //     print('FFmpeg output: $output');
  //     print('FFmpeg logs:');
  //     for (Log log in logs) {
  //       print('${log.getLevel()} - ${log.getMessage()}');
  //     }

  //     if (ReturnCode.isSuccess(returnCode)) {
  //       print('Video compiled successfully');
  //     } else {
  //       print('Error compiling video. Return code: $returnCode');
  //     }

  //     // Check if the file exists and its size
  //     File videoFile = File(_videoPath!);
  //     if (await videoFile.exists()) {
  //       print('Video file exists at $_videoPath');
  //       print('File size: ${await videoFile.length()} bytes');
  //     } else {
  //       print('Video file does not exist at $_videoPath');
  //     }

  //     // Clear the frames
  //     _frames.clear();
  //   } catch (e) {
  //     print('Error in compileFramesToVideo: $e');
  //   }
  // }
  Future<String?> compileFramesToVideo(
      List<ui.Image> frames, void Function(double) updateProgress) async {
    try {
      Directory tempDir = await getTemporaryDirectory();
      String framesDir = '${tempDir.path}/frames';
      await Directory(framesDir).create(recursive: true);

      // Save frames in parallel
      await Future.wait(frames.asMap().entries.map((entry) async {
        int i = entry.key;
        ui.Image image = entry.value;
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        final file =
            File('$framesDir/frame_${i.toString().padLeft(4, '0')}.png');
        await file.writeAsBytes(byteData!.buffer.asUint8List());
        updateProgress(i / frames.length * 0.5); // First 50% of progress
      }));

      Directory appDocDir = await getApplicationDocumentsDirectory();
      String videoPath =
          "${appDocDir.path}/tactical_pad_${DateTime.now().millisecondsSinceEpoch}.mp4";

      String command =
          "-y -framerate 30 -i '$framesDir/frame_%04d.png' -c:v mpeg4 -pix_fmt yuv420p '$videoPath'";

      await FFmpegKit.executeAsync(
          command,
          (session) async {
            final returnCode = await session.getReturnCode();
            if (ReturnCode.isSuccess(returnCode)) {
              print('Video compiled successfully');
            } else {
              print('Error compiling video. Return code: $returnCode');
            }
          },
          (log) => print(log.getMessage()),
          (statistics) {
            updateProgress(0.5 +
                (statistics.getTime() / 5000) * 0.5); // Last 50% of progress
          });

      return videoPath;
    } catch (e) {
      print('Error in compileFramesToVideo: $e');
      return null;
    }
  }

  Future<void> _compileFramesToVideo() async {
    _videoPath = await compileFramesToVideo(_frames, (progress) {
      setState(() {
        _progress = progress;
      });
    });
    _frames.clear();
  }
  // Future<void> _compileFramesToVideo() async {
  //   try {
  //     Directory tempDir = await getTemporaryDirectory();
  //     String framesDir = '${tempDir.path}/frames';
  //     await Directory(framesDir).create(recursive: true);

  //     for (int i = 0; i < _frames.length; i++) {
  //       final byteData =
  //           await _frames[i].toByteData(format: ui.ImageByteFormat.png);
  //       final file =
  //           File('$framesDir/frame_${i.toString().padLeft(4, '0')}.png');
  //       await file.writeAsBytes(byteData!.buffer.asUint8List());
  //       setState(() {
  //         _progress = i / _frames.length;
  //       });
  //     }

  //     Directory appDocDir = await getApplicationDocumentsDirectory();
  //     _videoPath =
  //         "${appDocDir.path}/tactical_pad_${DateTime.now().millisecondsSinceEpoch}.mp4";

  //     String command =
  //         "-y -framerate 30 -i '${framesDir}/frame_%04d.png' -c:v mpeg4 -pix_fmt yuv420p -movflags +faststart '${_videoPath}'";

  //     // String command =
  //     //     "-y -framerate 30 -i '$framesDir/frame_%04d.png' -c:v libx264 -preset ultrafast -crf 23 -pix_fmt yuv420p '$_videoPath'";

  //     await FFmpegKit.executeAsync(
  //         command,
  //         (session) async {
  //           final returnCode = await session.getReturnCode();
  //           if (ReturnCode.isSuccess(returnCode)) {
  //             print('Video compiled successfully');
  //           } else {
  //             print('Error compiling video. Return code: $returnCode');
  //           }
  //         },
  //         (log) => print(log.getMessage()),
  //         (statistics) {
  //           setState(() {
  //             _progress = statistics.getTime() / 5000;
  //           });
  //         });

  //     _frames.clear();
  //   } catch (e) {
  //     print('Error in compileFramesToVideo: $e');
  //   }
  // }

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

  void toggleEraseMode() {
    setState(() {
      isEraseMode = !isEraseMode; // Toggle erase mode
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
      key: _scaffoldKey,
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
          // IconButton(
          //   icon: Icon(Icons.save, color: Colors.white),
          //   onPressed: _saveProject,
          // ),
          IconButton(
            icon: Icon(_isRecording ? Icons.stop : Icons.fiber_manual_record),
            onPressed: _isRecording ? _stopRecording : _startRecording,
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
                child: RawGestureDetector(
                  gestures: <Type, GestureRecognizerFactory>{
                    PanGestureRecognizer: GestureRecognizerFactoryWithHandlers<
                        PanGestureRecognizer>(
                      () => PanGestureRecognizer(),
                      (PanGestureRecognizer instance) {
                        instance
                          ..onStart = (details) {
                            _onPanStart(details);
                          }
                          ..onUpdate = (details) {
                            _onPanUpdate(details);
                          }
                          ..onEnd = (details) {
                            _onPanEnd(details);
                          };
                      },
                    ),
                    ScaleGestureRecognizer:
                        GestureRecognizerFactoryWithHandlers<
                            ScaleGestureRecognizer>(
                      () => ScaleGestureRecognizer(),
                      (ScaleGestureRecognizer instance) {
                        instance
                          ..onUpdate = (details) {
                            setState(() {
                              _scale = details.scale;
                            });
                          };
                      },
                    ),
                    // Add factories for other gesture recognizers if needed
                    TapGestureRecognizer: GestureRecognizerFactoryWithHandlers<
                        TapGestureRecognizer>(
                      () => TapGestureRecognizer(),
                      (TapGestureRecognizer instance) {
                        instance.onTapDown = (TapDownDetails details) {
                          _onTapDown(details);
                        };
                      },
                    ),
                  },
                  behavior: HitTestBehavior.translucent,
                  child: Stack(
                    children: [
                      CustomPaint(
                        painter: DrawingPainter(
                          _drawingObjects,
                          selectedObject: _selectedDrawingObject,
                          dragOffset: _dragOffset,
                        ),
                        child: Container(
                          color: isEraseMode
                              ? Colors.red.withOpacity(0.1)
                              : Colors.transparent,
                        ),
                      ),
                      if (_isRecording)
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.fiber_manual_record,
                                    color: Colors.white, size: 20),
                                SizedBox(width: 5),
                                Text(
                                  'Recording',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
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
                          canvasScale: _canvasScale,
                          canvasPanOffset: _canvasPanOffset,
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
                          canvasScale: _canvasScale,
                          canvasPanOffset: _canvasPanOffset,
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
                          canvasScale: _canvasScale,
                          canvasPanOffset: _canvasPanOffset,
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
                          canvasScale: _canvasScale,
                          canvasPanOffset: _canvasPanOffset,
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
                          canvasScale: _canvasScale,
                          canvasPanOffset: _canvasPanOffset,
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
                          canvasScale: _canvasScale,
                          canvasPanOffset: _canvasPanOffset,
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
                          canvasScale: _canvasScale,
                          canvasPanOffset: _canvasPanOffset,
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
                          canvasScale: _canvasScale,
                          canvasPanOffset: _canvasPanOffset,
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
                          canvasScale: _canvasScale,
                          canvasPanOffset: _canvasPanOffset,
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
                          canvasScale: _canvasScale,
                          canvasPanOffset: _canvasPanOffset,
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
                          canvasScale: _canvasScale,
                          canvasPanOffset: _canvasPanOffset,
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
      bottomNavigationBar: CustomBottomAppBar(
        onDrawingTypeSelected: (DrawingBType type) {
          // Handle drawing type selection
          print('Selected drawing type: $type');
        },
        onAnimationPressed: () {
          _toggleVideoOverlay();
          // Handle animation button press
          print('Animation pressed');
        },
        onEraseMode: () {
          toggleEraseMode();
          print('eRASE pressed');
        },
        onLinePressed: () {
          _startDrawing(DrawingType.line);
          // Handle animation button press
          print('Line pressed');
        },
        onArrowPressed: () {
          _startDrawing(DrawingType.arrow);
          print('Arrow pressed');
        },
        onItemsPressed: () {
          _scaffoldKey.currentState!.openDrawer();
          // Handle items button press
          print('Items pressed');
        },
        onTextPressed: () {
          _startDrawing(DrawingType.text);
          // Handle text button press
          print('Text pressed');
        },
        onNotesPressed: () {
          // Handle notes button press
          print('Notes pressed');
        },
        onEffectsPressed: () {
          _showColorPicker();
          // Handle effects button press
          print('Effects pressed');
        },
      ),
      // bottomNavigationBar: BottomAppBar(
      //   color: Color(0xFF2E74B8),
      //   child: Row(
      //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //     children: [
      //       IconButton(
      //         icon: Icon(Icons.line_style),
      //         onPressed: () => _startDrawing(DrawingType.line),
      //       ),
      //       IconButton(
      //         icon: Icon(Icons.arrow_forward),
      //         onPressed: () => _startDrawing(DrawingType.arrow),
      //       ),
      //       IconButton(
      //         icon: Icon(Icons.circle_outlined),
      //         onPressed: () => _startDrawing(DrawingType.circle),
      //       ),
      //       IconButton(
      //         icon: Icon(Icons.text_fields),
      //         onPressed: () => _startDrawing(DrawingType.text),
      //       ),
      //       IconButton(
      //         icon: Icon(Icons.color_lens),
      //         onPressed: () => _showColorPicker(),
      //       ),
      //     ],
      // ),
      // ),
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
