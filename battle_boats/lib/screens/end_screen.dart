import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// the screen to show which player wins
class EndScreen extends StatefulWidget {
  const EndScreen({super.key, required this.winPlayerNum, this.onRematch});

  // we want the lobby creator to be P1 and the joiner P2 (null means a draw)
  final int? winPlayerNum;

  // called when Rematch is tapped. Returns true if the request went through.
  // null means no rematch is available, so the button stays disabled.
  final Future<bool> Function()? onRematch;

  @override
  State<EndScreen> createState() => _EndScreenState();
}

class _EndScreenState extends State<EndScreen> {
  // true once we have asked for a rematch and are waiting on the other player
  bool _requested = false;

  Future<void> _rematch() async {
    final ok = await widget.onRematch!();
    // if the other player asked first, the game resets and this screen closes
    // before we get here, so check it is still on screen
    if (ok && mounted) setState(() => _requested = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // displays winner with fancy font
            Text(
              widget.winPlayerNum == null
                  ? 'Draw!'
                  : 'Player ${widget.winPlayerNum} wins!',
              style: GoogleFonts.blackOpsOne(
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                // green to match wireframe
                backgroundColor: const Color(0xFFCDF2C8),
                foregroundColor: Colors.black,
                side: const BorderSide(color: Colors.black),
                shape: const StadiumBorder(),
              ),
              // disabled once we've asked, or if there is no rematch callback
              onPressed:
                  (_requested || widget.onRematch == null) ? null : _rematch,
              child: Text(_requested ? 'Waiting for opponent...' : 'Rematch'),
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
              // pop until instead of pushNamed to not create a new instance of the start screen
              // pop until brings to first, which would be start_screen when finished
              onPressed: () {
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