import 'package:flutter/material.dart';

class ColorDot extends StatelessWidget {
  final String color;

  const ColorDot({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        color: _getColor(),
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }

  Color _getColor() {
    switch (color.toLowerCase()) {
      case 'black':
        return Colors.black;
      case 'red':
        return Colors.red;
      case 'white':
        return Colors.white;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      default:
        return Colors.white;
    }
  }
}