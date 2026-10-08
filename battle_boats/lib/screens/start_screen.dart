import 'package:flutter/material.dart';
import 'package:battle_boats/widgets/join_lobby.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:battle_boats/screens/end_screen.dart';

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
                debugPrint('Joining lobby $code');
                // still waiting for navigation to gamescreen through our wip join function
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
              onPressed: () {
                // going to put the next screen here
                // temp take us to end screen so we know everything works
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EndScreen(winPlayerNum: 1),
                  ),
                );
              },
              child: const Text('Create Lobby'),
            ),
          ],
        ),
      ),
    );
  }
}