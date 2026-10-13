import 'package:battle_boats/widgets/board_grid.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:battle_boats/widgets/boat_widget.dart';

// the screen to show which player wins
class TestingScreen extends StatefulWidget {
  const TestingScreen({super.key});

  @override
  State<TestingScreen> createState() => _TestingScreenState();
}

class _TestingScreenState extends State<TestingScreen> {
  final List<List<CellState>> mycells = List.generate(
    5,
    (_) => List.filled(5, CellState.water),
  );

  Size? cellSize;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 800,
          height: 1000,
          child: Column(
            children: [
              
                _BoardPanel(
                  label: "TestLabel",
                  child: BoardGrid(
                    cells: mycells,
                    onCellSizeChanged: (newSize) {
                      if (cellSize != newSize) {
                        setState(() => cellSize = newSize);
                      }
                    },
                  ),
                ),
              if (cellSize != null)
                DraggableBoat(
                  cellSize: cellSize!,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BoardPanel extends StatelessWidget {
  const _BoardPanel({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      // fitting in everything in nicely
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.lightBlue,
        border: Border.all(color: Colors.black54, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(label),
          const SizedBox(height: 8),
          (Center(child: child)),
        ],
      ),
    );
  }
}