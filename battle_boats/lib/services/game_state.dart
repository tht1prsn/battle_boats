//this class stores info regarding the game state

import 'package:battle_boats/constants.dart';

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

  bool get iWon => winner == myRole;
  bool get isDraw => winner == 'draw';

  //returns true when all enemies are hit
  bool allEnemyHit(Iterable<int> roundShots) =>
      allBoatsHit(enemyBoard, [...myShots, ...roundShots]);
  }