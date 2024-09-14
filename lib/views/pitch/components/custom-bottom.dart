import 'package:flutter/material.dart';

class CustomBottomAppBar extends StatelessWidget {
  final Function(DrawingBType) onDrawingTypeSelected;
  final VoidCallback onAnimationPressed;
  final VoidCallback onItemsPressed;
  final VoidCallback onTextPressed;
  final VoidCallback onNotesPressed;
  final VoidCallback onEffectsPressed;

  const CustomBottomAppBar({
    Key? key,
    required this.onDrawingTypeSelected,
    required this.onAnimationPressed,
    required this.onItemsPressed,
    required this.onTextPressed,
    required this.onNotesPressed,
    required this.onEffectsPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.black,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: 60, // Adjust this value as needed
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildButton(Icons.arrow_left, 'Arrow',
                () => onDrawingTypeSelected(DrawingBType.arrow)),
            _buildButton(Icons.line_weight, 'Line',
                () => onDrawingTypeSelected(DrawingBType.line)),
            _buildButton(Icons.animation, 'Animation', onAnimationPressed),
            _buildButton(Icons.draw, 'Draw',
                () => onDrawingTypeSelected(DrawingBType.freehand)),
            _buildButton(Icons.sports_soccer, 'Items', onItemsPressed),
            _buildButton(Icons.text_fields, 'Text', onTextPressed),
            _buildButton(Icons.music_note, 'Notes', onNotesPressed),
            _buildButton(Icons.auto_fix_high, 'Effects', onEffectsPressed),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(IconData icon, String label, VoidCallback onPressed) {
    return Expanded(
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(color: Colors.white, fontSize: 10),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum DrawingBType { freehand, line, arrow, text }
