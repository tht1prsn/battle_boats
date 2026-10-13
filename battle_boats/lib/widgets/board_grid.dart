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
    this.onCellSizeChanged,
  });

  final List<List<CellState>> cells;
  final void Function(int row, int col)? onCellTap;
  final ValueChanged<Size>? onCellSizeChanged;

  @override
  Widget build(BuildContext context) {
    final count = cells.length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final boardSize = constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth
            : constraints.maxHeight;

        final cellSize = boardSize / count;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          onCellSizeChanged?.call(Size(cellSize, cellSize));
        });

        return SizedBox.square(
          dimension: boardSize,
          child: GridView.builder(
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: count,
              childAspectRatio: 1,
            ),
            itemCount: count * count,
            itemBuilder: (context, index) {
              final row = index ~/ count;
              final col = index % count;

              return GestureDetector(
                onTap: onCellTap == null
                    ? null
                    : () => onCellTap!(row, col),
                child: Container(
                  decoration: BoxDecoration(
                    color: _cellColor(cells[row][col]),
                    border: Border.all(color: Colors.black),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Color _cellColor(CellState state) {
    return switch (state) {
      CellState.water => Colors.lightBlue.shade100,
      CellState.boat => Colors.grey,
      CellState.hit => Colors.deepOrange,
      CellState.miss => Colors.lightBlue,
    };
  }
}