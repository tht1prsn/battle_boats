import 'package:flutter/material.dart';

// what each cell in the grid could be
enum CellState { water, boat, hit, miss }

// want to draw a grid of cells, report what gets tapped
// use variable to keep the grid size flexible
class BoardGrid extends StatelessWidget {
  const BoardGrid({
    super.key,
    required this.cells,
    this.onCellTap,
    this.onBoatDrop,
  });

  final List<List<CellState>> cells;
  final void Function(int row, int col)? onCellTap;

  // called when a boat is dragged and dropped on a cell. null = no dropping
  final void Function(int row, int col)? onBoatDrop;
  @override
  Widget build(BuildContext context) {
    final size = cells.length;
    // https://api.flutter.dev/flutter/widgets/AspectRatio-class.html
    return AspectRatio(
      aspectRatio: 1,
      child: GridView.builder(
        // https://api.flutter.dev/flutter/widgets/NeverScrollableScrollPhysics-class.html
        // the board shouldnt scroll
        physics: const NeverScrollableScrollPhysics(),
        // lays cells out in columns
        // https://api.flutter.dev/flutter/rendering/SliverGridDelegateWithFixedCrossAxisCount-class.html
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: size,
        ),
        itemCount: size * size,
        itemBuilder: (context, index) {
          final row = index ~/ size;
          final col = index % size;
          final cell = GestureDetector(
            onTap: onCellTap == null ? null : () => onCellTap!(row, col),
            child: Container(
              decoration: BoxDecoration(
                color: _cellColor(cells[row][col]),
                border: Border.all(color: Colors.black),
              ),
            ),
          );
          if (onBoatDrop == null) return cell;
          // cell also accepts dragged boats
          return DragTarget<String>(
            onAcceptWithDetails: (_) => onBoatDrop!(row, col),
            builder: (context, candidate, rejected) => cell,
          );
        },
      ),
    );
  }

  // color for each state of the cells
  Color _cellColor(CellState state) {
    return switch (state) {
      CellState.water => Colors.lightBlue.shade100,
      CellState.boat => Colors.grey,
      CellState.hit => Colors.deepOrange,
      CellState.miss => Colors.lightBlue,
    };
  }
}
