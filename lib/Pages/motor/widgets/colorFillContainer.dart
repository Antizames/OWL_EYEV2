import 'package:flutter/material.dart';
class ColorFillContainer extends StatefulWidget {
  final double sliderValue;

  ColorFillContainer({required this.sliderValue});

  @override
  _ColorFillContainerState createState() => _ColorFillContainerState();
}

class _ColorFillContainerState extends State<ColorFillContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.horizontal(
                left: Radius.circular(10),
                right: Radius.circular(10),
              ),
              color: Colors.grey,
              border: Border.all(color: Colors.black, width: 1), // Добавляем черную рамку
            ),
            height: 160,
            width: 80,
            child: Center(
              child: Text(
                (1000 + widget.sliderValue * 1000).toStringAsFixed(0),
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),

          Positioned(
            left: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 1),borderRadius: BorderRadius.horizontal(
                left: Radius.circular(10),
                right: Radius.circular(10), // Скругление слева
              ),color: Colors.orange,),
              height: 160 * widget.sliderValue,
              width: 80,
              child: Center(child: Text((1000+widget.sliderValue*1000).toStringAsFixed(0),style: TextStyle(fontSize: 20),)),
            ),
          ),
        ],
      ),
    );
  }
}