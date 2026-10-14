import 'package:battle_boats/widgets/boat_widget.dart';
import 'package:flutter/material.dart';
import 'package:battle_boats/widgets/board_grid.dart';

//Cherrypick

// board size for editing
// we can bring it from 5x5 to something fancier
const int boardSize = 5;

// main play screen
class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    required this.lobbyCode,
    required this.playerNumber,
    required this._myCells,
    required this.playerBoard
  });

  final String lobbyCode;

  // creator is P1, joiner is P2
  final int playerNumber;

  final List<List<CellState>> _myCells;

  final List<PlacedBoat> playerBoard;


  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // enemyCells just show hits and misses
  late List<List<CellState>> _enemyCells;

  // your own board, boats included

  @override
  void initState() {
    super.initState();
    // placeholder boards until logic happens
    _enemyCells = _emptyBoard();
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
                mode: BoardMode.attack,
                child: BoardGrid(cells: _enemyCells,
                ),
              ),
            ),
            Expanded(
              child: _BoardPanel(
                label: 'Your boats',
                mode: BoardMode.readOnly,
                child: BoardGrid(cells: widget._myCells),
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
  const _BoardPanel({required this.label, required this.child, required BoardMode mode});

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
