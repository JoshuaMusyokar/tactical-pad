import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tactical_pad/database/database.dart';

class Project {
  String id;
  String name;
  DateTime createdAt;
  DateTime? updatedAt;
  List<Offset> playerPositions;
  List<Offset> coachPositions;
  List<Offset> conePositions;
  List<Offset> ballPositions;
  List<Timeframe> timeframes = [];
  List<Map<String, dynamic>> recordedFrames; // Define recordedFrames

  Project({
    required this.id,
    required this.name,
    required this.createdAt,
    this.updatedAt,
    required this.playerPositions,
    required this.coachPositions,
    required this.conePositions,
    required this.ballPositions,
    List<Map<String, dynamic>>? recordedFrames, // Optional parameter
  }) : recordedFrames = recordedFrames ?? [];

  void updatePositions({
    List<Offset>? players,
    List<Offset>? coaches,
    List<Offset>? cones,
    List<Offset>? balls,
  }) {
    if (players != null) playerPositions = players;
    if (coaches != null) coachPositions = coaches;
    if (cones != null) conePositions = cones;
    if (balls != null) ballPositions = balls;
    updatedAt = DateTime.now();
  }

  // void recordTimeframe() {
  //   timeframes.add(Timeframe(
  //     timestamp: DateTime.now(),
  //     playerPositions: List.from(playerPositions),
  //     coachPositions: List.from(coachPositions),
  //     conePositions: List.from(conePositions),
  //     ballPositions: List.from(ballPositions),
  //   ));
  // }
  void recordTimeframe(
      List<Offset> playerPositions,
      List<Offset> coachPositions,
      List<Offset> conePositions,
      List<Offset> ballPositions) {
    recordedFrames.add({
      'playerPositions':
          playerPositions.map((e) => {'dx': e.dx, 'dy': e.dy}).toList(),
      'coachPositions':
          coachPositions.map((e) => {'dx': e.dx, 'dy': e.dy}).toList(),
      'conePositions':
          conePositions.map((e) => {'dx': e.dx, 'dy': e.dy}).toList(),
      'ballPositions':
          ballPositions.map((e) => {'dx': e.dx, 'dy': e.dy}).toList(),
    });
  }

  void recordFrame() {
    recordedFrames.add({
      'playerPositions': jsonEncode(
          playerPositions.map((e) => {'dx': e.dx, 'dy': e.dy}).toList()),
      'coachPositions': jsonEncode(
          coachPositions.map((e) => {'dx': e.dx, 'dy': e.dy}).toList()),
      'conePositions': jsonEncode(
          conePositions.map((e) => {'dx': e.dx, 'dy': e.dy}).toList()),
      'ballPositions': jsonEncode(
          ballPositions.map((e) => {'dx': e.dx, 'dy': e.dy}).toList()),
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<void> saveProjectWithTimeframes() async {
    final db = await DatabaseHelper().database;

    // Save project details
    await db.insert('projects', {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    });

    // Save each recorded frame
    for (var frame in recordedFrames) {
      print(frame);
      await db.insert('frames', {
        'projectId': id,
        ...frame,
      });
    }
  }

  void saveFrame() async {
    final frameData = {
      'projectId': id,
      'playerPositions': jsonEncode(
          playerPositions.map((e) => {'dx': e.dx, 'dy': e.dy}).toList()),
      'coachPositions': jsonEncode(
          coachPositions.map((e) => {'dx': e.dx, 'dy': e.dy}).toList()),
      'conePositions': jsonEncode(
          conePositions.map((e) => {'dx': e.dx, 'dy': e.dy}).toList()),
      'ballPositions': jsonEncode(
          ballPositions.map((e) => {'dx': e.dx, 'dy': e.dy}).toList()),
      'timestamp': DateTime.now().toIso8601String(),
    };
    print(frameData);

    await DatabaseHelper().insertFrame(frameData);
  }

  static Future<Project> loadProject(String id) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$id.json');

    if (await file.exists()) {
      final projectData = jsonDecode(await file.readAsString());

      return Project(
        id: projectData['id'],
        name: projectData['name'],
        createdAt: DateTime.parse(projectData['createdAt']),
        updatedAt: projectData['updatedAt'] != null
            ? DateTime.parse(projectData['updatedAt'])
            : null,
        playerPositions: List<Offset>.from(
            projectData['playerPositions'].map((e) => Offset(e[0], e[1]))),
        coachPositions: List<Offset>.from(
            projectData['coachPositions'].map((e) => Offset(e[0], e[1]))),
        conePositions: List<Offset>.from(
            projectData['conePositions'].map((e) => Offset(e[0], e[1]))),
        ballPositions: List<Offset>.from(
            projectData['ballPositions'].map((e) => Offset(e[0], e[1]))),
        recordedFrames:
            List<Map<String, dynamic>>.from(projectData['recordedFrames']),
      );
    } else {
      throw Exception('Project not found');
    }
  }

  // Convert a Project object into a Map object
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Convert a Map object into a Project object
  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'],
      name: map['name'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt:
          map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
      playerPositions: List<Offset>.from(jsonDecode(map['playerPositions'])
          .map((e) => Offset(e['dx'], e['dy']))),
      coachPositions: List<Offset>.from(jsonDecode(map['coachPositions'])
          .map((e) => Offset(e['dx'], e['dy']))),
      conePositions: List<Offset>.from(jsonDecode(map['conePositions'])
          .map((e) => Offset(e['dx'], e['dy']))),
      ballPositions: List<Offset>.from(jsonDecode(map['ballPositions'])
          .map((e) => Offset(e['dx'], e['dy']))),
      recordedFrames:
          List<Map<String, dynamic>>.from(jsonDecode(map['recordedFrames'])),
    );
  }
}

class Timeframe {
  final DateTime timestamp;
  final List<Offset> playerPositions;
  final List<Offset> coachPositions;
  final List<Offset> conePositions;
  final List<Offset> ballPositions;

  Timeframe({
    required this.timestamp,
    required this.playerPositions,
    required this.coachPositions,
    required this.conePositions,
    required this.ballPositions,
  });
}
