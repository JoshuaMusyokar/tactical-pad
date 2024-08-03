import 'package:flutter/material.dart';

class BottomMenuBar extends StatelessWidget {
  final Function(String) onActionSelected;

  BottomMenuBar({required this.onActionSelected});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle),
          label: 'Menu',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.save),
          label: 'Save',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
      currentIndex: 0,
      selectedItemColor: Colors.amber[800],
      onTap: (index) {
        if (index == 0) {
          onActionSelected('Menu');
        } else if (index == 1) {
          onActionSelected('Save');
        } else if (index == 2) {
          onActionSelected('Settings');
        }
      },
    );
  }
}
