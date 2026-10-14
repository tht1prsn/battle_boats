import 'package:battle_boats/widgets/board_grid.dart';
import 'package:flutter/material.dart';
import 'package:battle_boats/widgets/boat_widget.dart';

// the screen to show which player wins
class TestingScreen extends StatefulWidget {
  const TestingScreen({super.key});

  @override
  State<TestingScreen> createState() => _TestingScreenState();
}

class _TestingScreenState extends State<TestingScreen> {
  Size? cellSize = Size(50, 50);

  late List<DraggableBoat> fleet;
  late List<DraggableBoat> fleetCopy;
  final List<PlacedBoat> placedBoats = [];
  final Set<String> placedBoatIds = {};
  final List<List<CellState>> mycells = List.generate(
    5,
    (_) => List.filled(5, CellState.water),
  );

  @override
  void initState()
  {
    super.initState();
    fleet = [
      DraggableBoat(boatLength: 3, cellSize: cellSize!, id: "1"),
      DraggableBoat(boatLength: 1, cellSize: cellSize!, id: "2"),
      DraggableBoat(boatLength: 2, cellSize: cellSize!, id: "3")
    ];
    fleetCopy = fleet.toList();
  }

  void placeBoat(int row, int col, BoatState boat) {
    placedBoatIds.add(boat.id);
    setState(() {
      placedBoats.add(PlacedBoat(boat: boat, row: row, col: col));
      fleet.remove(fleet.firstWhere((b) => b.id == boat.id));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 600,
          height: 600,
          child: Column(
            children: [
                Expanded(child: 
                  _BoardPanel(
                    mode: BoardMode.placement,
                    label: "TestLabel",
                    child: SizedBox.square(
                    dimension: 250, // temporary size for a 5x5 grid with 50px cells
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: BoardGrid(
                            cells: mycells,
                            mode: BoardMode.placement,
                            onBoatDropped: placeBoat,
                          ),
                        ),

                        for (final placed in placedBoats)
                          Positioned(
                            left: placed.col * cellSize!.width,
                            top: placed.row * cellSize!.height,
                            width: placed.boat.direction == BoatOrientation.Horizontal
                                ? placed.boat.length * cellSize!.width
                                : cellSize!.width,
                            height: placed.boat.direction == BoatOrientation.Vertical
                                ? placed.boat.length * cellSize!.height
                                : cellSize!.height,
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 121, 113, 113),
                                border: Border.all(color: Colors.black),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: GestureDetector(
                                onDoubleTap: () {
                                  
                                  {
                                    setState(() {
                                      for(int i = 0; i < placed.boat.length; ++i)
                                      {
                                        if(placed.boat.direction == BoatOrientation.Horizontal)
                                        {
                                          mycells[placed.row][placed.col+i] = CellState.water;
                                        }
                                        else
                                        {
                                          mycells[placed.row+i][placed.col] = CellState.water;
                                        }
                                      }
                                      fleet.add(fleetCopy.firstWhere((b) => b.id == placed.boat.id));
                                      placedBoatIds.remove(placed.boat.id);
                                      placedBoats.remove(placed);

                                    });
                                  }
                                },
                              )
                            ),
                          ),
                      ],
                    ),
                  )
                ),
              ),
              Row(
                children: [...fleet],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _BoardPanel extends StatelessWidget {
  const _BoardPanel({required this.label, required this.child, required BoardMode mode});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      // fitting in everything in nicely
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black54, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(label),
          const SizedBox(height: 8),
          Expanded(
            child: Center(child: child),
          ),
        ],
      ),
    );
  }
}