import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// the screen to show which player wins
class EndScreen extends StatelessWidget {
  const EndScreen({super.key, required this.winPlayerNum});

  // we want the lobby creator to be P1 and the joiner P2
  final int winPlayerNum;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // displays winner with fancy font
            Text(
              'Player $winPlayerNum wins!',
              style: GoogleFonts.blackOpsOne(
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 48),
            // WIP rematch button for later
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                // green to match wireframe
                backgroundColor: const Color(0xFFCDF2C8),
                foregroundColor: Colors.black,
                side: const BorderSide(color: Colors.black),
                shape: const StadiumBorder(),
              ),
              onPressed: () {
                // still have to make the re queue stuff, do later
              },
              child: const Text('Rematch'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                // pink to match wireframe
                backgroundColor: const Color(0xFFF7D4D4),
                foregroundColor: Colors.black,
                side: const BorderSide(color: Colors.black),
                shape: const StadiumBorder(),
              ),
              // https://api.flutter.dev/flutter/widgets/Navigator/popUntil.html
              // pop until instead of pushNamed to not create a new instance of the start screen
              // pop until brings to first, which would be start_screen when finished
              onPressed: () {
                // print to make sure navigator works
                // debugPrint('Back to Lobby tapped');
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text('Back to Lobby'),
            ),
          ],
        ),
      ),
    );
  }
}