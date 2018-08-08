import 'package:flutter/material.dart';

typedef void OnDragCallBack(DragDirection direction, double delta);

enum DragDirection {
  up, down, left, right, all
}

class ResizableRectangle extends StatefulWidget {
  ResizableRectangle({
    this.minWidth = 0.0,
    this.minHeight = 0.0,
    this.top,
    this.left,
    this.initialWidth,
    this.initialHeight,
    this.touchRadius = 24.0,
    this.snapIncrement = 0.1,
    this.snapFactor = 1.0,
    this.child,
    this.background,
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
    this.showDebug = false,
  });

  final double minWidth;
  final double minHeight;
  final double top;
  final double left;
  final double initialWidth;
  final double initialHeight;
  final double touchRadius;
  final double snapIncrement;
  final double snapFactor;
  final Widget child;
  final Widget background;

  //Debugging
  final bool showDebug;

  //Callbacks
  final OnDragCallBack onDragStart;
  final OnDragCallBack onDragUpdate;
  final OnDragCallBack onDragEnd;

  @override
  ResizableRectangleState createState() {
    return new ResizableRectangleState();
  }
}

class ResizableRectangleState extends State<ResizableRectangle> {
//  double width, height;
  double top, bottom, left, right;
  bool dragTop, dragBottom, dragLeft, dragRight, dragAll;
  double maxWidth, maxHeight;
  GlobalKey encompassingBoxKey = GlobalKey();

