import 'dart:math';
import 'package:flutter/material.dart';

class AttitudeIndicator extends StatelessWidget {
  final double pitch;
  final double roll;

  const AttitudeIndicator({Key? key, required this.pitch, required this.roll}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(180, 180),
      painter: OuterCirclePainter(roll: roll),
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: ClipOval(
          child: CustomPaint(
            size: Size(130, 130),
            painter: AttitudeIndicatorPainter(pitch: pitch, roll: roll),
          ),
        ),
      ),
    );
  }
}

class OuterCirclePainter extends CustomPainter {
  final double roll;

  OuterCirclePainter({required this.roll});

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double outerRadius = size.width / 2;

    Paint outerBackgroundPaint = Paint()..color = Colors.black;
    canvas.drawCircle(Offset(centerX, centerY), outerRadius, outerBackgroundPaint);

    Paint borderPaint = Paint()
      ..color = Colors.grey[800]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(Offset(centerX, centerY), outerRadius, borderPaint);

    canvas.save();
    canvas.translate(centerX, centerY);
    canvas.rotate(-roll * pi / 180);

    Paint skyPaint = Paint()..color = Colors.blue;
    Paint groundPaint = Paint()..color = Colors.brown;

    canvas.drawArc(Rect.fromCircle(center: Offset(0, 0), radius: outerRadius), pi, pi, true, skyPaint);
    canvas.drawArc(Rect.fromCircle(center: Offset(0, 0), radius: outerRadius), 0, pi, true, groundPaint);

    Paint horizonPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4;
    canvas.drawLine(Offset(-outerRadius, 0), Offset(outerRadius, 0), horizonPaint);

    _drawRollScaleInCenter(canvas, 0, 0, outerRadius);

    canvas.restore();
  }

  void _drawRollScaleInCenter(Canvas canvas, double centerX, double centerY, double outerRadius) {
    Paint scalePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;

    for (int i = -90; i <= 90; i += 10) {
      double angle = (i - 90) * pi / 180;
      double innerRadius = outerRadius * 0.7;
      double lineLength = (i % 30 == 0) ? 25 : 15;
      double startX = innerRadius * cos(angle);
      double startY = innerRadius * sin(angle);
      double endX = (innerRadius + lineLength) * cos(angle);
      double endY = (innerRadius + lineLength) * sin(angle);

      canvas.drawLine(
        Offset(centerX + startX, centerY + startY),
        Offset(centerX + endX, centerY + endY),
        scalePaint,
      );
    }
  }

  @override
  bool shouldRepaint(OuterCirclePainter oldDelegate) {
    return oldDelegate.roll != roll;
  }
}

class AttitudeIndicatorPainter extends CustomPainter {
  final double pitch;
  final double roll;

  AttitudeIndicatorPainter({required this.pitch, required this.roll});

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double radius = size.width / 2;

    // Смещение линии горизонта и фона в зависимости от pitch
    double verticalOffset = (pitch / 60.0) * centerY * 0.7;

    canvas.save();
    canvas.translate(centerX, centerY);
    canvas.rotate(-roll * pi / 180);

    Paint skyPaint = Paint()..color = Colors.blue;
    Paint groundPaint = Paint()..color = Colors.brown;

    // Рисуем верхнюю полусферу (небо)
    canvas.drawArc(
      Rect.fromCircle(center: Offset(0, verticalOffset), radius: radius), // Положение и размер арки
      pi, // Начальный угол для верхней полусферы
      pi, // Угол для полусферы
      true, // Закрашиваемую область
      skyPaint, // Цвет неба
    );

// Рисуем нижнюю полусферу (земля)
    canvas.drawArc(
      Rect.fromCircle(center: Offset(0, verticalOffset), radius: radius), // Положение и размер арки
      0, // Начальный угол для нижней полусферы
      pi, // Угол для полусферы
      true, // Закрашиваемую область
      groundPaint, // Цвет земли
    );


    Paint horizonPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(-radius, 0 + verticalOffset),
      Offset(radius, 0 + verticalOffset),
      horizonPaint,
    );

    // Рисуем черную границу для всего внутреннего круга
    Paint borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(Offset(0, 0), radius, borderPaint);

    // Рисуем шкалу тангажа (pitch)
    _drawPitchScale(canvas, 0, 0, radius, verticalOffset);
    canvas.restore();


    // Оранжевая точка и треугольник остаются на месте
    _drawRollPointer(canvas, centerX, centerY, radius);
    _drawOrangeTriangle(canvas, centerX, centerY, radius);
  }

  void _drawPitchScale(Canvas canvas, double centerX, double centerY, double radius, double verticalOffset) {
    Paint scalePaint = Paint()
      ..color = Colors.white;

    List<double> linePositions = [-90.0, -67.5, -45.0, -22.5, 0.0, 22.5, 45.0, 67.5, 90.0];

    List<int> textValues = [-60, -30, 30,  60];

    int textIndex = 0;

    for (int i = 0; i < linePositions.length; i++) {
      double scaleY = (linePositions[i] / 90.0) * radius * 0.7;
      double lineWidth = (i % 2 == 0) ? 20.0 : 10.0;

      scalePaint.strokeWidth = 1;

      canvas.save();
      canvas.translate(centerX, centerY + verticalOffset);

      Offset start = Offset(-lineWidth, -scaleY);
      Offset end = Offset(lineWidth, -scaleY);

      canvas.drawLine(start, end, scalePaint);

      if (linePositions[i] != 0 && i % 2 == 0) {
        TextPainter textPainter = TextPainter(
          text: TextSpan(
            text: '${textValues[textIndex++]}',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(start.dx - 25, -scaleY - 6));
        textPainter.paint(canvas, Offset(end.dx + 5, -scaleY - 6));
      }

      canvas.restore();
    }
  }


  void _drawRollPointer(Canvas canvas, double centerX, double centerY, double radius) {
    Paint borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    double dotRadius = 3;
    double borderRadius = dotRadius + 1;
    canvas.drawCircle(Offset(centerX, centerY), borderRadius, borderPaint);

    Paint orangeDotPaint = Paint()..color = Colors.orange;

    canvas.drawCircle(Offset(centerX, centerY), dotRadius, orangeDotPaint);
  }

  void _drawOrangeTriangle(Canvas canvas, double centerX, double centerY, double radius) {
    Paint trianglePaint = Paint()..color = Colors.orange;

    Path trianglePath = Path();

    double topX = centerX;
    double topY = centerY - radius * 0.9;

    double leftX = centerX - radius * 0.1;
    double rightX = centerX + radius * 0.1;
    double bottomY = centerY - radius * 0.8;

    trianglePath.moveTo(topX, topY);
    trianglePath.lineTo(leftX, bottomY);
    trianglePath.lineTo(rightX, bottomY);
    trianglePath.close();

    canvas.drawPath(trianglePath, trianglePaint);
  }

  @override
  bool shouldRepaint(AttitudeIndicatorPainter oldDelegate) {
    return oldDelegate.pitch != pitch || oldDelegate.roll != roll;
  }
}
