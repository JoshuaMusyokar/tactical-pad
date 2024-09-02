import 'package:flutter/material.dart';
import 'package:tactical_pad/views/pitch/components/object_menu.dart';

Widget buildFancyModalBottomSheet(
    BuildContext context, Function(String) onActionSelected) {
  return DraggableScrollableSheet(
    initialChildSize: 0.75, // 75% of screen height
    maxChildSize: 0.75,
    minChildSize: 0.5,
    builder: (BuildContext context, ScrollController scrollController) {
      return Container(
        decoration: BoxDecoration(
          color: Color(0xFF2A5D83), // Blue color extracted from the image
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, -3),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          children: [
            _buildModalHandle(), // Handle at the top of the modal
            Expanded(
              child: ObjectsMenu(onActionSelected: onActionSelected),
              // child: ObjectsMenu(scrollController: scrollController),
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildModalHandle() {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Container(
      width: 60,
      height: 5,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(5),
      ),
    ),
  );
}
