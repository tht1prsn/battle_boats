import 'package:flutter/material.dart';

// when the player creates or joins a lobby 
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
              onPressed: () => (
                // going to put the next screen here
              ),
              child: const Text('Join Lobby'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                // we cannot join people yet so we wont join yet
              },
              child: const Text('Create Lobby'),
            ),
          ],
        ),
      ),
    );
  }
}