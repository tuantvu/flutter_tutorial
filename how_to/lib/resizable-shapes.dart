import 'package:flutter/material.dart';
import 'package:how_to/resizable-rectangle.dart';

class ResizableShapes extends StatefulWidget {
  @override
  ResizableShapesState createState() {
    return new ResizableShapesState();
  }
}

class ResizableShapesState extends State<ResizableShapes> {
  bool leftBorderOn = false;
  bool rightBorderOn = false;
  bool topBorderOn = false;
  bool bottomBorderOn = false;

  @override
  Widget build(BuildContext context) {
    return Align(
      child: Container(
        width: 200.0,
        height: 500.0,
        child: Center(
          child: ResizableRectangle(
            minHeight: 25.0,
            minWidth: 100.0,
            initialHeight: 50.0,
            snapIncrement: 25.0,
            snapFactor: 0.25,
            touchRadius: 25.0,
            showDebug: false,
            background: DecoratedBox(decoration: BoxDecoration(color: Colors.green)),
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: topBorderOn ? Colors.yellow : Colors.black54,
                    width: topBorderOn ? 4.0 : 1.0,
                  ),
                  bottom: BorderSide(
                    color: bottomBorderOn ? Colors.yellow : Colors.black54,
                    width: bottomBorderOn ? 4.0 : 1.0,
                  ),
                  left: BorderSide(
                    color: leftBorderOn ? Colors.yellow : Colors.black54,
                    width: leftBorderOn ? 4.0 : 1.0,
                  ),
                  right: BorderSide(
                    color: rightBorderOn ? Colors.yellow : Colors.black54,
                    width: rightBorderOn ? 4.0 : 1.0,
                  ),
                )
              ),
              child: Center(
                child: Text("ehh"),
              ),
            ),
            onDragStart: (direction, delta) {
              setState(() {
                if (direction == AxisDirection.up) {
                  topBorderOn = true;
                } else if (direction == AxisDirection.down) {
                  bottomBorderOn = true;
                } else if (direction == AxisDirection.left) {
                  leftBorderOn = true;
                } else if (direction == AxisDirection.right) {
                  rightBorderOn = true;
                }
              });
            },
            onDragEnd: (direction, delta) {
              setState(() {
                topBorderOn = bottomBorderOn = leftBorderOn = rightBorderOn = false;
              });
            },
          ),
        ),
      ),
    );
  }
}