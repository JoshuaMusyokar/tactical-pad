import 'package:flutter/material.dart';

class ZoomableCanvas extends StatefulWidget {
  final List<Widget> children;

  ZoomableCanvas({Key? key, required this.children}) : super(key: key);

  @override
  _ZoomableCanvasState createState() => _ZoomableCanvasState();
}

class _ZoomableCanvasState extends State<ZoomableCanvas> {
  final TransformationController _transformationController =
      TransformationController();

  double _canvasHeight = 0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _canvasHeight = constraints.maxHeight; // Get the height

        return Container(
          color: Colors.blue.withOpacity(0.2), // Set a background color
          child: Column(
            children: [
              // Display the height
              // Padding(
              //   padding: const EdgeInsets.all(8.0),
              //   child: Text('Canvas Height: $_canvasHeight'),
              // ),
              Expanded(
                child: InteractiveViewer(
                  transformationController: _transformationController,
                  boundaryMargin: EdgeInsets.all(double.infinity),
                  minScale: 0.1,
                  maxScale: 4.0,
                  child: Container(
                    // color: Colors.grey[300], // Background color for canvas area
                    child: Stack(
                      children: widget.children,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
