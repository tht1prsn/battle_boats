import 'dart:math';

import 'package:battle_boats/services/game_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:battle_boats/constants.dart';

//if there are any issues running app, we can throw a game exception
class GameException implements Exception {
  GameException(this.message);
  final String message;
  @override
  String toString() => message;
}

class GameServices {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  //characters used for join code
  static const _alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ123456789';

  //this is the user id, main automatically assigns uid so there will always be one
  String get _uid => _auth.currentUser!.uid;

  String _randomCode() {
    final r = Random.secure();
    //https://api.dart.dev/dart-core/List/List.generate.html
    return List.generate(5, (_) => _alphabet[r.nextInt(_alphabet.length)]).join();
  }

  //a fresh player
  Map<String, dynamic> _player(String? uid) => {
    'uid': uid,
    //25 spots for a 5x5 grid
    'board': List<int>.filled(25,0),
    'ready': false,
    'shots': <int>[],
    'submittedRound': 0,
  };


  // returns a string based on player role
  String _roleOf(Map<String, dynamic> data) {
    if (data['p1']['uid'] == _uid) return 'p1';
    if (data['p2']['uid'] == _uid) return 'p2';
    throw GameException('You are not in this game.');
  }

  String _other(String role) => role == 'p1' ? 'p2' : 'p1';


  // firestore lists come back as List<dynamic>, so convert (null to empty)
  List<int> _ints(dynamic v) => List<int>.from(v ?? const []);

  //creates a game and returns its join code. user becomes p1
  Future<String> createGame() async {
      final code = _randomCode();
      final ref = _db.collection('games').doc(code);
      //reads the document, if one is already there is returns false
      //this prevents two players from making the same code at the 
      //same time
      //https://firebase.google.com/docs/firestore/manage-data/transactions
      //https://firebase.google.com/docs/firestore/query-data/listen
      final created = await _db.runTransaction<bool>((transaction) async {
        final snap = await transaction.get(ref);
        if (snap.exists) return false;
        //new game doc, starts waiting for p2
        transaction.set(ref, {
          'status': 'waiting',
          'round': 1,
          'winner': null,
          'createdAt': FieldValue.serverTimestamp(),
          'p1': _player(_uid),
          'p2': _player(null),
        });
        return true;
      });
      if (created) return code;

    throw GameException('Could not create a game. Try again.');
  }

  //joining existing game as p2
  Future<void> joinGame(String code) async {
    final ref = _db.collection('games').doc(code.trim().toUpperCase());
    //lookig for game
    await _db.runTransaction((transaction) async {
    final snap = await transaction.get(ref);
    if (!snap.exists) throw GameException('No game with that code.');

    final p1Uid = snap.get('p1.uid');
    final p2Uid = snap.get('p2.uid');

    if (p1Uid == _uid || p2Uid == _uid) return; // already in this game
    if (p2Uid != null) throw GameException('That game is full.');

    transaction.update(ref, {'p2.uid': _uid, 'status': 'placing'});
  });
}

  // listens for everything in game
  // https://firebase.google.com/docs/firestore/query-data/listen
  Stream<GameState> watchGame(String code) {
    return _db
      .collection('games')
      .doc(code)
      .snapshots()
      .where((snap) => snap.exists)
      .map((snap) {
        final data = snap.data()!;
        final me = _roleOf(data);
        final mine = data[me] as Map<String, dynamic>;
        final theirs = data[_other(me)] as Map<String, dynamic>;
        final round = data['round'] as int;
        return GameState(
          status: data['status'] as String,
          round: round,
          winner: data['winner'] as String?,
          myRole: me,
          myBoard: _ints(mine['board']),
          enemyBoard: _ints(theirs['board']),
          myShots: _ints(mine['shots']),
          enemyShots: _ints(theirs['shots']),
          iAmReady: mine['ready'] == true,
          enemyReady: theirs['ready'] == true,
          iSubmitted: mine['submittedRound'] == round,
          enemySubmitted: theirs['submittedRound'] == round,
        );
      });
  }
  
  // initial phase: save my board and starts game once both are ready
    Future<void> submitBoard(String code, List<int> board) async {
    if (board.length != boardCells ||
        board.where((c) => c == 1).length != boatCount) {
      throw GameException('Place exactly $boatCount boats.');
    }
    final ref = _db.collection('games').doc(code);
    await _db.runTransaction((transaction) async {
      final snap = await transaction.get(ref);
      if (!snap.exists) throw GameException('No game with that code.');
      final data = snap.data()!;
      if (data['status'] != 'placing') {
        throw GameException('The game is not in the placing phase.');
      }
      final me = _roleOf(data);
      if (data[me]['ready'] == true) return; // already submitted
      final enemyReady = data[_other(me)]['ready'] == true;
      transaction.update(ref, {
        '$me.board': board,
        '$me.ready': true,
        if (enemyReady) 'status': 'playing',
      });
    });
  }
 
  /// playing phase: call once when my turn ends (first miss, or every
  /// enemy boat hit). shots is every cell I fired at this round.
  Future<void> submitShots(String code, List<int> shots) async {
    final ref = _db.collection('games').doc(code);
    await _db.runTransaction((transaction) async {
      final snap = await transaction.get(ref);
      if (!snap.exists) throw GameException('No game with that code.');
      final data = snap.data()!;
      if (data['status'] != 'playing') {
        throw GameException('The game is not in progress.');
      }
      final me = _roleOf(data);
      final enemy = _other(me);
      final round = data['round'] as int;
      final mine = data[me] as Map<String, dynamic>;
      final theirs = data[enemy] as Map<String, dynamic>;
 
      if (mine['submittedRound'] == round) return; // already submitted
 
      // I finished first, stop my shots and wait for the other player
      if (theirs['submittedRound'] != round) {
        transaction.update(ref, {
          '$me.pending': shots,
          '$me.submittedRound': round,
        });
        return;
      }
 
      // I finished second, close the round for both players.
      final myShots = {..._ints(mine['shots']), ...shots};
      final theirShots = {
        ..._ints(theirs['shots']),
        ..._ints(theirs['pending']),
      };
      final iWon = allBoatsHit(_ints(theirs['board']), myShots);
      final theyWon = allBoatsHit(_ints(mine['board']), theirShots);
 
      transaction.update(ref, {
        '$me.shots': myShots.toList(),
        '$me.pending': <int>[],
        '$enemy.shots': theirShots.toList(),
        '$enemy.pending': <int>[],
        'round': round + 1,
        if (iWon || theyWon) 'status': 'finished',
        if (iWon || theyWon)
          'winner': (iWon && theyWon) ? 'draw' : (iWon ? me : enemy),
      });
    });
  }
}