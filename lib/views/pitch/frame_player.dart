import 'package:flutter/material.dart';

class FramePlaybackWidget extends StatefulWidget {
  final List<Map<String, dynamic>> frames;

  FramePlaybackWidget({required this.frames});

  @override
  _FramePlaybackWidgetState createState() => _FramePlaybackWidgetState();
}

class _FramePlaybackWidgetState extends State<FramePlaybackWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    if (widget.frames.isNotEmpty) {
      final firstFrame = widget.frames.first;
      final lastFrame = widget.frames.last;

      final startTime = firstFrame['timestamp'] ?? 0;
      final endTime = lastFrame['timestamp'] ?? 0;

      // Slow down animation by increasing the duration
      final duration =
          Duration(milliseconds: ((endTime - startTime) * 2).clamp(1, 20000));

      _animationController = AnimationController(
        vsync: this,
        duration: duration,
      )..repeat(); // Use repeat() for continuous animation

      _animation =
          Tween<double>(begin: 0, end: 1).animate(_animationController);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54, // Modal background color
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.9,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'lib/assets/paddle-pitch.jpeg', // Paddle pitch background
                  fit: BoxFit.cover,
                ),
              ),
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  final frameIndex =
                      (_animation.value * (widget.frames.length - 1)).toInt();
                  if (frameIndex < 0 || frameIndex >= widget.frames.length)
                    return Container();

                  final frame = widget.frames[frameIndex];

                  return Stack(
                    children: [
                      if (frame['playerPositions'] != null &&
                          frame['playerPositions'].isNotEmpty)
                        Positioned(
                          left: frame['playerPositions'][0]['dx'] ?? 0.0,
                          top: frame['playerPositions'][0]['dy'] ?? 0.0,
                          child: SizedBox(
                            width: 50, // Set width according to your needs
                            height: 50, // Set height according to your needs
                            child: Image.asset('lib/assets/player.png'),
                          ),
                        ),
                      if (frame['coachPositions'] != null &&
                          frame['coachPositions'].isNotEmpty)
                        Positioned(
                          left: frame['coachPositions'][0]['dx'] ?? 0.0,
                          top: frame['coachPositions'][0]['dy'] ?? 0.0,
                          child: SizedBox(
                            width: 50, // Set width according to your needs
                            height: 50, // Set height according to your needs
                            child: Image.asset('lib/assets/coach.png'),
                          ),
                        ),
                      if (frame['conePositions'] != null &&
                          frame['conePositions'].isNotEmpty)
                        Positioned(
                          left: frame['conePositions'][0]['dx'] ?? 0.0,
                          top: frame['conePositions'][0]['dy'] ?? 0.0,
                          child: SizedBox(
                            width: 30, // Set width according to your needs
                            height: 30, // Set height according to your needs
                            child: Image.asset('lib/assets/cone.png'),
                          ),
                        ),
                      if (frame['ballPositions'] != null &&
                          frame['ballPositions'].isNotEmpty)
                        Positioned(
                          left: frame['ballPositions'][0]['dx'] ?? 0.0,
                          top: frame['ballPositions'][0]['dy'] ?? 0.0,
                          child: SizedBox(
                            width: 20, // Set width according to your needs
                            height: 20, // Set height according to your needs
                            child: Image.asset('lib/assets/ball.png'),
                          ),
                        ),
                    ],
                  );
                },
              ),
              Positioned(
                top: 16,
                right: 16,
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.black),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
