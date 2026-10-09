import 'dart:math';

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
}