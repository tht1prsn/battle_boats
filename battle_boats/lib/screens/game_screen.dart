import 'package:flutter/material.dart';
import 'package:battle_boats/widgets/board_grid.dart';

// board size for editing
// we can bring it from 5x5 to something fancier
const int boardSize = 5;

// main play screen
class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    required this.lobbyCode,
    required this.playerNumber,
  });

  final String lobbyCode;

  // creator is P1, joiner is P2
  final int playerNumber;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // enemyCells just show hits and misses
  late List<List<CellState>> _enemyCells;

  // your own board, boats included
  late List<List<CellState>> _myCells;

  @override
  void initState() {
    super.initState();
    // placeholder boards until logic happens
    _enemyCells = _emptyBoard();
    _myCells = _emptyBoard();
    // sample cells to show every color
    // these are temp
    _myCells[0][0] = CellState.boat;
    _myCells[0][1] = CellState.boat;
    _myCells[2][3] = CellState.hit;
    _myCells[4][4] = CellState.miss;
  }

  List<List<CellState>> _emptyBoard() {
    return List.generate(
      boardSize,
      (_) => List.filled(boardSize, CellState.water),
    );
  }

  // temp placeholder to mark a miss to check taps
  void _fireAt(int row, int col) {
    // redraw new cell color
    setState(() {
      _enemyCells[row][col] = CellState.miss;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // wireframe colors for P1 and P2
      backgroundColor: widget.playerNumber == 1
          ? const Color(0xFFEED9FB)
          : const Color(0xFFDDDDF8),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            Text('Lobby code: ${widget.lobbyCode}'),
            Expanded(
              child: _BoardPanel(
                label: 'Enemy waters',
                child: BoardGrid(cells: _enemyCells, onCellTap: _fireAt),
              ),
            ),
            Expanded(
              child: _BoardPanel(
                label: 'Your boats',
                // no onCellTap, so your own board is read-only
                child: BoardGrid(cells: _myCells),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// white box that holds one board like wireframe
class _BoardPanel extends StatelessWidget {
  const _BoardPanel({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      // fitting in everything in nicely
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black54, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(label),
          const SizedBox(height: 8),
          Expanded(child: Center(child: child)),
        ],
      ),
    );
  }
}
