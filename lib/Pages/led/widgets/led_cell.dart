import 'package:flutter/material.dart';

class LedCell extends StatelessWidget {
  final int index;
  final bool isSelected;
  final Set<String> directions;
  final int? colorIndex;

  const LedCell({
    super.key,
    required this.index,
    required this.isSelected,
    required this.directions,
    this.colorIndex,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor = _getBackgroundColor(colorIndex);
    final bool hasColor = colorIndex != null;
    final Color fgColor = hasColor ? Colors.black : Colors.white;

    return Stack(
      children: [
        // Фон
        Container(
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
        ),

        // Стрелки (вверх, вниз, вправо, влево)
        if (directions.contains('С'))
          Positioned(
            top: -6,
            left: 0,
            right: 0,
            child: Icon(Icons.arrow_drop_up, size: 18, color: fgColor),
          ),
        if (directions.contains('Ю'))
          Positioned(
            bottom: -6,
            left: 0,
            right: 0,
            child: Icon(Icons.arrow_drop_down, size: 18, color: fgColor),
          ),
        if (directions.contains('В'))
          Positioned(
            top: 0,
            bottom: 0,
            right: -6,
            child: Icon(Icons.arrow_right, size: 18, color: fgColor),
          ),
        if (directions.contains('З'))
          Positioned(
            top: 0,
            bottom: 0,
            left: -6,
            child: Icon(Icons.arrow_left, size: 18, color: fgColor),
          ),

        // Выделение
        if (isSelected)
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.deepPurpleAccent, width: 2),
              borderRadius: BorderRadius.circular(4),
            ),
          ),

        // U / D текст
        if (directions.contains('U'))
          Positioned(
            top: 2,
            left: 3,
            child: Text(
              'U',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: fgColor,
              ),
            ),
          ),
        if (directions.contains('D'))
          Positioned(
            bottom: 2,
            right: 3,
            child: Text(
              'D',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: fgColor,
              ),
            ),
          ),
      ],
    );
  }

  Color _getBackgroundColor(int? index) {
    if (index == null) return Colors.transparent;
    final hue = (index * 360 / 16) % 360;
    return HSVColor.fromAHSV(1.0, hue, 0.5, 0.85).toColor();
  }
}
