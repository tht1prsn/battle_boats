import 'package:battle_boats/screens/game_screen.dart';
import 'package:battle_boats/widgets/boat_widget.dart';
import 'package:flutter/material.dart';
import 'package:battle_boats/widgets/board_grid.dart';

// board size for editing
// we can bring it from 5x5 to something fancier
const int boardSize = 5;

// main play screen
class SetupScreen extends StatefulWidget {
  const SetupScreen({
    super.key,
    required this.lobbyCode,
    required this.playerNumber,
  });

  final String lobbyCode;
  final int playerNumber;

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {

  Size? cellSize = Size(50, 50);
  // your own board, boats included
  late List<List<CellState>> myCells;


  late List<DraggableBoat> fleet;
  late List<DraggableBoat> fleetCopy;
  final List<PlacedBoat> placedBoats = [];
  final Set<String> placedBoatIds = {};

  @override
  void initState() {
    super.initState();
    myCells = _emptyBoard();

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

  List<List<CellState>> _emptyBoard() {
    return List.generate(
      boardSize,
      (_) => List.filled(boardSize, CellState.water),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // wireframe colors for P1 and P2
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            Text('Lobby code: ${widget.lobbyCode}'),
            Expanded(
              child:_BoardPanel(
                    mode: BoardMode.placement,
                    label: "TestLabel",
                    child: SizedBox.square(
                    dimension: 250, // temporary size for a 5x5 grid with 50px cells
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: BoardGrid(
                            cells: myCells,
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
                                          myCells[placed.row][placed.col+i] = CellState.water;
                                        }
                                        else
                                        {
                                          myCells[placed.row+i][placed.col] = CellState.water;
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
            Container(
              height: 150,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
               color: Colors.white,
               border: Border.all(color: Colors.black54, width: 2),
               borderRadius: BorderRadius.circular(12),
              ),
              child: Column(children: [
                Text("Fleet"),
                Row(children: [
                  ...fleet
                ],),
                ElevatedButton(
                  onPressed: fleet.isEmpty ? () {
                    // move to game screen

                    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) 
                    { 
                      return GameScreen(lobbyCode: widget.lobbyCode, playerNumber: widget.playerNumber, myCells: myCells, playerBoard: placedBoats);
                    }));

                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey,
                    disabledForegroundColor: Colors.white70,
                  ),
                  child: const Text('Ready up'),
              )
              ],))
          ],
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