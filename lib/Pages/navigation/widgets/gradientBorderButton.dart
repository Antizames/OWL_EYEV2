import 'package:flutter/material.dart';
class GradientBorderButton extends StatefulWidget {
  final String text;
  final List<Color> buttonColors;
  final List<Color> borderColors;
  final String tooltipMessage;
  final VoidCallback onPressed;
  final bool toolTip;
  final double width; // Убираем необязательность этих параметров
  final double height;
  final Widget? icon; // Добавляем новый параметр для иконки

  const GradientBorderButton({
    Key? key,
    required this.text,
    required this.buttonColors,
    required this.borderColors,
    this.tooltipMessage = '',
    required this.onPressed,
    this.toolTip = true,
    required this.width,
    required this.height,
    this.icon, // создаем новое поле для иконки
  }) : super(key: key);

  @override
  State<GradientBorderButton> createState() => _GradientBorderButtonState();
}

class _GradientBorderButtonState extends State<GradientBorderButton> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: widget.borderColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
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
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Иконка слева, выровненная по вертикали и прижатая к левому краю
                  if (widget.icon != null)
                    Positioned(
                      left: 0,
                      child: Container(
                        padding: const EdgeInsets.only(left: 0), // Слегка отодвигаем от края для визуального комфорта
                        child: Container(
                          width: 130.0, // Задаем фиксированную ширину для контейнера
                          height: 140.0, // Задаем фиксированную высоту для контейнера
                          child: widget.icon!,
                        ),
                      ),
                    ),

                  // Текст по центру. Иконка не влияет на его позиционирование
                  Text(
                    widget.text,
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}