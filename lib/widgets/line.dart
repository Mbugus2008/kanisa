import 'package:flutter/cupertino.dart';

class Line extends StatelessWidget {
  Line({
    super.key, required this.size, required this.orientation
  });

  double size;
  lineOrientation orientation;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: getwidth(), // Width of the line
      height: getheight(), // Thickness of the line
      child: Container(
        color: Color.fromRGBO(136, 14, 79, .2), // Color of the line
      ),
    );
  }

  double getwidth() {
    return (orientation == lineOrientation.vertical) ? 2.0 : size;
  }
  double getheight() {
    return (orientation == lineOrientation.horizontal) ? 2.0 : size;
  }
}
enum lineOrientation{horizontal,vertical}