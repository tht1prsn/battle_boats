import 'package:flutter/material.dart';


//https://api.flutter.dev/flutter/widgets/Draggable-class.html
class DraggableBoat extends StatelessWidget {
  const DraggableBoat({
    super.key,
    required this.cellSize,
  });

  final Size cellSize;

  @override
  Widget build(BuildContext context) {
    const boatLength = 3;

    return Draggable<String>(
      data: 'boat',
      feedback: Container(
        width: cellSize.width * boatLength,
        height: cellSize.height,
        decoration: BoxDecoration(
          color: Colors.brown,
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _buildBoat(),
      ),
      child: _buildBoat(),
    );
  }

  Widget _buildBoat() {
    return Container(
      width: cellSize.width * 3,
      height: cellSize.height,
      decoration: BoxDecoration(
        color: Colors.brown,
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}