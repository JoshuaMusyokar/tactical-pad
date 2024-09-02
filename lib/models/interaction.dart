import "package:flutter/material.dart";

class Interaction {
  final Offset startPosition;
  final Offset endPosition;
  final int timestamp;
  final String objectType; // e.g., "player", "coach", "cone", etc.

  Interaction({
    required this.startPosition,
    required this.endPosition,
    required this.timestamp,
    required this.objectType,
  });
}
