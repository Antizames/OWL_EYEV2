import 'package:flutter/material.dart';
class MyCustomSlider extends StatefulWidget {
  final double sliderValue;
  final Function(double) onValueChanged; // Добавление callback-функции

  const MyCustomSlider({
    Key? key,
    required this.sliderValue,
    required this.onValueChanged,
  }) : super(key: key);

  @override
  _MyCustomSliderState createState() => _MyCustomSliderState();
}

class _MyCustomSliderState extends State<MyCustomSlider> {
  late double localSliderValue;

  @override
  void initState() {
    super.initState();
    localSliderValue = widget.sliderValue;
  }
  @override
  void didUpdateWidget(MyCustomSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Проверяем, изменилось ли входящее значение
    if (oldWidget.sliderValue != widget.sliderValue) {
      setState(() {
        // Обновляем локальное значение, если входящее значение изменилось
        localSliderValue = widget.sliderValue;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    // Определение градиента для активной части слайдера
    final LinearGradient activeGradient = LinearGradient(
      colors: [Color.fromARGB(255, 255, 115, 8), Color.fromARGB(255, 252, 128, 33)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    // Определение градиента для неактивной части слайдера
    final LinearGradient inactiveGradient = LinearGradient(
        colors: [Color.fromARGB(255, 22, 25, 28),Color.fromARGB(255, 22, 24, 26),Color.fromARGB(255, 22, 24, 26), Color.fromARGB(255, 65, 68, 71)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter
    );

    return Center(
      child: SliderTheme(
        data: SliderThemeData(
          // кастомизация бегунка
          thumbShape: _CustomThumbShape(),
          // кастомизация активной части полосы
          activeTrackColor: Colors.transparent,
          inactiveTrackColor: Colors.transparent,
          trackHeight: 8.0,
          overlayColor: Colors.orange.withAlpha(32), // цвет вокруг бегунка при нажатии
          overlayShape: RoundSliderOverlayShape(overlayRadius: 28.0), // форма и размер этого вокруг бегунка
          trackShape: _CustomTrackShape(activeGradient, inactiveGradient), // кастомизация формы и градиента полосы
        ),
        child: Slider(
          min: 0,
          max: 360,
          divisions: 72,
          value: localSliderValue,
          onChanged: (value) {
            setState(() {
              localSliderValue = value;
            });
            widget.onValueChanged(value); // Вызов callback-функции с новым значением
          },
        ),
      ),
    );
  }
}

class _CustomThumbShape extends SliderComponentShape {
  // Размеры бегунка
  final double thumbRadius = 16.0;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size(thumbRadius * 2, thumbRadius * 2);
  }

  @override
  void paint(
      PaintingContext context,
      Offset center, {
        required Animation<double> activationAnimation,
        required Animation<double> enableAnimation,
        required bool isDiscrete,
        required TextPainter labelPainter,
        required RenderBox parentBox,
        required SliderThemeData sliderTheme,
        required TextDirection textDirection,
        required double value,
        required double textScaleFactor,
        required Size sizeWithOverflow,
      }) {
    final Canvas canvas = context.canvas;

    final Paint shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.6); // Устанавливаем цвет тени и степень ее прозрачности
    final double elevation = 2.0; // Высота тени от элемента
    final Path shadowPath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: thumbRadius + elevation));
    canvas.drawShadow(shadowPath, shadowPaint.color, elevation, true);

    // Градиент для бегунка
    final Paint thumbPaint = Paint()
      ..shader = LinearGradient(
          colors: [Color.fromARGB(255, 233, 237, 245), Color.fromARGB(255, 149, 152, 158,)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight
      ).createShader(Rect.fromCircle(center: center, radius: thumbRadius));

    final Path thumbPath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: thumbRadius));
    canvas.drawPath(thumbPath, thumbPaint);


    canvas.drawPath(thumbPath, thumbPaint);

    // Рисуем синий кружок в середине
    final double blueCircleRadius = thumbRadius / 5; // Допустим, размер синего кружка в 2 раза меньше
    final Paint blueCirclePaint = Paint()
      ..color = Colors.orange; // Цвет синего кружка

    final Path blueCirclePath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: blueCircleRadius));

    canvas.drawPath(blueCirclePath, blueCirclePaint);
  }
}

class _CustomTrackShape extends SliderTrackShape {
  final LinearGradient activeGradient;
  final LinearGradient inactiveGradient;

  _CustomTrackShape(this.activeGradient, this.inactiveGradient);

  @override
  void paint(
      PaintingContext context,
      Offset offset, {
        required RenderBox parentBox,
        required SliderThemeData sliderTheme,
        required Animation<double> enableAnimation,
        required Offset thumbCenter,
        bool isDiscrete = false,
        bool isEnabled = false,
        Offset? secondaryOffset,
        required TextDirection textDirection,
      }) {
    final double trackHeight = sliderTheme.trackHeight ?? 4.0;
    final double trackWidth = parentBox.size.width;
    final double trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double activeTrackStart = offset.dx;
    final double activeTrackEnd = thumbCenter.dx;
    final double inactiveTrackStart = activeTrackEnd;
    final double inactiveTrackEnd = trackWidth + offset.dx;
    final Radius radius = Radius.circular(trackHeight / 2); // Для скругления используется радиус, равный половине высоты трека

    final Paint activePaint = Paint()..shader = activeGradient.createShader(Rect.fromLTRB(activeTrackStart, trackTop, activeTrackEnd, trackTop + trackHeight));
    final Paint inactivePaint = Paint()..shader = inactiveGradient.createShader(Rect.fromLTRB(inactiveTrackStart, trackTop, inactiveTrackEnd, trackTop + trackHeight));

    if (activeTrackEnd > activeTrackStart) {
      context.canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTRB(activeTrackStart, trackTop, activeTrackEnd, trackTop + trackHeight), radius),
          activePaint);
    }

    context.canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTRB(inactiveTrackStart, trackTop, inactiveTrackEnd, trackTop + trackHeight), radius),
        inactivePaint);
  }

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight ?? 4.0;
    final double trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    return Rect.fromLTWH(offset.dx, trackTop, parentBox.size.width, trackHeight);
  }
}