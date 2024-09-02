import 'package:flutter/material.dart';
import 'package:tactical_pad/views/pitch/components/object_maker.dart';

// Player Marker with a size of 50.0
class PlayerMarker extends ObjectMarker {
  PlayerMarker({
    required Function(Offset) onPositionChanged,
    required Offset position,
    required Function(Offset) onDragEnd,
  }) : super(
          position: position,
          onDragEnd: onDragEnd,
          onPositionChanged: onPositionChanged,
          imageAsset: 'lib/assets/player.png',
          size: 60.0, // Player size
        );
}

// Player Marker with a size of 50.0
class PlayerFourMarker extends ObjectMarker {
  PlayerFourMarker({
    required Function(Offset) onPositionChanged,
    required Offset position,
    required Function(Offset) onDragEnd,
  }) : super(
          position: position,
          onDragEnd: onDragEnd,
          onPositionChanged: onPositionChanged,
          imageAsset: 'lib/assets/player-4.png',
          size: 60.0, // Player size
        );
}

// Player Marker with a size of 50.0
class PlayerFiveMarker extends ObjectMarker {
  PlayerFiveMarker({
    required Function(Offset) onPositionChanged,
    required Offset position,
    required Function(Offset) onDragEnd,
  }) : super(
          position: position,
          onDragEnd: onDragEnd,
          onPositionChanged: onPositionChanged,
          imageAsset: 'lib/assets/player-5.png',
          size: 60.0, // Player size
        );
}

// Player Marker with a size of 50.0
class PlayerSixMarker extends ObjectMarker {
  PlayerSixMarker({
    required Function(Offset) onPositionChanged,
    required Offset position,
    required Function(Offset) onDragEnd,
  }) : super(
          position: position,
          onDragEnd: onDragEnd,
          onPositionChanged: onPositionChanged,
          imageAsset: 'lib/assets/player-6.png',
          size: 60.0, // Player size
        );
}

// Coach Marker with a size of 60.0
class CoachMarker extends ObjectMarker {
  CoachMarker({
    required Function(Offset) onPositionChanged,
    required Offset position,
    required Function(Offset) onDragEnd,
  }) : super(
          position: position,
          onDragEnd: onDragEnd,
          onPositionChanged: onPositionChanged,
          imageAsset: 'lib/assets/coach.png',
          size: 70.0, // Coach size
        );
}

// Cone Marker with a size of 40.0
class ConeMarker extends ObjectMarker {
  ConeMarker({
    required Function(Offset) onPositionChanged,
    required Offset position,
    required Function(Offset) onDragEnd,
  }) : super(
          position: position,
          onDragEnd: onDragEnd,
          onPositionChanged: onPositionChanged,
          imageAsset: 'lib/assets/cone.png',
          size: 40.0, // Cone size
        );
}

// Cone Marker with a size of 40.0
class LowConeMarker extends ObjectMarker {
  LowConeMarker({
    required Function(Offset) onPositionChanged,
    required Offset position,
    required Function(Offset) onDragEnd,
  }) : super(
          position: position,
          onDragEnd: onDragEnd,
          onPositionChanged: onPositionChanged,
          imageAsset: 'lib/assets/low-cone.png',
          size: 40.0, // Cone size
        );
}

// Agility Marker with a size of 35.0
class AgilityMarker extends ObjectMarker {
  AgilityMarker({
    required Function(Offset) onPositionChanged,
    required Offset position,
    required Function(Offset) onDragEnd,
  }) : super(
          position: position,
          onDragEnd: onDragEnd,
          onPositionChanged: onPositionChanged,
          imageAsset: 'lib/assets/agility.png',
          size: 35.0, // Agility size
        );
}

// Strip Marker with a size of 30.0
class StripMarker extends ObjectMarker {
  StripMarker({
    required Function(Offset) onPositionChanged,
    required Offset position,
    required Function(Offset) onDragEnd,
  }) : super(
          position: position,
          onDragEnd: onDragEnd,
          onPositionChanged: onPositionChanged,
          imageAsset: 'lib/assets/strip.png',
          size: 30.0, // Strip size
        );
}

// Basket Marker with a size of 50.0
class BasketMarker extends ObjectMarker {
  BasketMarker({
    required Function(Offset) onPositionChanged,
    required Offset position,
    required Function(Offset) onDragEnd,
  }) : super(
          position: position,
          onDragEnd: onDragEnd,
          onPositionChanged: onPositionChanged,
          imageAsset: 'lib/assets/basket.png',
          size: 50.0, // Basket size
        );
}

// Podelprit Marker with a size of 30.0
class PodelpritMarker extends ObjectMarker {
  PodelpritMarker({
    required Function(Offset) onPositionChanged,
    required Offset position,
    required Function(Offset) onDragEnd,
  }) : super(
          position: position,
          onDragEnd: onDragEnd,
          onPositionChanged: onPositionChanged,
          imageAsset: 'lib/assets/strip.png',
          size: 30.0, // Podelprit size
        );
}

// Ball Marker with a size of 40.0
class BallMarker extends ObjectMarker {
  BallMarker({
    required Function(Offset) onPositionChanged,
    required Offset position,
    required Function(Offset) onDragEnd,
  }) : super(
          position: position,
          onDragEnd: onDragEnd,
          onPositionChanged: onPositionChanged,
          imageAsset: 'lib/assets/ball.png',
          size: 20.0, // Ball size
        );
}
