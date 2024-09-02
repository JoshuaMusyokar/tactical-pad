import 'package:flutter/material.dart';

class CoordinateAnimationScreen extends StatefulWidget {
  final Map<String, List<Offset>> coordinates;

  CoordinateAnimationScreen({required this.coordinates});

  @override
  _CoordinateAnimationScreenState createState() =>
      _CoordinateAnimationScreenState();
}

class _CoordinateAnimationScreenState extends State<CoordinateAnimationScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _animation;
  late int _currentIndex;
  late String _currentObjectType;

  // Map to store image assets for each object type
  final Map<String, String> _objectImages = {
    "ball": 'lib/assets/ball.png',
    "agility": 'lib/assets/agility.png',
    "strip": 'lib/assets/strip.png',
    "Low_cone": 'lib/assets/low_cone.png',
    "cone": 'lib/assets/cone.png',
    "podelprit": 'lib/assets/podelprit.png',
    "vertical_basket": 'lib/assets/vertical_basket.png',
    "basket": 'lib/assets/basket.png',
    "player": 'lib/assets/player.png',
    "coach": 'lib/assets/coach.png',
  };

  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
    _currentObjectType = widget.coordinates.keys.first;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _startAnimation();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tactical Pad'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2E74B8), Color(0xFF2A5D83)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/assets/paddle-pitch.jpeg'),
            fit: BoxFit.fill,
          ),
        ),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Transform.translate(
                  offset: _animation.value,
                  child: child,
                );
              },
              child: Image.asset(
                _objectImages[_currentObjectType] ?? 'lib/assets/cone.png',
                width: 48,
                height: 48,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startAnimation() {
    if (widget.coordinates.containsKey(_currentObjectType) &&
        widget.coordinates[_currentObjectType]!.isNotEmpty) {
      _animation = Tween<Offset>(
        begin: widget.coordinates[_currentObjectType]!.first,
        end: widget.coordinates[_currentObjectType]!.last,
      ).animate(_animationController);

      _animationController.forward().whenComplete(() {
        _animateToNextCoordinate();
      });
    }
  }

  void _animateToNextCoordinate() {
    if (_currentIndex < widget.coordinates[_currentObjectType]!.length - 1) {
      _currentIndex++;
      _animationController.reset();

      _animation = Tween<Offset>(
        begin: widget.coordinates[_currentObjectType]![_currentIndex - 1],
        end: widget.coordinates[_currentObjectType]![_currentIndex],
      ).animate(_animationController);

      _animationController.forward().whenComplete(() {
        _animateToNextCoordinate();
      });
    } else {
      _switchObjectType();
    }
  }

  void _switchObjectType() {
    final objectTypes = widget.coordinates.keys.toList();
    final currentIndex = objectTypes.indexOf(_currentObjectType);

    if (currentIndex < objectTypes.length - 1) {
      _currentObjectType = objectTypes[currentIndex + 1];
      _currentIndex = 0;

      _startAnimation();
    }
  }
}
