import 'package:flutter/material.dart';


//https://api.flutter.dev/flutter/widgets/Draggable-class.html
class DraggableBoat extends StatefulWidget {
  const DraggableBoat({super.key});

  @override
  State<DraggableBoat> createState() => _DraggableBoatState();
}

class _DraggableBoatState extends State<DraggableBoat> {
  int boatLength = 2;
  //separate class for individual boat pieces
  List<Widget> boats = List.empty(growable: true);

  @override
  void initState()
  {
    super.initState();

    for(int i = 0; i < boatLength; ++i)
    {
      boats.add(
        ColoredBox(
          color: Colors.purple,
          child: SizedBox(
            width: 100,
            height: 100
          )
        )
      );
    }

  }

  @override 
  Widget build(BuildContext context)
  {
    return 
    Draggable<int>(
      data: 1,
      feedback: Flex(
        direction: Axis.horizontal, children: [...boats]
      ), 
      child: Flex(
        direction: Axis.horizontal, children: [...boats]
      ),
    );
  }
}