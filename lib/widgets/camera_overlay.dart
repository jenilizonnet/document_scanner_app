import 'package:flutter/material.dart';

class CameraOverlay extends StatelessWidget {
  const CameraOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        final scanWidth = width * 0.85;
        final scanHeight = height * 0.6;

        final left = (width - scanWidth) / 2;
        final top = (height - scanHeight) / 2;

        return Stack(
          children: [
            // 🔲 Dark overlay (top)
            Positioned(
              left: 0,
              top: 0,
              right: 0,
              height: top,
              child: _darkLayer(),
            ),

            // 🔲 Dark overlay (bottom)
            Positioned(
              left: 0,
              bottom: 0,
              right: 0,
              height: top,
              child: _darkLayer(),
            ),

            // 🔲 Dark overlay (left)
            Positioned(
              left: 0,
              top: top,
              width: left,
              height: scanHeight,
              child: _darkLayer(),
            ),

            // 🔲 Dark overlay (right)
            Positioned(
              right: 0,
              top: top,
              width: left,
              height: scanHeight,
              child: _darkLayer(),
            ),

            // 🟩 Scan Area Border
            Positioned(
              left: left,
              top: top,
              width: scanWidth,
              height: scanHeight,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green, width: 3),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            // 🟢 Corner Indicators
            Positioned(left: left, top: top, child: _corner()),
            Positioned(right: left, top: top, child: _corner()),
            Positioned(left: left, bottom: top, child: _corner()),
            Positioned(right: left, bottom: top, child: _corner()),
          ],
        );
      },
    );
  }

  // 🔳 Dark layer
  Widget _darkLayer() {
    return Container(color: Colors.black.withOpacity(0.6));
  }

  // 🟢 Corner box
  Widget _corner() {
    return Container(
      width: 30,
      height: 30,
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.green, width: 4),
          left: BorderSide(color: Colors.green, width: 4),
        ),
      ),
    );
  }
}
