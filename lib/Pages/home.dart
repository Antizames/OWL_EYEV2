import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:usb_serial/usb_serial.dart';
class Setup extends StatefulWidget {
  @override
  State<Setup> createState() => _SetupState();
}

class _SetupState extends State<Setup> {
  final MapController mapController = MapController();
  List<LatLng> points = [];
  void _handleTap(LatLng latlng) {
    setState(() {
      points.add(latlng);
    });
  }
  void _handleLongPress() {
      draggableScrollableController.animateTo(
        0.1, // Минимальный размер. Укажите нужное значение.
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
  }
  var polylines;
  Timer? _timer;
  int _currentPointIndex = 0; // Индекс стартовой точки
  double progress = 0;
  LatLng? animatedMarkerPoint; // Текущая позиция маркера
  final DraggableScrollableController draggableScrollableController = DraggableScrollableController();
  final double initialChildSize = 0.3; // Исходный размер DraggableScrollableSheet
  bool isPressedDown = false; // Флаг для отслеживания перетаскивания
  Duration delayDuration = Duration(milliseconds: 30); // Задержка перед скрытием меню
  Future<void> sendMSPMessage(List<int> mspMessage) async {
    List<UsbDevice> devices = await UsbSerial.listDevices();
    print("${devices.length} USB devices found");

    if (devices.isNotEmpty) {
      UsbDevice device = devices.first;

      UsbPort? port = await device.create();
      if(port == null) {
        print("Не удалось открыть порт");
        return;
      }
      bool openResult = await port.open();
      if (!openResult) {
        print("Не удалось открыть соединение");
        return;
      }
      port.setDTR(true);
      port.setRTS(true);

      port.setPortParameters(57600, UsbPort.DATABITS_8, UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);
      port.write(Uint8List.fromList(mspMessage));
      await Future.delayed(Duration(milliseconds: 500)); // Ждем, пока данные передадутся

      // Закрываем соединение
      await port.close();
      print("Соединение закрыто");
    } else {
      print("USB устройства не найдены");
    }
  }
  // Метод для запуска анимации
  void _animateObject() {
    if (points.isEmpty || points.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Добавьте хотя бы две точки для полётного задания")),
      );
      return;
    }
    for(int i = 0; i < points.length; i++){
      sendMSPMessage(buildMSP(points[i], 201));
    }
    animatedMarkerPoint = points.first;

    final int totalPoints = points.length;
    _currentPointIndex = 0; // Сбросить индекс
    progress = 0.0; // Сбросить прогресс

    _timer?.cancel(); // Отменяем предыдущий таймер, если он был
    _timer = Timer.periodic(Duration(milliseconds: 100), (Timer _timer) {
      setState(() {
        progress += 0.05;
        if (progress >= 1) {
          progress = 0.0;
          _currentPointIndex++;
          if (_currentPointIndex >= totalPoints - 1) {
            _currentPointIndex = 0; // Возвращаемся к началу, если это конец маршрута
            _timer.cancel(); // Останавливаем таймер
          }
        }
        final start = points[_currentPointIndex];
        final end = points[(_currentPointIndex + 1) % totalPoints];
        animatedMarkerPoint = LatLng(
          start.latitude + (end.latitude - start.latitude) * progress,
          start.longitude + (end.longitude - start.longitude) * progress,
        );
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Убедимся, что таймер отменен при удалении виджета
    super.dispose();
  }


  void _resetMarkers() {
    setState(() {
      points.clear();
    });
  }
  List<LatLng> generateSpiralPoints(List<LatLng> polygonPoints) {
    List<LatLng> spiralPoints = [];

    if (polygonPoints.isEmpty) {
      return spiralPoints;
    }

    double cx = 0, cy = 0;
    for (LatLng point in polygonPoints) {
      cx += point.latitude;
      cy += point.longitude;
    }
    cx /= polygonPoints.length;
    cy /= polygonPoints.length;

    double maxRadius = 0;
    for (LatLng point in polygonPoints) {
      double distance = sqrt(pow(point.latitude - cx, 2) + pow(point.longitude - cy, 2));
      if (distance > maxRadius) {
        maxRadius = distance;
      }
    }

    LatLng startPoint = polygonPoints.first;
    double startRadius = sqrt(pow(startPoint.latitude - cx, 2) + pow(startPoint.longitude - cy, 2));
    double deltaRadius = maxRadius/70; // Decrease/increase to control the tightness of the spiral
    double deltaAngle = 12*pi / 36; // Change to adjust the angle step
    int numPoints = 50; // Total number of points in the spiral
    double angle = acos(startPoint.longitude-cy);
    double newLatitude = cx;
    double newLongitude = cy;
    double radius = 0;
    for (int i = 0; i < numPoints; i++) {
      spiralPoints.add(LatLng(newLatitude, newLongitude));
      double px = newLatitude;
      double py = newLongitude;
      radius += deltaRadius;
      angle -= deltaAngle;
      newLatitude = px + 1.5*radius * sin(angle)*0.6;
      newLongitude = py + 1.5*radius * cos(angle);
      deltaRadius *= 1.005;
    }

    return spiralPoints;
  }
  List<int> buildMSP(LatLng coordinates, command) {

    // Преобразование широты и долготы в бинарный формат
    int lat = (coordinates.latitude * 10000).round();
    int lon = (coordinates.longitude * 10000).round();

    // Создаем буфер данных
    var dataBytes = ByteData(8);
    dataBytes.setInt32(0, lat, Endian.little); // 4 байта для широты
    dataBytes.setInt32(4, lon, Endian.little); // 4 байта для долготы

    int dataSize = 8;
    int checksum = 0;

    List<int> message = [0x24, 0x4D, 0x3C, dataSize, command];
    checksum ^= dataSize;
    checksum ^= command;

    // Добавляем данные и вычисляем контрольную сумму
    for (int i = 0; i < dataSize; i++) {
      message.add(dataBytes.getUint8(i));
      checksum ^= dataBytes.getUint8(i);
    }

    message.add(checksum);
    return message;
  }
  List<LatLng> generateZigZagPath(List<LatLng> polygonPoints, double spacing) {

    List<LatLng> pathPoints = [];

    if (polygonPoints.length != 4) {
      return pathPoints;
    }

    // Определение минимальной и максимальной широты и долготы
    double minLat = polygonPoints.map((p) => p.latitude).reduce(min);
    double maxLat = polygonPoints.map((p) => p.latitude).reduce(max);
    double minLon = polygonPoints.map((p) => p.longitude).reduce(min);
    double maxLon = polygonPoints.map((p) => p.longitude).reduce(max);

    // Генерация точек зигзага
    bool direction = true; // true для движения вверх, false для движения вниз
    for (double lon = minLon; lon <= maxLon; lon += spacing) {
      if (direction) {
        pathPoints.add(LatLng(minLat, lon));
        pathPoints.add(LatLng(maxLat, lon));
      } else {
        pathPoints.add(LatLng(maxLat, lon));
        pathPoints.add(LatLng(minLat, lon));
      }
      direction = !direction; // Смена направления
    }

    return pathPoints;
  }


// Helper function to calculate the cross product of vectors (p1-p0) x (p2-p0)
  double isLeft(LatLng p0, LatLng p1, LatLng p2) {
    return (p1.latitude - p0.latitude) * (p2.longitude - p0.longitude) - (p2.latitude - p0.latitude) * (p1.longitude - p0.longitude);
  }
  List<Polyline> _buildPolylines() {
    var polylineList = <Polyline>[];
    if (points.length > 1) {
      polylineList.add(
        Polyline(
          points: [...points, points.first],
          strokeWidth: 2.0,
          isDotted: true,
          color: Colors.deepPurple,
        ),
      );
    }
    return polylineList;
  }
  List<Marker> _buildMarkers() {
    return points.asMap().entries.map((entry) {
      int idx = entry.key;
      LatLng latlng = entry.value;
      return Marker(
        width: 80,
        height: 80,
        point: latlng,
        builder: (ctx) => Container(
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(10),
                padding: EdgeInsets.all(10),
                child: Icon(
                  Icons.location_on,
                  color: Colors.deepPurple,
                  size: 20,
                ),
              ),
              Positioned(
                bottom: -5,
                child: Text(
                    '${idx + 1}', // Номер маркера
                    style: GoogleFonts.raleway(
                        textStyle: TextStyle(
                            fontSize: 20,
                            color: Colors.black
                        )
                    )
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
  void _openMenu(){
    Navigator.of(context).push(
        MaterialPageRoute(builder: (BuildContext context){
          return Drawer(
              child: new ListView(
                children: <Widget>[
                  ListTile(
                    title: const Text('Навигация',style: TextStyle(fontSize: 26),),
                    onTap: () {Navigator.pushReplacementNamed(context, '/');},
                  ),
                  ListTile(title: const Text('Конфигурация',style: TextStyle(fontSize: 26),),onTap: () {Navigator.pushReplacementNamed(context, '/3d');}),
                  Divider(color: Colors.black87),
                  ListTile(title: const Text('Сообщить об ошибке',style: TextStyle(fontSize: 26),),onTap: () {}),
                ],));
        })
    );
  }
  @override
  Widget build(BuildContext context) {
    polylines = _buildPolylines();
    var markers = _buildMarkers();
    if (animatedMarkerPoint != null) {
      markers.add(
        Marker(
          width: 80.0,
          height: 80.0,
          point: animatedMarkerPoint!,
          builder: (ctx) => Icon(Icons.airplanemode_active, size: 32.0, color: Colors.deepOrange),
        ),
      );
    }
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Listener(
            onPointerDown: (details) {
              isPressedDown = true;
              Future.delayed(delayDuration).then((_) {
                if (isPressedDown) { // Если пользователь все еще удерживает нажатие
                  draggableScrollableController.animateTo(
                    0.01, // Минимизируем размер DraggableScrollableSheet
                    duration: Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                }
              });
            },
            onPointerUp: (details) {
              isPressedDown = false; // Сброс флага при отпускании
              draggableScrollableController.animateTo(
                initialChildSize, // Возвращаем DraggableSheet к исходному размеру
                duration: Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            },
            child: FlutterMap(
              mapController: mapController,
              options: MapOptions(
                center: LatLng(55.8, 37.43),
                zoom: 15.0,
                onTap: (_, latlng) => _handleTap(latlng)
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                ),
                PolylineLayer(
                  polylines: polylines,
                ),
                MarkerLayer(
                  markers: markers,
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: 640, // Обратите внимание на ширину и высоту вашего контейнера
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromARGB(255, 52, 57, 63),
                    Color.fromARGB(255, 52, 57, 63).withOpacity(0.8),
                    Color.fromARGB(255, 52, 57, 63).withOpacity(0.7),
                    Color.fromARGB(255, 52, 57, 63).withOpacity(0.55),
                    Color.fromARGB(255, 52, 57, 63).withOpacity(0.4),
                    Color.fromARGB(255, 52, 57, 63).withOpacity(0.25),
                    Color.fromARGB(255, 52, 57, 63).withOpacity(0.1),
                    Color.fromARGB(255, 52, 57, 63).withOpacity(0.05),
                    Colors.transparent,
                  ],
                  stops: [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.7, 0.8, 1],
                ),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: 56, // Ширина и высота FloatingActionButton
                  height: 56,
                  child: FloatingActionButton(
                    onPressed: () {_openMenu();},
                    child: Icon(Icons.menu),
                    backgroundColor: Colors.transparent, // Прозрачный фон
                    elevation: 0, // Убрать тень
                    splashColor: Colors.transparent, // Прозрачный цвет всплеска
                  ),
                ),
              ),
            ),
          ),
          DraggableScrollableSheet(
            controller: draggableScrollableController,
            initialChildSize: 0.3,
            minChildSize: 0.01,
            maxChildSize: 0.3,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Color.fromARGB(255, 52, 57, 63), Color.fromARGB(255, 22, 23, 27,)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter)
                ),
                child: GridView.count(
                  controller: scrollController,
                  scrollDirection: Axis.vertical,
                  crossAxisCount: 1,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                  childAspectRatio: (400/60),
                  children: <Widget>[
                    GradientBorderButton(text: 'Полёт по периметру',
                        buttonColors: <Color>[Color.fromARGB(255, 46, 51, 56), Color.fromARGB(255, 30, 33, 36,)],
                        borderColors: <Color>[Color.fromARGB(255, 8, 231, 53), Color.fromARGB(255, 93, 249,140), Color.fromARGB(255,169, 255, 112)],
                        onPressed: _animateObject,
                        width: 150,
                        height: 60,
                    toolTip: false,),
                    GradientBorderButton(text: 'Сбросить маркеры',
                      buttonColors: <Color>[Color.fromARGB(255, 46, 51, 56), Color.fromARGB(255, 30, 33, 36,)],
                      borderColors: <Color>[Color.fromARGB(255, 251, 14, 14), Color.fromARGB(255, 249, 93, 93,), Color.fromARGB(255, 227, 2, 2)],
                      onPressed: _resetMarkers,
                      width: 150,
                      height: 60,
                      toolTip: false,),
                    GradientBorderButton(text: 'Спиральная траектория',
                      buttonColors: <Color>[Color.fromARGB(255, 46, 51, 56), Color.fromARGB(255, 30, 33, 36,)],
                      borderColors: <Color>[Color.fromARGB(255, 2, 96, 164), Color.fromARGB(255, 25, 160, 236)],
                      onPressed: () {
                        if (points.length < 3) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Отметьте от 3 маркеров на карте для отображения выбранной территории")),
                          );
                        } else {
                          List<LatLng> spiralPoints = generateSpiralPoints(points);

                          setState(() {
                            _resetMarkers();
                            points.addAll(spiralPoints);
                          });
                        }
                      },
                      width: 150,
                      height: 60,
                      toolTip: false,)
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
class GradientBorderButton extends StatefulWidget {
  final String text;
  final List<Color> buttonColors;
  final List<Color> borderColors;
  final String tooltipMessage;
  final VoidCallback onPressed;
  final bool toolTip;
  final double width; // Убираем необязательность этих параметров
  final double height;

  const GradientBorderButton({
    Key? key,
    required this.text,
    required this.buttonColors,
    required this.borderColors,
    this.tooltipMessage = '',
    required this.onPressed,
    this.toolTip = true,
    required this.width, // Теперь параметры обязательны
    required this.height,
  }) : super(key: key);

  @override
  State<GradientBorderButton> createState() => _GradientBorderButtonState();
}

class _GradientBorderButtonState extends State<GradientBorderButton> {
  @override
  Widget build(BuildContext context) {
    return SizedBox( // Используем SizedBox для задания фиксированного размера
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
        padding: EdgeInsets.all(2),
        margin: const EdgeInsets.all(4),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onPressed,
            onLongPress: widget.toolTip ? () {
              final overlay = Overlay.of(context);
              final renderBox = context.findRenderObject() as RenderBox;
              final size = renderBox.size;
              final offset = renderBox.localToGlobal(Offset.zero);

              OverlayEntry? entry;
              entry = OverlayEntry(
                builder: (context) => Positioned(
                  left: offset.dx,
                  top: offset.dy - size.height / 2,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Text(widget.tooltipMessage, style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
              );
              overlay.insert(entry);
              Future.delayed(Duration(seconds: 2), () => entry?.remove());
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
              child: Center(child: Text(widget.text, style: TextStyle(fontSize: 14, color: Colors.white))),
            ),
          ),
        ),
      ),
    );
  }
}

