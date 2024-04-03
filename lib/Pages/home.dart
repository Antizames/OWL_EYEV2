import 'dart:convert';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:usb_serial/usb_serial.dart';
import 'package:flutter/services.dart';
class Setup extends StatefulWidget {
  @override
  State<Setup> createState() => _SetupState();
}

class _SetupState extends State<Setup> {
  final MapController mapController = MapController();
  List<LatLng> points = [];
  void _handleTap(LatLng latlng) {
    if (_isMoveMarkerMode) {
      // Перемещение выбранного маркера к новому местоположению
      // Здесь вам необходимо знать, какой маркер пользователь хочет переместить.
      // Можете использовать переменную, например, selectedMarkerIndex, чтобы отслеживать это.
      setState(() {
        points[index] = latlng; // Обновите координаты маркера
      });
    } else {
      setState(() {
        points.add(latlng);
      });
    }

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
  final double initialChildSize = 0.33; // Исходный размер DraggableScrollableSheet
  bool isPressedDown = false; // Флаг для отслеживания перетаскивания
  Duration delayDuration = Duration(milliseconds: 45); // Задержка перед скрытием меню
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
    lataddController.dispose();
    lonaddController.dispose();
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

int index = -1;
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
          color: Colors.orange.shade800,
        ),
      );
    }
    return polylineList;
  }
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Marker> _buildMarkers() {
    return points.asMap().entries.map((entry) {
      int idx = entry.key;
      LatLng latlng = entry.value;
      return Marker(
        width: 300,
        height: 100,
        point: latlng,
        builder: (ctx) => GestureDetector(
        onLongPress: () {
          _openCenteredMenu(context, idx);
        },
        child: Container(
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Icon(
                Icons.sports_baseball,
                size: 20,
                color: Colors.orange.shade800,
              ),
              Icon(
                Icons.location_on,
                size: 31,
                color: Colors.black,
              ),
              // Обводка для внутреннего кружка (средний размер)
              Icon(
                Icons.location_on,
                size: 26, // Средний размер между внешней границей и внутренней заливкой
                color: Colors.white, // Сделайте ее полупрозрачной, чтобы создать эффект обводки
              ),
              // Текст

              if (_isMoveMarkerMode && index == idx) // Проверяем, активен ли режим перемещения и текущий маркер выбран
                Positioned(
                  bottom: 10, // Расстояние под маркером
                  child: Container(
                    width: 50,
                    height: 20,
                    decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(5)
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              _isMoveMarkerMode = false; // Выход из режима перемещения
                              index = -1; // Сброс выбранного индекса
                              // Сохранение измененного положения маркера уже выполнено через _handleTap
                            });
                          },
                          child: Icon(Icons.check, size: 20, color: Colors.black,),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              _isMoveMarkerMode = false;  // Выход из режима перемещения
                              points[index] = posWas; // Возвращает маркер в исходное положение
                              index = -1; // Сброс выбранного индекса
                            });
                          },
                          child: Icon(Icons.cancel_presentation, size: 20, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
              if (!_isMoveMarkerMode || index != idx)
                Positioned(
                  bottom: 0,
                  child: Text(
                    '${idx + 1}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
            ],
          ),
        ),
          ));
    }).toList();
  }
  void _openSidebarMenu(BuildContext context) {
    showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) => throw UnimplementedError(),
      barrierDismissible: false, // Сделаем нашу затемненную область действующей вручную
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.transparent, // Прозрачный цвет, т.к. обработка вручную
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero);
        final offsetAnimation = animation.drive(tween);

        return Stack(
          children: <Widget>[
            GestureDetector(
              // Затемненный фон за меню
              onTap: () => Navigator.pop(context), // Закрытие меню
              child: FadeTransition(
                opacity: animation,
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
            ),
            SlideTransition(
              position: offsetAnimation,
              child: _buildSidebarMenu(context),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSidebarMenu(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(13), // Применяем скругление к Material
        bottomRight: Radius.circular(13),
      ),
      child: Material(
        // Это обеспечивает правильные тему и отображение текста кнопок
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8, // ширина панели, например 80% от ширины экрана
          height: MediaQuery.of(context).size.height, // на всю высоту
          color: Colors.white, // Цвет фона контейнера
          child: Column(
            children: [
              Padding(padding: EdgeInsets.all(10)),
              ListTile(
                leading: Icon(Icons.navigation),
                title: Text('Навигация'),
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/');
                },
              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('Конфигурация'),
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/3d');
                },
              ),
              ListTile(
                leading: Icon(Icons.report_problem),
                title: Text('Сообщить об ошибке'),
                onTap: () {
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
  LatLng posWas = LatLng(55.312, 53.123);

// Переменные для сохранения введенных значений
  double latWas = 0;
  double lonWas = 0;
  void _openCenteredMenu(BuildContext context, int idx) {
    index = idx;
    posWas = points[index];
    showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) => throw UnimplementedError(),
      barrierDismissible: true, // Позволяем закрыть меню, тапнув вне его
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withOpacity(0.5), // Затемненный фон
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(parent: animation, curve: Curves.easeOut);
        return FadeTransition(
          opacity: curvedAnimation,
          child: Center(
            child: _buildCenteredMenu(context),
          ),
        );
      },
    );
  }
  TextEditingController lataddController = TextEditingController();
  TextEditingController lonaddController = TextEditingController();
  Widget _buildCenteredMenu(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    LatLng currentPoint = LatLng(0, 0);
    return ClipRRect(

        borderRadius: BorderRadius.circular(20), child: Material( // Используем Material для соблюдения стилей элементов управления
      elevation: 10.0, // Добавим тень
      borderRadius: BorderRadius.circular(20), // Скругленные углы
      child: Container(
        width: screenWidth * 0.9, // например, ширина - 70% от ширины экрана
        height: screenHeight * 0.3, // и высота - 70% от высоты экрана
        color: Colors.white,
        padding: EdgeInsets.all(10),
        child: Column( // Пример внутреннего содержимого
          children: [
            ListTile(
              leading: Icon(Icons.open_with),
              title: Text('Переместить маркер'),
              onTap: () {
                Navigator.of(context).pop();
                // Активация режима перемещения
                setState(() {
                  _isMoveMarkerMode = true;
                });
              },
            ),
            Divider(color: Colors.black12,),
            ListTile(
              leading: Icon(Icons.navigation),
              title: Text('Изменить координаты'),
              onTap: () {
                TextEditingController latController = TextEditingController(text: '${points[index].latitude.toStringAsFixed(6)}');
                TextEditingController lonController = TextEditingController(text: '${points[index].longitude.toStringAsFixed(6)}');
                Navigator.of(context).pop();
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    // Объявляем контроллеры для ввода текста

                    // Возвращаем кастомное диалоговое окно
                    return Dialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                      alignment: Alignment.center,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Material(
                          elevation: 10.0,
                          child: Container(
                            width: MediaQuery.of(context).size.width * 1.5,
                            height: MediaQuery.of(context).size.height * 0.27,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white70, Colors.orange
                                ],
                              ),
                            ),
                            padding: EdgeInsets.all(4),
                            child: ClipRRect( // Обрезает внутренний контент по радиусу
                              borderRadius: BorderRadius.circular(15.0), // Согласование радиуса с внешним контейнером
                                child: Container(
                                  color: Colors.white, // Фон внутреннего контента (мог бы быть и прозрачным, если нужно)
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            children: [
                                              Flexible(
                                                flex: 1,
                                                child: Padding(
                                                  padding: EdgeInsets.only(left: 10.0), // Отступ для текста
                                                  child: Text('Широта', style: TextStyle(color: Colors.black, fontSize: 16)),
                                                ),
                                              ),
                                              Flexible(
                                                flex: 2,
                                                child: Padding(
                                                  padding: EdgeInsets.all(5.0),
                                                  child: TextField(
                                                    controller: latController,
                                                    style: TextStyle(color: Colors.white),
                                                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                                                    inputFormatters: [
                                                      FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d{0,6}')),
                                                      TextInputFormatter.withFunction((oldValue, newValue) {
                                                        if (newValue.text.isEmpty) {
                                                          return newValue;
                                                        }
                                                        final numValue = num.tryParse(newValue.text);
                                                        return (numValue != null && numValue >= -90 && numValue <= 90) ? newValue : oldValue;
                                                      }),
                                                    ],
                                                    decoration: InputDecoration(
                                                      fillColor: Colors.black,
                                                      filled: true,
                                                      hintText: "Введите значение широты",
                                                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                                                      border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(10.0),
                                                        borderSide: BorderSide.none,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            children: [
                                              Flexible( // Изменили Expanded на Flexible для текста
                                                flex: 1, // Задали flex для управления размером
                                                child: Padding(
                                                  padding: EdgeInsets.only(left: 10.0), // Отступ для текста
                                                  child: Text('Долгота', style: TextStyle(color: Colors.black, fontSize: 16)),
                                                ),
                                              ),
                                              Flexible( // Изменили Expanded на Flexible для текстового поля
                                                flex: 2, // Задали flex в два раза больше, чем у текста, для управления размером
                                                child: Padding(
                                                  padding: EdgeInsets.all(5.0),
                                                  child: TextField(
                                                    controller: lonController,
                                                    style: TextStyle(color: Colors.white),
                                                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                                                    inputFormatters: [
                                                      FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d{0,6}')),
                                                      TextInputFormatter.withFunction((oldValue, newValue) {
                                                        if (newValue.text.isEmpty) {
                                                          return newValue;
                                                        }
                                                        final numValue = num.tryParse(newValue.text);
                                                        return (numValue != null && numValue >= -180 && numValue <= 180) ? newValue : oldValue;
                                                      }),
                                                    ],
                                                    decoration: InputDecoration(
                                                      fillColor: Colors.black,
                                                      filled: true,
                                                      hintText: "Введите значение долготы",
                                                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                                                      border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(10.0),
                                                        borderSide: BorderSide.none,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          // Кнопка сохранить
                                          TextButton(
                                            child: Text('Сохранить', style: TextStyle(color: Colors.orange, fontSize: 16, fontWeight: FontWeight.bold)),
                                            onPressed: () {
                                              // Пытаемся спарсить широту и долготу из контроллеров
                                              double? newLat = double.tryParse(latController.text);
                                              double? newLon = double.tryParse(lonController.text);

                                              // Проверяем, что оба значения успешно спарсены
                                              if (newLat != null && newLon != null) {
                                                // Обновляем значение точки в списке points
                                                // Здесь предполагается, что points это List<LatLng>
                                                setState(() {
                                                  points[index] = LatLng(newLat, newLon);
                                                });

                                              } else {
                                                // Ошибка парсинга, можно показать сообщение пользователю
                                                print("Введенные данные некорректны.");
                                              }

                                              // Закрываем текущее модальное окно/экран
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      )
                                    ],
                                  ),))
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            Divider(color: Colors.black12,),
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('Удалить маркер'),
              onTap: () {
                if(points!= null && points.length > index){
                  setState(() {
                    points.removeAt(index);
                    index = 0;
                  });

                  // Если нужно, обновляем состояние карты здесь

                }
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    ),
    );
  }
  bool _isMoveMarkerMode = false;
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
                    duration: Duration(milliseconds: 700),
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
              width: 640,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white,
                    Colors.white.withOpacity(0.8),
                    Colors.white.withOpacity(0.7),
                    Colors.white.withOpacity(0.55),
                    Colors.white.withOpacity(0.4),
                    Colors.white.withOpacity(0.25),
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.05),
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
                    onPressed: () {_openSidebarMenu(context);},
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
            initialChildSize: 0.33,
            minChildSize: 0.01,
            maxChildSize: 0.33,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), // Скругление верхнего левого угла
                  topRight: Radius.circular(20), // Скругление верхнего правого угла
                ),
                    gradient: LinearGradient(
                        colors: [Colors.white, Color.fromARGB(255, 22, 23, 27,)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter)
                ),
                child: CustomScrollView(
                  controller: scrollController,
                  slivers: <Widget>[
                    SliverPadding(
                      padding: EdgeInsets.only(top: 10.0),
                    sliver: SliverToBoxAdapter(
                      child:
                      GradientBorderButton(
                        icon: SvgPicture.asset('Assets/Images/halfD.svg'),
                        text: 'Добавить маркер',
                        buttonColors: [Colors.black, Colors.black],
                        borderColors: [Colors.white70, Color.fromARGB(255,252,128,33)],
                        onPressed: (){
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              // Объявляем контроллеры для ввода текста

                              // Возвращаем кастомное диалоговое окно
                              return Dialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                                alignment: Alignment.center,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Material(
                                    elevation: 10.0,
                                    child: Container(
                                        width: MediaQuery.of(context).size.width * 1.5,
                                        height: MediaQuery.of(context).size.height * 0.27,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.white70, Colors.orange
                                            ],
                                          ),
                                        ),
                                        padding: EdgeInsets.all(4),
                                        child: ClipRRect( // Обрезает внутренний контент по радиусу
                                            borderRadius: BorderRadius.circular(15.0), // Согласование радиуса с внешним контейнером
                                            child: Container(
                                              color: Colors.white, // Фон внутреннего контента (мог бы быть и прозрачным, если нужно)
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Column(
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                        children: [
                                                          Flexible(
                                                            flex: 1,
                                                            child: Padding(
                                                              padding: EdgeInsets.only(left: 10.0), // Отступ для текста
                                                              child: Text('Широта', style: TextStyle(color: Colors.black, fontSize: 16)),
                                                            ),
                                                          ),
                                                          Flexible(
                                                            flex: 2,
                                                            child: Padding(
                                                              padding: EdgeInsets.all(5.0),
                                                              child: TextField(
                                                                controller: lataddController,
                                                                style: TextStyle(color: Colors.white),
                                                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                                                                inputFormatters: [
                                                                  FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d{0,6}')),
                                                                  TextInputFormatter.withFunction((oldValue, newValue) {
                                                                    if (newValue.text.isEmpty) {
                                                                      return newValue;
                                                                    }
                                                                    final numValue = num.tryParse(newValue.text);
                                                                    return (numValue != null && numValue >= -90 && numValue <= 90) ? newValue : oldValue;
                                                                  }),
                                                                ],
                                                                decoration: InputDecoration(
                                                                  fillColor: Colors.black,
                                                                  filled: true,
                                                                  hintText: "Введите широту",
                                                                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                                                                  border: OutlineInputBorder(
                                                                    borderRadius: BorderRadius.circular(10.0),
                                                                    borderSide: BorderSide.none,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                        children: [
                                                          Flexible( // Изменили Expanded на Flexible для текста
                                                            flex: 1, // Задали flex для управления размером
                                                            child: Padding(
                                                              padding: EdgeInsets.only(left: 10.0), // Отступ для текста
                                                              child: Text('Долгота', style: TextStyle(color: Colors.black, fontSize: 16)),
                                                            ),
                                                          ),
                                                          Flexible( // Изменили Expanded на Flexible для текстового поля
                                                            flex: 2, // Задали flex в два раза больше, чем у текста, для управления размером
                                                            child: Padding(
                                                              padding: EdgeInsets.all(5.0),
                                                              child: TextField(
                                                                controller: lonaddController,
                                                                style: TextStyle(color: Colors.white),
                                                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                                                                inputFormatters: [
                                                                  FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d{0,6}')),
                                                                  TextInputFormatter.withFunction((oldValue, newValue) {
                                                                    if (newValue.text.isEmpty) {
                                                                      return newValue;
                                                                    }
                                                                    final numValue = num.tryParse(newValue.text);
                                                                    return (numValue != null && numValue >= -180 && numValue <= 180) ? newValue : oldValue;
                                                                  }),
                                                                ],
                                                                decoration: InputDecoration(
                                                                  fillColor: Colors.black,
                                                                  filled: true,
                                                                  hintText: "Введите долготу",
                                                                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                                                                  border: OutlineInputBorder(
                                                                    borderRadius: BorderRadius.circular(10.0),
                                                                    borderSide: BorderSide.none,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                    children: [
                                                      // Кнопка сохранить
                                                      TextButton(
                                                        child: Text('Сохранить', style: TextStyle(color: Colors.orange, fontSize: 16, fontWeight: FontWeight.bold)),
                                                        onPressed: () {
                                                          // Пытаемся спарсить широту и долготу из контроллеров
                                                          double? newLat = double.tryParse(lataddController.text);
                                                          double? newLon = double.tryParse(lonaddController.text);

                                                          // Проверяем, что оба значения успешно спарсены
                                                          if (newLat != null && newLon != null) {
                                                            // Обновляем значение точки в списке points
                                                            // Здесь предполагается, что points это List<LatLng>
                                                            setState(() {
                                                              points.add(LatLng(newLat, newLon));
                                                              lataddController.clear();
                                                              lonaddController.clear();
                                                            });

                                                          } else {
                                                            // Ошибка парсинга, можно показать сообщение пользователю
                                                            print("Введенные данные некорректны.");
                                                          }

                                                          // Закрываем текущее модальное окно/экран
                                                          Navigator.of(context).pop();
                                                        },
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              ),))
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        width: 450,
                        height: 95,
                        toolTip: false,
                      ),
                    ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.only(top: 10.0),
                      sliver: SliverToBoxAdapter(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: <Widget>[
                              GradientBorderButtonHelp(
                                iconLeft: SvgPicture.asset('Assets/Images/D1Dron4i.svg'),
                                iconRight: SvgPicture.asset('Assets/Images/P3rka.svg'),
                                text: 'Сбросить маркеры',
                                buttonColors: [Colors.black, Colors.black87, Colors.black54],
                                borderColors: [Colors.white70, Color.fromARGB(255,252,128,33),],
                                onPressed: _resetMarkers,
                                width: 250,
                                height: 130,
                                tooltipMessage: "Сброс всех маркеров",
                              ),
                              GradientBorderButtonHelp(
                                iconLeft: SvgPicture.asset('Assets/Images/D1Dron4i.svg'),
                                iconRight: SvgPicture.asset('Assets/Images/P3rka.svg'),
                                text: 'Полёт по периметру',
                                buttonColors: [Colors.black, Colors.black87, Colors.black54],
                                borderColors: [Colors.white70, Color.fromARGB(255,252,128,33),],
                                onPressed: _animateObject,
                                width: 250,
                                height: 130,
                                tooltipMessage: "Задаёт полёт БПЛА по периметру заданной территории",
                              ),

                              // Добавьте больше кнопок здесь
                              GradientBorderButtonHelp(
                                iconLeft: SvgPicture.asset('Assets/Images/D1Dron4i.svg'),
                                iconRight: SvgPicture.asset('Assets/Images/Sp1ralka.svg'),
                                text: 'Спиральная траектория',
                                buttonColors: [Colors.black, Colors.black87, Colors.black54],
                                borderColors: [Colors.white70, Color.fromARGB(255,252,128,33)],
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
                                width: 250,
                                height: 130,
                                toolTip: false,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
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
                          width: 50.0, // Задаем фиксированную ширину для контейнера
                          height: 50.0, // Задаем фиксированную высоту для контейнера
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
