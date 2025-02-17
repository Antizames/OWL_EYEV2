import 'package:flutter/material.dart';
class RollTextField extends StatelessWidget {
  final TextEditingController controller;
  final Function(double?) onRollChanged;

  RollTextField({
    Key? key,
    required this.controller,
    required this.onRollChanged,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      width: MediaQuery.of(context).size.width * 0.8,
      height: 40,
      child: Padding(
        padding: EdgeInsets.only(left: 10),
        child: TextField(
          controller: controller,
          style: TextStyle(color: Colors.grey),
          decoration: InputDecoration(
            border: InputBorder.none, // Удаление стандартной рамки
            hintText: 'Введите значение', // Подсказка, когда поле пустое
            hintStyle: TextStyle(color: Colors.grey),
          ),
          keyboardType: TextInputType.number, // Клавиатура для чисел
          onChanged: (text) {
            var newValue = double.tryParse(text);
            if (newValue != null) {
              if (newValue > 360) {
                newValue = 360;
                controller.text = newValue.toStringAsFixed(0);
                controller.selection = TextSelection.fromPosition(TextPosition(offset: controller.text.length));
              } else if(newValue < 0){
                newValue = 0;
                controller.text = newValue.toStringAsFixed(0);
                controller.selection = TextSelection.fromPosition(TextPosition(offset: controller.text.length));
              }
              onRollChanged(newValue);
            } else {
              onRollChanged(null);
            }
          },
        ),
      ),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.horizontal(
          left: Radius.circular(7),
          right: Radius.circular(7), // Скругление слева
        ),
        border: Border.all(color: Color.fromARGB(255, 109, 113, 120), width: 1),
      ),
    );
  }
}
