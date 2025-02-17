import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:usb_serial/usb_serial.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:owl/pages/navigation/widgets/gradientBorderButton.dart';
import 'package:owl/pages/navigation/widgets/gradientBorderButtonHelp.dart';
import 'package:owl/pages/navigation/widgets/hintDialog.dart';
import 'package:owl/pages/appBar/widgets/customAppBar.dart';
class Navigation extends StatefulWidget {
  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  final MapController mapController = MapController();
  List<LatLng> points = [];
  void _handleTap(LatLng latlng) {
    if (_isMoveMarkerMode) {
      setState(() {
        points[index] = latlng; // Обновите координаты маркера
      });
    } else {
      setState(() {
        points.add(latlng);
      });
    }

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
  var droneSpeedkm = 100000; // задаем текущую скорость дрона

  // Метод для запуска анимации
  void _animateObject() {
    var droneSpeed = droneSpeedkm * 1/38880000;

    if (points.isEmpty || points.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Добавьте хотя бы две точки для полётного задания")),
      );
      return;
    }

    final totalPoints = points.length;

    _currentPointIndex = 0;
    progress = 0.0;

    _timer?.cancel();
    _timer = Timer.periodic(Duration(milliseconds: 10), (timer) {
      setState(() {
        final start = points[_currentPointIndex];
        final end = points[(_currentPointIndex + 1) % totalPoints];
        final distance = sqrt(pow(end.latitude - start.latitude, 2) + pow(end.longitude - start.longitude, 2));

        final step = droneSpeed / distance;
        progress += step;

        if (progress >= 1) {
          progress = 0.0;
          _currentPointIndex++;


          animatedMarkerPoint = LatLng(
              end.latitude, end.longitude
          );
        } else {
          animatedMarkerPoint = LatLng(
            start.latitude + (end.latitude - start.latitude) * progress,
            start.longitude + (end.longitude - start.longitude) * progress,
          );
        }
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
      animatedMarkerPoint = null;
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
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(13), // Применяем скругление к Material
        bottomRight: Radius.circular(13),
      ),
      child: Material(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height, // на всю высоту
          color: Colors.white, // Цвет фона контейнера
          child: Column(
            children: [
              const Padding(padding: EdgeInsets.all(10)),
              ListTile(
                leading: const Icon(Icons.navigation),
                title: const Text('Навигация'),
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/');
                },
              ),
              ListTile(
                leading: Icon(FontAwesomeIcons.microchip),
                title: Text('Конфигурация'),
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/conf');
                },
              ),
              ListTile(
                leading: Icon(FontAwesomeIcons.phoenixSquadron),
                title: Text('Дрон'),
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/mod');
                },
              ),
              ListTile(
                leading: Icon(Icons.battery_charging_full),
                title: Text('Питание и Батарея'),
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/bat');
                },
              ),
              ListTile(
                leading: Icon(Icons.cable),
                title: Text('Порты'),
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/port');
                },
              ),
              ListTile(
                leading: Icon(FontAwesomeIcons.gears),
                title: Text('Сервоприводы'),
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/ser');
                },
              ),
              ListTile(
                leading: Icon(FontAwesomeIcons.fan),
                title: Text('Моторы'),
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/mot');
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
                                  Colors.transparent, Colors.transparent
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
          builder: (ctx) => SvgPicture.asset('Assets/Images/D1Dron4i.svg'),
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
              if(!_isMoveMarkerMode) {
                isPressedDown = false; // Сброс флага при отпускании
                draggableScrollableController.animateTo(
                  initialChildSize,
                  // Возвращаем DraggableSheet к исходному размеру
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              }
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
              width: MediaQuery.of(context).size.width,
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [SizedBox(
                  height: 56,
                  child: FloatingActionButton(
                    onPressed: () {_openSidebarMenu(context);},
                    child: Icon(Icons.menu),
                    backgroundColor: Colors.transparent, // Прозрачный фон
                    elevation: 0, // Убрать тень
                    splashColor: Colors.transparent, // Прозрачный цвет всплеска
                  ),
                ),
                  HintDialog(),]
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
                        colors: [Colors.white, Color.fromARGB(255, 190, 191, 194,)],
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
                                              Colors.transparent, Colors.transparent
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
                                                          Flexible(
                                                            flex: 2,
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
                                iconRight: SvgPicture.asset('Assets/Images/trash.svg'),
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
                                iconRight: SvgPicture.asset('Assets/Images/polet.svg'),
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
                                iconRight: SvgPicture.asset('Assets/Images/spirali.svg'),
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




