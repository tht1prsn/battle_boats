import 'package:battle_boats/widgets/boat_widget.dart';
import 'package:flutter/material.dart';

// what each cell in the grid could be
enum CellState { water, boat, hit, miss }
enum BoardMode {
  placement, // Place boats on your own board
  attack,    // Click enemy cells to attempt a hit
  readOnly,  // Display the board without interaction
}

// want to draw a grid of cells, report what gets tapped
// use variable to keep the grid size flexible
class BoardGrid extends StatelessWidget {
  const BoardGrid({
    super.key,
    required this.cells,
    this.mode = BoardMode.readOnly,
    this.onCellTap,
    this.onBoatDropped, 
    this.onCellSizeChanged
  });

  final List<List<CellState>> cells;
  final BoardMode mode;


  final ValueChanged<Size>? onCellSizeChanged;
  //attack
  final void Function(int row, int col)? onCellTap;

  //place boat
  final void Function(int row, int col, BoatState boat)? onBoatDropped;

  @override
  Widget build(BuildContext context) {
  final size = cells.length;

  if (size == 0) {
    return const SizedBox.shrink();
  }
  return LayoutBuilder(
    builder: (context, constraints) {
      final boardSize = constraints.maxWidth < constraints.maxHeight
          ? constraints.maxWidth
          : constraints.maxHeight;

      final cellSize = Size(
        boardSize / size,
        boardSize / size,
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        onCellSizeChanged?.call(cellSize);
      });

      return SizedBox.square(
        dimension: boardSize,
        child: GridView.builder(
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: size,
            childAspectRatio: 1,
          ),
          itemCount: size * size,
          itemBuilder: (context, index) {
            final row = index ~/ size;
            final col = index % size;

            final cell = Container(
              decoration: BoxDecoration(
                color: _cellColor(cells[row][col]),
                border: Border.all(color: Colors.black),
              ),
            );
            Widget? cellChild;
            switch(mode)
            {
              case BoardMode.placement:
                
                cellChild = DragTarget<BoatState>(
                  onWillAcceptWithDetails: (details) {
                    // Add placement validation next.
                    return true;
                    
                  },
                  onAcceptWithDetails: (details) {
                    onBoatDropped?.call(row, col, details.data);
                  },
                  builder: (context, candidates, rejected) {
                    return Container(
                      decoration: BoxDecoration(
                        color: candidates.isNotEmpty
                            ? const Color.fromARGB(255, 35, 163, 39)
                            : _cellColor(cells[row][col]),
                        border: Border.all(color: Colors.black),
                      ),
                    );
                  },
                );
              case BoardMode.attack:
                cellChild = GestureDetector(
                  onTap: () => onCellTap?.call(row, col),
                  child: cell,
                );

              case BoardMode.readOnly:
                cellChild = null;
            }
            return cellChild ?? cell;
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