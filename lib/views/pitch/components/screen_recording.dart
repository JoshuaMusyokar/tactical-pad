import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:video_player/video_player.dart';

class RecordingScreen extends StatefulWidget {
  @override
  _RecordingScreenState createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  GlobalKey _repaintBoundaryKey = GlobalKey();
  List<ui.Image> _frames = [];
  String? _videoPath;
  VideoPlayerController? _videoPlayerController;
  bool _isRecording = false;

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    super.dispose();
  }

  Future<void> _captureFrame() async {
    RenderRepaintBoundary boundary = _repaintBoundaryKey.currentContext!
        .findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    _frames.add(image);
  }

  Future<void> _startRecording() async {
    _isRecording = true;
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
    Directory tempDir = await getTemporaryDirectory();
    String framesDir = '${tempDir.path}/frames';
    await Directory(framesDir).create(recursive: true);

    // Save each frame as an image
    for (int i = 0; i < _frames.length; i++) {
      final image = _frames[i];
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final file = File('$framesDir/frame_${i.toString().padLeft(4, '0')}.png');
      await file.writeAsBytes(byteData!.buffer.asUint8List());
    }

    // Compile images into video
    Directory appDocDir = await getApplicationDocumentsDirectory();
    _videoPath = "${appDocDir.path}/output.mp4";

    String command =
        "-r 30 -i $framesDir/frame_%04d.png -c:v libx264 -vf fps=30 $_videoPath";
    await FFmpegKit.execute(command);

    // Clear the frames
    _frames.clear();
  }

  Future<void> _playVideo() async {
    if (_videoPath != null && File(_videoPath!).existsSync()) {
      _videoPlayerController = VideoPlayerController.file(File(_videoPath!))
        ..initialize().then((_) {
          setState(() {});
          _videoPlayerController!.play();
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Screen Recording Example'),
      ),
      body: Stack(
        children: [
          RepaintBoundary(
            key: _repaintBoundaryKey,
            child: Container(
              color: Colors.white,
              child: Center(
                child: Text(
                  'This is the recording area',
                  style: TextStyle(fontSize: 24, color: Colors.black),
                ),
              ),
            ),
          ),
          if (_videoPlayerController != null &&
              _videoPlayerController!.value.isInitialized)
            Center(
              child: AspectRatio(
                aspectRatio: _videoPlayerController!.value.aspectRatio,
                child: VideoPlayer(_videoPlayerController!),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_isRecording) {
            await _stopRecording();
          } else {
            await _startRecording();
          }
        },
        child: Icon(_isRecording ? Icons.stop : Icons.fiber_manual_record),
      ),
    );
  }
}
