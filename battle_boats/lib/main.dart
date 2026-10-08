import 'package:flutter/material.dart';
import 'package:battle_boats/screens/start_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:battle_boats/screens/game_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
await Firebase.initializeApp (
  options: DefaultFirebaseOptions.currentPlatform,
);
//when launching firebase it signs in user as anonymous
//so they do not need to have a sign in
//https://firebase.google.com/docs/auth/flutter/anonymous-auth
if (FirebaseAuth.instance.currentUser == null) {
  await FirebaseAuth.instance.signInAnonymously();
}
runApp(const MainApp());
}


class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: StartScreen(),
    );
  }
}
