import 'package:battle_boats/services/game_services.dart';
import 'package:flutter/material.dart';
import 'package:battle_boats/widgets/join_lobby.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:battle_boats/screens/end_screen.dart';
import 'package:battle_boats/screens/game_screen.dart';

// when the player creates or joins a lobby
// collects the join code, start screen is the one that does the joining
class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // same font as the end screen so the app feels consistent
            Text(
              'BattleBoats',
              style: GoogleFonts.blackOpsOne(
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            // size fixing
            const SizedBox(height: 48),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                // aqua to match wireframe
                backgroundColor: const Color(0xFFC7F5EE),
                foregroundColor: Colors.black,
                side: const BorderSide(color: Colors.black),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
              ),
              onPressed: () async {
                // join code popup stuffs
                final code = await showDialog<String>(
                  context: context,
                  builder: (_) => const JoinLobbyDialog(),
                );
                if (code == null || !context.mounted) return;
                try {
                  // asks to add us as player 2
                  await GameServices().joinGame(code);
                  if (!context.mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          GameScreen(lobbyCode: code, playerNumber: 2),
                    ),
                  );
                } on GameException catch (e) {
                  // wrong code or full game, message comes from game_services
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(e.message)));
                } catch (_) {
                  // any other bad things to catch from Firebase
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Something went wrong. Try again.'),
                    ),
                  );
                }
              },
              child: const Text('Join Lobby'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                // blue to match wireframe
                backgroundColor: const Color(0xFFCFE0FB),
                foregroundColor: Colors.black,
                side: const BorderSide(color: Colors.black),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
              ),
              onPressed: () async {
              try {
                // makes a new game and gives its code
                // whoever does this become player 1
                final code = await GameServices().createGame();
                if (!context.mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GameScreen(lobbyCode: code, playerNumber: 1),
                  ),
                );
              } on GameException catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(e.message)));
              } catch (_) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Something went wrong. Try again.')),
                );
              }
            },
              child: const Text('Create Lobby'),
            ),
          ],
        ),
      ),
    );
  }
}
