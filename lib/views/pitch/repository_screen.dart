import 'package:flutter/material.dart';
import 'package:tactical_pad/database/database.dart';

class RepositoryScreen extends StatelessWidget {
  final String projectId;

  RepositoryScreen({required this.projectId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Frame Repository'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseHelper().getFrames(projectId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No frames saved.'));
          }

          final frames = snapshot.data!;
          return ListView.builder(
            itemCount: frames.length,
            itemBuilder: (context, index) {
              final frame = frames[index];
              return ListTile(
                title: Text('Frame ${index + 1}'),
                subtitle: Text(frame['timestamp']),
                onTap: () {
                  // Load and play the frame
                },
              );
            },
          );
        },
      ),
    );
  }
}
