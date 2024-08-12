import 'package:flutter/material.dart';
import 'dart:async';

class TimerBanner extends StatefulWidget {
  @override
  _TimerBannerState createState() => _TimerBannerState();
}

class _TimerBannerState extends State<TimerBanner> {
  late Timer _timer;
  Duration _elapsedTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      setState(() {
        _elapsedTime = _elapsedTime + Duration(seconds: 1);
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = _elapsedTime.inMinutes.toString().padLeft(2, '0');
    final seconds =
        _elapsedTime.inSeconds.remainder(60).toString().padLeft(2, '0');

    return Positioned(
      top: 10,
      right: 10,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: Colors.black.withOpacity(0.7),
        child: Text(
          '$minutes:$seconds',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }
}
