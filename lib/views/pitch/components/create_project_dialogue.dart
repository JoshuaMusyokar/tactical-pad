import 'package:flutter/material.dart';

class CreateProjectDialog extends StatefulWidget {
  final Function(String) onProjectCreated;

  CreateProjectDialog({required this.onProjectCreated});

  @override
  _CreateProjectDialogState createState() => _CreateProjectDialogState();
}

class _CreateProjectDialogState extends State<CreateProjectDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New Project'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(hintText: 'Enter project name'),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            widget.onProjectCreated(_controller.text);
            Navigator.of(context).pop();
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}
