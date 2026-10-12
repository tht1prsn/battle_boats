import 'dart:async'; 
import 'package:flutter/material.dart';
import 'package:battle_boats/widgets/board_grid.dart';
import 'package:battle_boats/constants.dart';
import 'package:battle_boats/services/game_services.dart'; 
import 'package:battle_boats/services/game_state.dart'; 
// board size for editing, *this is now stored in lib/constants.dart
// we can bring it from 5x5 to something fancier
//const int boardSize = 5;

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

// talks to firestore
  final _service = GameServices();
  // subscription to the live game doc
  StreamSubscription<GameState>? _gameSub;
  // latest gamestate
  GameState? _state;

  final Set<int> _placed = {};
  // cells fired at this round
  final List<int> _roundShots = [];
  // should be true from turn ended until round closes
  bool _submitting = false;
  int _lastRound = 1;

  @override
  void initState() {
    super.initState();
    // placeholder boards until logic happens
    _enemyCells = _emptyBoard();
    _myCells = _emptyBoard();
   // start listening to the game document 
    // _onGameState runs once right away and again whenever either player
    // changes anything. The placeholder boards and sample cells
    // above are replaced only once the game is in the 'playing' phase 
    _gameSub = _service.watchGame(widget.lobbyCode).listen(
      _onGameState,
      onError: (_) => _snack('Lost connection to the game.'),
    );
  }

  // dispose added so the listener stops when this screen
  // closes. Without it the stream keeps running in the background.
  @override
  void dispose() {
    _gameSub?.cancel();
    super.dispose();
  }

  // new method, called with a fresh GameState every time the game document changes. 
  // s.status is one of:
  // 'waiting'  creator alone in the lobby
  // 'placing'  both players in, placing boats
  // 'playing'  both boards submitted, rounds in progress
  // 'finished' someone won (s.winner / s.iWon / s.isDraw)
  // 
  //For now it only fills the two boards once the game is in 'playing' or 'finished'
  // until then. s.myCells() shows your boats plus the enemy's hits and misses
  // s.enemyCells(_roundShots) shows the shots you have fired.

  void _onGameState(GameState s) {
    if (!mounted) return;
    setState(() {
      // a rematch resets the game: finished -> placing
      final restarted = s.status == 'placing' && _state?.status == 'finished';
      // new round (or restart): forget this round's local shots
      if (s.round != _lastRound || restarted) {
        _roundShots.clear();
        _submitting = false;
        _lastRound = s.round;
      }
      if (restarted) _placed.clear();
      _state = s;
      _refreshBoards();
    });
  }

    // rebuilds the two grids from the current phase
  void _refreshBoards() {
    final s = _state;
    if (s == null) return;
    if (s.status == 'placing') {
      // your own board shows the boats you are placing until you submit
      _myCells = s.iAmReady ? s.myCells() : _placementCells();
      _enemyCells = _emptyBoard();
    } else if (s.status == 'playing' || s.status == 'finished') {
      _myCells = s.myCells(); // my boats + the enemy's hits and misses
      _enemyCells = s.enemyCells(_roundShots); // what I have fired at
    }
  }

  // grid showing the boats chosen so far in the placing phase
  List<List<CellState>> _placementCells() {
    final cells = _emptyBoard();
    for (final i in _placed) {
      cells[i ~/ boardSize][i % boardSize] = CellState.boat;
    }
    return cells;
  }

  // two small helpers added.
  // _snack shows a message
  // _run runs a service call and shows any error (GameException messages like "Place exactly 3 boats." come ready to display).
  // Use it like:
  // _run(() => _service.submitShots(widget.lobbyCode, shots));


  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // ignore: unused_element
  Future<bool> _run(Future<void> Function() action) async {
    try {
      await action();
      return true;
    } on GameException catch (e) {
      _snack(e.message);
    } catch (_) {
      _snack('Something went wrong. Try again.');
    }
    return false;
    }

  List<List<CellState>> _emptyBoard() {
    return List.generate(
      boardSize,
      (_) => List.filled(boardSize, CellState.water),
    );
  }


    bool get _canPlace => 
    _state != null && _state!.status == 'placing' && !_state!.iAmReady;
 
   void _togglePlacement(int row, int col) {
    if (!_canPlace) return;
    final index = cellIndex(row, col);
    setState(() {
      if (_placed.contains(index)) {
        _placed.remove(index);
      } else if (_placed.length < boatCount) {
        _placed.add(index);
      }
      _refreshBoards();
    });
  }

   // sends the chosen boats to Firestore
  Future<void> _submitBoard() async {
    final board = List<int>.filled(boardCells, 0);
    for (final i in _placed) {
      board[i] = 1;
    }
    await _run(() => _service.submitBoard(widget.lobbyCode, board));
  }

      // playing phase: fire until you miss
  bool get _canFire =>
      _state != null &&
      _state!.status == 'playing' &&
      !_state!.iSubmitted &&
      !_submitting;

   void _fireAt(int row, int col) {
    final s = _state;
    if (s == null || !_canFire) return;
    final index = cellIndex(row, col);
    // already fired here (in an earlier round or this one)
    if (s.myShots.contains(index) || _roundShots.contains(index)) return;
 
    _roundShots.add(index);
    final hit = s.enemyBoard[index] == 1;
    // the shot shows immediately, before the round closes
    setState(_refreshBoards);
 
    // a miss, or sinking the last enemy boat, ends my turn
    if (!hit || s.allEnemyHit(_roundShots)) {
      _endTurn();
    }
  }

  // sends this round's shots. If both players have finished, the round
  // closes and both boards update; otherwise we wait for the opponent.
  Future<void> _endTurn() async {
    _submitting = true;
    final ok = await _run(
      () => _service.submitShots(widget.lobbyCode, List.of(_roundShots)),
    );
    // on success _submitting is cleared when the round number changes
    if (!ok) _submitting = false;
  }

