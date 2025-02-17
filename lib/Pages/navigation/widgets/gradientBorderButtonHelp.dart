import 'package:flutter/material.dart';
class GradientBorderButtonHelp extends StatefulWidget {
  final String text;
  final List<Color> buttonColors;
  final List<Color> borderColors;
  final String tooltipMessage;
  final VoidCallback onPressed;
  final bool toolTip;
  final double width;
  final double height;
  final Widget? iconLeft; // Добавляем параметр для левой иконки
  final Widget? iconRight; // Добавляем параметр для правой иконки

  const GradientBorderButtonHelp({
    Key? key,
    required this.text,
    required this.buttonColors,
    required this.borderColors,
    this.tooltipMessage = '',
    required this.onPressed,
    this.toolTip = true,
    required this.width,
    required this.height,
    this.iconLeft, // создаем новое поле для левой иконки
    this.iconRight, // создаем новое поле для правой иконки
  }) : super(key: key);

  @override
  State<GradientBorderButtonHelp> createState() => _GradientBorderButtonHelpState();
}

class _GradientBorderButtonHelpState extends State<GradientBorderButtonHelp> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: widget.borderColors,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(2),
        margin: const EdgeInsets.all(4),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onPressed,
            onLongPress: widget.toolTip ? () {
              // Действие при долгом нажатии для отображения тултипа
            } : null,
            borderRadius: BorderRadius.circular(10),
            child: Ink(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: widget.buttonColors,
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(8), // Добавляем небольшой отступ для внутреннего содержимого
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Равномерно распределяем пространство
                children: [
                  Text(
                    widget.text,
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                    textAlign: TextAlign.start,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Иконки будут на краях
                    children: [
                      if(widget.iconLeft != null)
                        Container(
                          width: 100.0, // Задаем фиксированную ширину для контейнера
                          height: 70.0, // Задаем фиксированную высоту для контейнера
                          child: widget.iconLeft!,
                        ), // Левая иконка
                      if(widget.iconRight != null)
                        Container(
                          width: 60.0, // Задаем фиксированную ширину для контейнера
                          height: 60.0, // Задаем фиксированную высоту для контейнера
                          child: widget.iconRight!,
                        ), // Правая иконка
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}