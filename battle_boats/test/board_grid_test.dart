import 'package:battle_boats/widgets/board_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// size x size board where all cells are water
List<List<CellState>> waterGrid(int size) =>
    List.generate(size, (_) => List.filled(size, CellState.water));

// BoardGrid needs a MaterialApp and Scaffold around it
// the SizedBox gives every test the same fixed 300x300 area 
Widget wrap(BoardGrid grid) {
  return MaterialApp(
    home: Scaffold(body: SizedBox(width: 300, height: 300, child: grid)),
  );
}

// every cell in the grid, row by row
Finder allCells() => find.descendant(
      of: find.byType(BoardGrid),
      matching: find.byType(GestureDetector),
    );

// the fill color of the cell at index
Color? colorAt(WidgetTester tester, int index) {
  final box = tester.widget<Container>(
    find.descendant(of: allCells().at(index), matching: find.byType(Container)),
  );
  return (box.decoration as BoxDecoration).color;
}

void main() {
  testWidgets('draws size x size cells', (tester) async {
    await tester.pumpWidget(wrap(BoardGrid(cells: waterGrid(5))));
    expect(allCells(), findsNWidgets(25));
  });

  testWidgets('tapping a cell gives its row and column', (tester) async {
    int? tappedRow;
    int? tappedCol;
    await tester.pumpWidget(wrap(BoardGrid(
      cells: waterGrid(5),
      onCellTap: (row, col) {
        tappedRow = row;
        tappedCol = col;
      },
    )));

    // index 7 in a 5-wide grid is row 1, column 2 (7 ~/ 5 and 7 % 5)
    await tester.tap(allCells().at(7));

    expect(tappedRow, 1);
    expect(tappedCol, 2);
  });

  testWidgets('each cell state has its own color', (tester) async {
    final cells = [
      [CellState.water, CellState.boat],
      [CellState.hit, CellState.miss],
    ];
    await tester.pumpWidget(wrap(BoardGrid(cells: cells)));

    expect(colorAt(tester, 0), Colors.lightBlue.shade100); // water
    expect(colorAt(tester, 1), Colors.grey); // boat
    expect(colorAt(tester, 2), Colors.deepOrange); // hit
    expect(colorAt(tester, 3), Colors.lightBlue); // miss
  });
}