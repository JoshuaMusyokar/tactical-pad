import 'package:flutter/material.dart';

class ActionMenu extends StatelessWidget {
  final Function(String) onActionSelected;

  ActionMenu({required this.onActionSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      height: 250.0,
      child: Column(
        children: [
          Text(
            'Select Action',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              children: <Widget>[
                _buildMenuItem(Icons.person_add, 'Add Player'),
                _buildMenuItem(Icons.person_2_rounded, 'Add Coach'),
                _buildMenuItem(Icons.traffic, 'Add Cone'),
                _buildMenuItem(Icons.sports_soccer, 'Add Ball'),
                _buildMenuItem(Icons.create, 'Draw Line'),
                _buildMenuItem(Icons.delete, 'Erase Objects'),
                _buildMenuItem(Icons.save, 'Save Formation'),
                _buildMenuItem(Icons.folder_open, 'Load Formation'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String action) {
    return GestureDetector(
      onTap: () => onActionSelected(action),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(icon, size: 50.0),
          SizedBox(height: 8.0),
          Text(action),
        ],
      ),
    );
  }
}
