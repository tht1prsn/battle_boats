import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:battle_boats/widgets/boat_widget.dart';

// the screen to show which player wins
class TestingScreen extends StatelessWidget {
  const TestingScreen({super.key});

 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: DraggableBoat()
      ),
    );
  }
}