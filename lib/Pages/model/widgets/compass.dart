import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_svg/flutter_svg.dart';

class CompassPainter extends CustomPainter {
  final double yaw;

  CompassPainter({required this.yaw});

  @override
  void paint(Canvas canvas, Size size) {
    // Настройка кистей
    Paint circlePaint = Paint()
      ..color = Colors.grey.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..isAntiAlias = true;

    Paint tickPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.0;

    Paint needlePaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    Paint planePaint = Paint()
      ..color = Colors.blueAccent
      ..style = PaintingStyle.fill;

    // Центр и радиус компаса
    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = min(size.width, size.height) / 2 * 0.9;

    // Рисуем внешнее кольцо компаса
    canvas.drawCircle(center, radius, circlePaint);

    // Рисуем деления компаса каждые 10 градусов
    for (int i = 0; i < 360; i += 5) {
      double angle = i * pi / 180;
      double innerRadius = 0;
      if (i % 30 == 0 && i % 90 != 0){
        innerRadius = radius * 0.85;
        tickPaint.strokeWidth = 2;
      }
      else if (i % 90 == 0){
        innerRadius = radius * 0.8;
        tickPaint.strokeWidth = 3;
      }
      else{
        innerRadius = radius * 0.9;
        tickPaint.strokeWidth = 1;
      }

      Offset startPoint = Offset(
        center.dx + innerRadius * cos(angle),
        center.dy + innerRadius * sin(angle),
      );
      Offset endPoint = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      canvas.drawLine(startPoint, endPoint, tickPaint);
    }

    // Добавляем метки градусов каждые 30 градусов
    TextPainter textPainter = TextPainter(
      textAlign: TextAlign.start,
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i < 360; i += 30) {
      double angle = i * pi / 180 - 1.57;
      double textRadius = radius * 0.73;
      String direction = _getDirectionLabel(i);

      Offset textOffset = Offset(
        center.dx + textRadius * cos(angle),
        center.dy + textRadius * sin(angle),
      );

      textPainter.text = TextSpan(
        text: direction,
        style: TextStyle(
          color: Colors.black,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      canvas.save();
      canvas.translate(textOffset.dx, textOffset.dy);
      canvas.rotate(angle + pi / 2);
      textPainter.paint(
          canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
      canvas.restore();
    }

    // Рисуем самолет БПЛА в центре компаса
    _drawUAV(canvas, center, planePaint, radius);
    _drawPlaneIcon(canvas, center, radius, yaw);
  }
  void _drawPlaneIcon(Canvas canvas, Offset center, double radius, double yaw) {
    // Сохраняем состояние холста
    canvas.save();

    // Переносим холст в центр и поворачиваем на угол yaw
    canvas.translate(center.dx, center.dy);
    canvas.rotate((yaw) * pi / 180);

    // Загружаем иконку самолета и рисуем в центре компаса
    TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(Icons.airplanemode_active.codePoint),
        style: TextStyle(
          fontSize: radius * 1.2, // Размер иконки самолета
          fontFamily: Icons.airplanemode_active.fontFamily,
          color: Colors.red, // Цвет самолета
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    // Рисуем иконку самолета с учетом перевода и поворота
    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );

    // Восстанавливаем состояние холста
    canvas.restore();
  }

  // Функция для получения меток направлений
  String _getDirectionLabel(int degree) {
    switch (degree) {
      case 0:
        return 'N';
      case 30:
        return '${(degree/10).toInt()}';
      case 60:
        return '${(degree/10).toInt()}';
      case 90:
        return 'E';
      case 120:
        return '${(degree/10).toInt()}';
      case 150:
        return '${(degree/10).toInt()}';
      case 180:
        return 'S';
      case 210:
        return '${(degree/10).toInt()}';
      case 240:
        return '${(degree/10).toInt()}';
      case 270:
        return 'W';
      case 300:
        return '${(degree/10).toInt()}';
      case 330:
        return '${(degree/10).toInt()}';
      default:
        return '$degree°';
    }
  }

  // Функция для рисования БПЛА
  void _drawUAV(Canvas canvas, Offset center, Paint paint, double radius) {
    Path uavPath = Path();

    // Тело БПЛА
    uavPath.moveTo(center.dx, center.dy - radius * 0.05);
    uavPath.lineTo(center.dx - radius * 0.03, center.dy + radius * 0.05);
    uavPath.lineTo(center.dx + radius * 0.03, center.dy + radius * 0.05);
    uavPath.close();

    // Крылья
    uavPath.moveTo(center.dx - radius * 0.05, center.dy);
    uavPath.lineTo(center.dx - radius * 0.15, center.dy + radius * 0.03);
    uavPath.lineTo(center.dx - radius * 0.05, center.dy + radius * 0.03);

    uavPath.moveTo(center.dx + radius * 0.05, center.dy);
    uavPath.lineTo(center.dx + radius * 0.15, center.dy + radius * 0.03);
    uavPath.lineTo(center.dx + radius * 0.05, center.dy + radius * 0.03);

    canvas.drawPath(uavPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
