import 'package:flutter/material.dart';

class CreateProjectDialog extends StatelessWidget {
  final Function(String) onProjectCreated;

  CreateProjectDialog({required this.onProjectCreated});

  @override
  Widget build(BuildContext context) {
    final TextEditingController _controller = TextEditingController();

    return AlertDialog(
      title: Text('Create New Project'),
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(hintText: "Enter project name"),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_controller.text.isNotEmpty) {
              onProjectCreated(_controller.text);
              Navigator.of(context).pop();
            }
          },
          child: Text('Create'),
        ),
      ],
    );
  }
}
