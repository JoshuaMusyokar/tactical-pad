import 'package:flutter/material.dart';
import 'package:tactical_pad/views/pitch/components/object_maker.dart';

class PlayerMarker extends ObjectMarker {
  PlayerMarker({
    required Function(Offset) onPositionChanged,
    required Offset position,
    required Function(Offset) onDragEnd,
    required double canvasScale,
    required Offset canvasPanOffset,
  }) : super(
          position: position,
          onDragEnd: onDragEnd,
          onPositionChanged: onPositionChanged,
          imageAsset: 'lib/assets/player.png',
          initialSize: 100.0,
          canvasScale: canvasScale,
          canvasPanOffset: canvasPanOffset,
        );
}

class PlayerFourMarker extends ObjectMarker {
  PlayerFourMarker({
    required Function(Offset) onPositionChanged,
    required Offset position,
    required Function(Offset) onDragEnd,
    required double canvasScale,
    required Offset canvasPanOffset,
  }) : super(
          position: position,
          onDragEnd: onDragEnd,
          onPositionChanged: onPositionChanged,
          imageAsset: 'lib/assets/player-4.png',
          initialSize: 100.0,
          canvasScale: canvasScale,
          canvasPanOffset: canvasPanOffset,
        );
}

class PlayerFiveMarker extends ObjectMarker {
  PlayerFiveMarker({
    required Function(Offset) onPositionChanged,
    required Offset position,
    required Function(Offset) onDragEnd,
    required double canvasScale,
    required Offset canvasPanOffset,
  }) : super(
          position: position,
          onDragEnd: onDragEnd,
          onPositionChanged: onPositionChanged,
          imageAsset: 'lib/assets/player-5.png',
          initialSize: 100.0,
          canvasScale: canvasScale,
          canvasPanOffset: canvasPanOffset,
        );
}

class PlayerSixMarker extends ObjectMarker {
  PlayerSixMarker({
    required Function(Offset) onPositionChanged,
    required Offset position,
    required Function(Offset) onDragEnd,
    required double canvasScale,
    required Offset canvasPanOffset,
  }) : super(
          position: position,
          onDragEnd: onDragEnd,
          onPositionChanged: onPositionChanged,
          imageAsset: 'lib/assets/player-6.png',
          initialSize: 100.0,
          canvasScale: canvasScale,
          canvasPanOffset: canvasPanOffset,
        );
}

class CoachMarker extends ObjectMarker {
  CoachMarker({
    required Function(Offset) onPositionChanged,
    required Offset position,
    required Function(Offset) onDragEnd,
    required double canvasScale,
    required Offset canvasPanOffset,
  }) : super(
          position: position,
          onDragEnd: onDragEnd,
          onPositionChanged: onPositionChanged,
          imageAsset: 'lib/assets/coach.png',
          initialSize: 110.0,
          canvasScale: canvasScale,
          canvasPanOffset: canvasPanOffset,
        );
}

class ConeMarker extends ObjectMarker {
  ConeMarker({
    required Function(Offset) onPositionChanged,
    required Offset position,
    required Function(Offset) onDragEnd,
    required double canvasScale,
    required Offset canvasPanOffset,
  }) : super(
          position: position,
          onDragEnd: onDragEnd,
          onPositionChanged: onPositionChanged,
          imageAsset: 'lib/assets/cone.png',
          initialSize: 80.0,
          canvasScale: canvasScale,
          canvasPanOffset: canvasPanOffset,
        );
}

class LowConeMarker extends ObjectMarker {
  LowConeMarker({
    required Function(Offset) onPositionChanged,
    required Offset position,
    required Function(Offset) onDragEnd,
    required double canvasScale,
    required Offset canvasPanOffset,
  }) : super(
          position: position,
          onDragEnd: onDragEnd,
          onPositionChanged: onPositionChanged,
          imageAsset: 'lib/assets/low-cone.png',
          initialSize: 700.0,
          canvasScale: canvasScale,
          canvasPanOffset: canvasPanOffset,
        );
}

class AgilityMarker extends ObjectMarker {
  AgilityMarker({
    required Function(Offset) onPositionChanged,
    required Offset position,
    required Function(Offset) onDragEnd,
    required double canvasScale,
    required Offset canvasPanOffset,
  }) : super(
          position: position,
          onDragEnd: onDragEnd,
          onPositionChanged: onPositionChanged,
          imageAsset: 'lib/assets/agility.png',
          initialSize: 75.0,
          canvasScale: canvasScale,
          canvasPanOffset: canvasPanOffset,
        );
}

class StripMarker extends ObjectMarker {
  StripMarker({
    required Function(Offset) onPositionChanged,
    required Offset position,
    required Function(Offset) onDragEnd,
    required double canvasScale,
    required Offset canvasPanOffset,
  }) : super(
          position: position,
          onDragEnd: onDragEnd,
          onPositionChanged: onPositionChanged,
          imageAsset: 'lib/assets/strip.png',
          initialSize: 60.0,
          canvasScale: canvasScale,
          canvasPanOffset: canvasPanOffset,
        );
}

class BasketMarker extends ObjectMarker {
  BasketMarker({
    required Function(Offset) onPositionChanged,
    required Offset position,
    required Function(Offset) onDragEnd,
    required double canvasScale,
    required Offset canvasPanOffset,
  }) : super(
          position: position,
          onDragEnd: onDragEnd,
          onPositionChanged: onPositionChanged,
          imageAsset: 'lib/assets/basket.png',
          initialSize: 850.0,
          canvasScale: canvasScale,
          canvasPanOffset: canvasPanOffset,
        );
}

class PodelpritMarker extends ObjectMarker {
  PodelpritMarker({
    required Function(Offset) onPositionChanged,
    required Offset position,
    required Function(Offset) onDragEnd,
    required double canvasScale,
    required Offset canvasPanOffset,
  }) : super(
          position: position,
          onDragEnd: onDragEnd,
          onPositionChanged: onPositionChanged,
          imageAsset: 'lib/assets/strip.png',
          initialSize: 70.0,
          canvasScale: canvasScale,
          canvasPanOffset: canvasPanOffset,
        );
}

class BallMarker extends ObjectMarker {
  BallMarker({
    required Function(Offset) onPositionChanged,
    required Offset position,
    required Function(Offset) onDragEnd,
    required double canvasScale,
    required Offset canvasPanOffset,
  }) : super(
          position: position,
          onDragEnd: onDragEnd,
          onPositionChanged: onPositionChanged,
          imageAsset: 'lib/assets/ball.png',
          initialSize: 45.0,
          canvasScale: canvasScale,
          canvasPanOffset: canvasPanOffset,
        );
}
