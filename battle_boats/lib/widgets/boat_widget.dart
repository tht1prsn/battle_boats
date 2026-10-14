//cherrypick

import 'package:flutter/material.dart';

enum BoatOrientation { Horizontal, Vertical }

class BoatState {
  BoatState(this.length, this.direction, this.id);

  int length;
  BoatOrientation direction;
  String id;
}

class DraggableBoat extends StatefulWidget {
  const DraggableBoat({
    super.key,
    required this.id,
    required this.cellSize,
    required this.boatLength,
  });
  final String id;
  final Size cellSize;
  final int boatLength;
  @override
  State<DraggableBoat> createState() => _DraggableBoatState();
}

class _DraggableBoatState extends State<DraggableBoat> {
  BoatOrientation _orientation = BoatOrientation.Horizontal;

  void _rotateBoat() {
    setState(() {
      _orientation = _orientation == BoatOrientation.Horizontal
          ? BoatOrientation.Vertical
          : BoatOrientation.Horizontal;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isHorizontal =
        _orientation == BoatOrientation.Horizontal;

    final Size boatSize = isHorizontal
        ? Size(
            widget.cellSize.width * widget.boatLength,
            widget.cellSize.height,
          )
        : Size(
            widget.cellSize.width,
            widget.cellSize.height * widget.boatLength,
          );

    return GestureDetector(
      onLongPress: _rotateBoat,
      child: Draggable<BoatState>(
        dragAnchorStrategy: (draggable, context, position) {
          return Offset(
            boatSize.width / 2,
            boatSize.height / 2,
          );
        },
        data: BoatState(widget.boatLength, _orientation, widget.id),
        feedback: _buildBoat(boatSize),
        childWhenDragging: Opacity(
          opacity: 0.3,
          child: _buildBoat(boatSize),
        ),
        child: _buildBoat(boatSize),

      ),
    );
  }

  Widget _buildBoat(Size size) {
    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        color: Colors.brown,
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class PlacedBoat {
  PlacedBoat({
    required this.boat,
    required this.row,
    required this.col,
  });

  final BoatState boat;
  final int row;
  final int col;
}