  @override
  void initState() {
    super.initState();
//    width = widget.initialWidth;
//    height = widget.initialHeight;

    dragTop = dragBottom = dragLeft = dragRight = dragAll = false;
    top = bottom = left = right = 0.0;
    //In case using max size, the size of the container is unknown until first render
    WidgetsBinding.instance.addPostFrameCallback((_){
      RenderBox box = encompassingBoxKey.currentContext.findRenderObject();
      var initHeight = widget.initialHeight != null ? widget.initialHeight : box.size.height;
      var initWidth = widget.initialWidth != null ? widget.initialWidth : box.size.width;
      setState(() {
        maxWidth = box.size.width;
        maxHeight = box.size.height;
        top = widget.top ?? maxHeight / 2 - initHeight / 2; //Defaults to center if widget.top is null
        bottom = top + initHeight;
        left = widget.left ?? maxWidth / 2 - initWidth / 2; //Defaults to center if widget.left is null
        right = left + initWidth;
      });

      debugPrint("top: $top, bottom: $bottom, left: $left, right: $right, "
          "maxWidth: $maxWidth, maxHeight: $maxHeight");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          key: encompassingBoxKey,
          width: double.infinity,
          height: double.infinity,
          color: widget.showDebug ? Colors.green : null,
          child: widget.background,
        ),
        Positioned(
          top: top,
          left: left,
          child: GestureDetector(
            onVerticalDragDown: _onVerticalDragStart,
            onVerticalDragCancel: _onDragCancel,
            onVerticalDragStart: _onVerticalDragStart,
            onVerticalDragUpdate: _onVerticalDragUpdate,
            onVerticalDragEnd: _onVerticalDragEnd,
            onHorizontalDragDown: _onHorizontalDragStart,
            onHorizontalDragCancel: _onDragCancel,
            onHorizontalDragStart: _onHorizontalDragStart,
            onHorizontalDragUpdate: _onHorizontalDragUpdate,
            onHorizontalDragEnd: _onHorizontalDragEnd,
            child: widget.showDebug ? getDebugBox() : Container(
              width: _width(),
              height: _height(),
              child: widget.child,
            ),
          ),
        )
      ],
    );
  }

  Widget getDebugBox() {
    return Stack(
      children: <Widget>[
        Container(
            width: _width(),
            height: _height(),
            child: widget.child
        ),
        Container(
          width: _width(),
          height: _height(),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.red.withOpacity(0.33), width: widget.touchRadius),
          ),
        )
      ],
    );
  }

  void _onVerticalDragStart(drag) {
    //Determine global position to enable dragTop or dragBottom
    RenderBox box = context.findRenderObject();
    var _tapPos = box.globalToLocal(drag.globalPosition);
    debugPrint("drag start: $drag, localPos: $_tapPos, mathTop: ${top + widget.touchRadius} mathBottom: ${bottom - widget.touchRadius}");
    //Drag Top if tapped within touchRadius
    if (_tapPos.dy < top + widget.touchRadius) {
      dragTop = true;
      _callBack(widget.onDragStart, DragDirection.up, 0.0);
    } else if (_tapPos.dy > bottom - widget.touchRadius) {
      dragBottom = true;
      _callBack(widget.onDragStart, DragDirection.down, 0.0);
    } else {
      dragAll = true;
      _callBack(widget.onDragStart, DragDirection.all, 0.0);
    }
    debugPrint("dragTop: $dragTop, dragBottom: $dragBottom");
  }

  void _onVerticalDragUpdate(drag) {
//              debugPrint("drag update: $drag");
    if (dragTop) {
      setState(() {
        top = (top + drag.primaryDelta).clamp(0.0, bottom - widget.minHeight);
      });
      _callBack(widget.onDragUpdate, DragDirection.up, drag.primaryDelta);
    } else if (dragBottom) {
      setState(() {
        bottom = (bottom + drag.primaryDelta).clamp(top + widget.minHeight, maxHeight);
      });
      _callBack(widget.onDragUpdate, DragDirection.down, drag.primaryDelta);
    } else {
      var currentHeight = _height();
      var prevTop = top;
      var prevBottom = bottom;
      setState(() {
        top = (top + drag.primaryDelta);
        bottom = (bottom + drag.primaryDelta);
        if (top < 0.0) {
          top = prevTop;
          bottom = top + currentHeight;
        } else if (bottom > maxHeight) {
          bottom = prevBottom;
          top = bottom - currentHeight;
        }
      });
      _callBack(widget.onDragUpdate, DragDirection.all, drag.primaryDelta);
    }
  }

  void _onVerticalDragEnd(drag) {
    int quotient = _height() ~/ widget.snapIncrement;
    var remainder = _height() % widget.snapIncrement;
    var ratio = quotient;
    if (remainder > widget.snapIncrement * widget.snapFactor) {
      ratio = quotient + 1;
    }
    var desiredHeight = ratio * widget.snapIncrement;
    if (dragTop) {
      setState(() {
        top = (bottom - desiredHeight).clamp(0.0, bottom - widget.minHeight);
      });
      _callBack(widget.onDragEnd, DragDirection.up, 0.0);
    } else if (dragBottom) {
      setState(() {
        bottom = (top + desiredHeight).clamp(top + widget.minHeight, maxHeight);
      });
      _callBack(widget.onDragEnd, DragDirection.down, 0.0);
    } else {
      int dragQuotient = maxHeight ~/ widget.snapIncrement;
      var dragRemainder = maxHeight % widget.snapIncrement;
      var ratio = quotient;
      if (remainder > widget.snapIncrement * widget.snapFactor) {
        ratio = quotient + 1;
      }
      var desiredHeight = ratio * widget.snapIncrement;
      setState(() {
        top = (bottom - desiredHeight).clamp(0.0, bottom - widget.minHeight);
        bottom = (top + desiredHeight).clamp(top + widget.minHeight, maxHeight);
      });
      _callBack(widget.onDragEnd, DragDirection.down, 0.0);
    }
    dragTop = dragBottom = dragAll = false;
  }

  void _onHorizontalDragStart(drag) {
    //Determine global position to enable dragTop or dragBottom
    RenderBox box = context.findRenderObject();
    var _tapPos = box.globalToLocal(drag.globalPosition);
    debugPrint("drag start: $drag, localPos: $_tapPos, mathTop: ${left + widget.touchRadius} mathBottom: ${right - widget.touchRadius}");
    //Drag Top if tapped within touchRadius
    if (_tapPos.dx < left + widget.touchRadius) {
      dragLeft = true;
      _callBack(widget.onDragStart, DragDirection.left, 0.0);
    } else if (_tapPos.dx > right - widget.touchRadius) {
      dragRight = true;
      _callBack(widget.onDragStart, DragDirection.right, 0.0);
    }
    debugPrint("dragLeft: $dragLeft, dragRight: $dragRight");
  }

  void _onHorizontalDragUpdate(drag) {
//              debugPrint("drag update: $drag");
    if (dragLeft) {
      setState(() {
        left = (left + drag.primaryDelta).clamp(0.0, right - widget.minWidth);
      });
      _callBack(widget.onDragUpdate, DragDirection.left, drag.primaryDelta);
    } else if (dragRight) {
      setState(() {
        right = (right + drag.primaryDelta).clamp(left + widget.minWidth, maxWidth);
      });
      _callBack(widget.onDragUpdate, DragDirection.right, drag.primaryDelta);
    }
  }

  void _onHorizontalDragEnd(drag) {
    debugPrint("drag end: $drag");
    int quotient = _width() ~/ widget.snapIncrement;
    var remainder = _width() % widget.snapIncrement;
    var ratio = quotient;
    if (remainder > widget.snapIncrement * widget.snapFactor) {
      ratio = quotient + 1;
    }
    var desiredWidth = ratio * widget.snapIncrement;
    if (dragLeft) {
      setState(() {
        left = (right - desiredWidth).clamp(0.0, right - widget.minWidth);
      });
      _callBack(widget.onDragEnd, DragDirection.left, 0.0);
    } else if (dragRight) {
      setState(() {
        right = (left + desiredWidth).clamp(left + widget.minHeight, maxWidth);
      });
      _callBack(widget.onDragEnd, DragDirection.right, 0.0);
    }
    dragLeft = dragRight = false;
  }

  void _onDragCancel() {
    if (dragTop) {
      _callBack(widget.onDragEnd, DragDirection.up, 0.0);
    } else if (dragBottom) {
      _callBack(widget.onDragEnd, DragDirection.down, 0.0);
    } else if (dragLeft) {
      _callBack(widget.onDragEnd, DragDirection.left, 0.0);
    } else if (dragRight) {
      _callBack(widget.onDragEnd, DragDirection.right, 0.0);
    } else {
      _callBack(widget.onDragEnd, DragDirection.all, 0.0);
    }
  }

  double _height() {
    return bottom - top;
  }

  double _width() {
    return right - left;
  }

  void _callBack(OnDragCallBack callback, DragDirection direction, double delta) {
    if (callback != null) {
      callback(direction, delta);
    }
  }
}