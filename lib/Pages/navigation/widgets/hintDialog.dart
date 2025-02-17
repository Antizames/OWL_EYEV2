import 'package:flutter/material.dart';
class HintDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 50, // Увеличила высоту для соответствия размеру картинки
      child: ElevatedButton(
        onPressed: () {
          showHintDialog(context);
        },
        child: Icon(Icons.question_mark),
      ),
    );
  }

  void showHintDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.30,
            child: Column(
              mainAxisSize: MainAxisSize.min, // Высота окна подгоняется под содержимое
              crossAxisAlignment: CrossAxisAlignment.start, // Выравнивание по левому краю
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end, // Сдвигаем содержимое вниз
                    children: [
                      const Padding(padding: EdgeInsets.all(5)),
                      Expanded(child: Text(
                        "При нажатии на карту появится маркер, при его удержании откроется меню маркера",style: TextStyle(fontSize: 24),
                      ),)
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}