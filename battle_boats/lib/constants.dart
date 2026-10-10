//this file stores the constants of the game state so all files can access it
const int boardSize = 5;
const int boardCells = boardSize * boardSize;
const int boatCount = 3; //starting small


/// True when every boat cell (value 1) on [board] appears in [shots].
/// Boards are flat lists: 0 = water, 1 = boat.
bool allBoatsHit(List<int> board, Iterable<int> shots) {
  final fired = shots.toSet();
  final boats = [
    for (var i = 0; i < board.length; i++)
      if (board[i] == 1) i,
  ];
  // Guard: a board with no boats can never count as "all hit".
  return boats.isNotEmpty && boats.every(fired.contains);
}