import 'package:flutter/material.dart';

class CheckboxWidget extends StatefulWidget {
  final List<bool> values;
  final List<String> labels;

  const CheckboxWidget({
    Key? key,
    required this.values,
    required this.labels,
  }) : super(key: key);

  @override
  State<CheckboxWidget> createState() => _CheckboxWidgetState();
}

class _CheckboxWidgetState extends State<CheckboxWidget> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        children: [
          // Ряд для текстовых меток
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.labels.length, (index) {
              return Container(
                padding: const EdgeInsets.all(8.0),
                child: Text(widget.labels[index]),
                width: 50,
              );
            }),
          ),
          // Ряд для чекбоксов
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.values.length, (index) {
              return Container(
                padding: const EdgeInsets.all(8.0),
                width: 50,
                height: 50,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      widget.values[index] = !widget.values[index];
                    });
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: widget.values[index] ? Colors.orange : Colors.black.withOpacity(0.72),
                      border: Border.all(color: Colors.black),
                    ),
                    child: widget.values[index]
                        ? Icon(Icons.check, color: Colors.black)
                        : null,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}