// one line of text telling the player what is happening
  String _statusMessage() {
    final s = _state;
    if (s == null) return 'Connecting...';
    if (s.status == 'waiting') return 'Waiting for an opponent...';
    if (s.status == 'placing') {
      if (s.iAmReady) return 'Boats submitted. Waiting for opponent...';
      return 'Place your boats: ${_placed.length} / $boatCount';
    }
    if (s.status == 'playing') {
      if (!s.iSubmitted) return 'Round ${s.round}: keep firing until you miss';
      return s.enemySubmitted
          ? 'Updating...'
          : 'Waiting for opponent to finish...';
    }
    return 'Game over';
  }
  
   @override
  Widget build(BuildContext context) {
    final s = _state;
    // [FB-13] colour from the real role once we know it
    final isP1 = s != null ? s.myRole == 'p1' : widget.playerNumber == 1;
 
    return Scaffold(
      // wireframe colors for P1 and P2
      backgroundColor:
          isP1 ? const Color(0xFFEED9FB) : const Color(0xFFDDDDF8),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            Text('Lobby code: ${widget.lobbyCode}'),
            Text(_statusMessage()),
            Expanded(
              child: _BoardPanel(
                label: 'Enemy waters',
                // null (no taps) unless it is my turn to fire
                child: BoardGrid(
                  cells: _enemyCells,
                  onCellTap: _canFire ? _fireAt : null,
                ),
              ),
            ),
            Expanded(
              child: _BoardPanel(
                label: 'Your boats',
                // read-only except while placing boats
                child: BoardGrid(
                  cells: _myCells,
                  onCellTap: _canPlace ? _togglePlacement : null,
                ),
              ),
            ),
            // the Submit button only exists while placing boats
            if (_canPlace)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ElevatedButton(
                  onPressed: _placed.length == boatCount ? _submitBoard : null,
                  child: const Text('Submit boats'),
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