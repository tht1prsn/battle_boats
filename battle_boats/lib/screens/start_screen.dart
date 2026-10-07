import 'package:flutter/material.dart';
import 'package:battle_boats/widgets/join_lobby.dart';

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
            // maybe we can come in and make the font cool later
            Text('BattleBoats',
                style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 48),
            ElevatedButton(
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
              onPressed: () {
                // going to put the next screen here
              },
              child: const Text('Create Lobby'),
            ),
          ],
        ),
      ),
    );
  }
}