//this class stores info regarding the game state

import 'package:battle_boats/constants.dart';
import 'package:battle_boats/widgets/board_grid.dart';

class GameState {
  GameState({
    required this.status,
    required this.round,
    required this.winner,
    required this.myRole,
    required this.myBoard,
    required this.enemyBoard,
    required this.myShots,
    required this.enemyShots,
    required this.iAmReady,
    required this.enemyReady,
    required this.iSubmitted,
    required this.enemySubmitted,
    required this.iWantRematch,
    required this.enemyWantsRematch,
  });

  final String status; // waiting | placing | playing | finished
  final int round;
  final String? winner; // 'p1' | 'p2' | 'draw' | null
  final String myRole; // 'p1' | 'p2'

  final List<int> myBoard; // 0 water, 1 boat
  final List<int> enemyBoard; // only use during 'playing'
  final List<int> myShots; // cells I fired at the enemy 
  final List<int> enemyShots; // cells the enemy fired at me 

  final bool iAmReady;
  final bool enemyReady;
  final bool iSubmitted; // I finished this round's turn
  final bool enemySubmitted;

  final bool iWantRematch;
  final bool enemyWantsRematch;

  bool get iWon => winner == myRole;
  bool get isDraw => winner == 'draw';

  //returns true when all enemy boats are hit by my closed-round shots
  //plus roundShots (the shots I have made so far this round)
  bool allEnemyHit(Iterable<int> roundShots) =>
      allBoatsHit(enemyBoard, [...myShots, ...roundShots]);

  ///my board as a grid for BoardGrid: my boats, plus the enemy's hits
  ///and misses on it. Only changes when a round closes
  List<List<CellState>> myCells() {
    final fired = enemyShots.toSet();
    return _toGrid((i) {
      final boat = myBoard.length > i && myBoard[i] == 1;
      if (fired.contains(i)) return boat ? CellState.hit : CellState.miss;
      return boat ? CellState.boat : CellState.water;
    });
  }

  /// The enemy's board as a grid: only cells I have fired at, shown as hit
  /// or miss. Pass this round's shots so far in roundShots so they show
  /// immediately, before the round closes.
  List<List<CellState>> enemyCells([Iterable<int> roundShots = const []]) {
    final fired = {...myShots, ...roundShots};
    return _toGrid((i) {
      if (!fired.contains(i)) return CellState.water;
      final boat = enemyBoard.length > i && enemyBoard[i] == 1;
      return boat ? CellState.hit : CellState.miss;
    });
  }

  List<List<CellState>> _toGrid(CellState Function(int index) cellAt) {
    return List.generate(
      boardSize,
      (r) => List.generate(boardSize, (c) => cellAt(cellIndex(r, c))),
    );
  }
}