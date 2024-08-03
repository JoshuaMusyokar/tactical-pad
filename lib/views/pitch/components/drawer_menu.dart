import 'package:flutter/material.dart';

class DrawerMenu extends StatelessWidget {
  final Function(String) onActionSelected;

  DrawerMenu({required this.onActionSelected});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'More Actions',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.add),
            title: Text('New Project'),
            onTap: () => onActionSelected('new_project'),
          ),
          ListTile(
            leading: Icon(Icons.folder_open),
            title: Text('Open Projects'),
            onTap: () => onActionSelected('open_projects'),
          ),
          ListTile(
            leading: Icon(Icons.save),
            title: Text('Save'),
            onTap: () => onActionSelected('save'),
          ),
          ListTile(
            leading: Icon(Icons.save_alt),
            title: Text('Save As'),
            onTap: () => onActionSelected('save_as'),
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () => onActionSelected('settings'),
          ),
          ListTile(
            leading: Icon(Icons.share),
            title: Text('Share'),
            onTap: () => onActionSelected('share'),
          ),
          ListTile(
            leading: Icon(Icons.dashboard),
            title: Text('Board'),
            onTap: () => onActionSelected('board'),
          ),
          ListTile(
            leading: Icon(Icons.grid_on),
            title: Text('Field 3D'),
            onTap: () => onActionSelected('field_3d'),
          ),
          ListTile(
            leading: Icon(Icons.folder),
            title: Text('Repositories'),
            onTap: () => onActionSelected('repositories'),
          ),
        ],
      ),
    );
  }
}
