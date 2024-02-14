import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:math';

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
  var polylines;
  Timer? _timer;
  int _currentPointIndex = 0; // Индекс стартовой точки
  double progress = 0;
  LatLng? animatedMarkerPoint; // Текущая позиция маркера

  // Метод для запуска анимации
  void _animateObject() {
    if (points.isEmpty || points.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Добавьте хотя бы две точки для полётного задания")),
      );
      return;
    }
    // Возможно, установка начального положения маркера:
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

    // Calculate the centroid of the polygon
    double cx = 0, cy = 0;
    for (LatLng point in polygonPoints) {
      cx += point.latitude;
      cy += point.longitude;
    }
    cx /= polygonPoints.length;
    cy /= polygonPoints.length;

    // Determine the maximum distance from the centroid to any vertex to calculate the spiral bounds
    double maxRadius = 0;
    for (LatLng point in polygonPoints) {
      double distance = sqrt(pow(point.latitude - cx, 2) + pow(point.longitude - cy, 2));
      if (distance > maxRadius) {
        maxRadius = distance;
      }
    }

    // Configuration for the spiral
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
      newLatitude = px + radius * sin(angle)*0.6;
      newLongitude = py + radius * cos(angle);
      deltaRadius *= 1.003;
    }

    return spiralPoints;
  }
  List<LatLng> generateZigZagPath(List<LatLng> polygonPoints, double spacing) {
    // В данном примере предполагается, что polygonPoints образуют прямоугольник
    // и передаются в следующем порядке: левый нижний, правый нижний, правый верхний, левый верхний

    List<LatLng> pathPoints = [];

    if (polygonPoints.length != 4) {
      // Обработка ошибок или другой код для не прямоугольных полигонов
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
                  ListTile(title: const Text('Конфигурация',style: TextStyle(fontSize: 26),),onTap: () {Navigator.pushReplacementNamed(context, '/conf');}),
                  ListTile(title: const Text('Отказобезопасность',style: TextStyle(fontSize: 26),),onTap: () {Navigator.pushNamed(context, '/fail');}),
                  ListTile(title: const Text('Питание и Батарея',style: TextStyle(fontSize: 26),),onTap: () {Navigator.pushReplacementNamed(context, '/poba');}),
                  ListTile(title: const Text('Порты',style: TextStyle(fontSize: 26),),onTap: () {Navigator.pushReplacementNamed(context, '/port');}),
                  ListTile(title: const Text('Видео',style: TextStyle(fontSize: 26),),onTap: () {Navigator.pushReplacementNamed(context, '/vid');}),
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
      appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                _openMenu();
              },
              icon: Icon(Icons.menu))
      ),
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          center: LatLng(55.8, 37.43),
          zoom: 15.0,
          onTap: (_, latlng) => _handleTap(latlng),
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
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            onPressed: _animateObject, // Запуск анимации по нажатию
            child: Icon(Icons.play_arrow),
            tooltip: 'Начать полётное задание',
            backgroundColor: Colors.blue,
          ),
          SizedBox(height: 10, width: 10,),
          FloatingActionButton(
            onPressed: _resetMarkers,
            child: Icon(Icons.delete),
            tooltip: 'Сбросить маркеры',
            backgroundColor: Colors.red,
            heroTag: 'reset',
          ),
          SizedBox(height: 10, width: 10,),
          FloatingActionButton(
            child: Icon(Icons.auto_mode),
            onPressed: () {
              // Add logic to create spiral trajectory
              if (points.length < 3) {
                // Ensure at least 3 points to form a polygon
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Отметьте от 3 маркеров на карте для отображения выбранной территории")),
                );
              } else {
                List<LatLng> spiralPoints = generateSpiralPoints(points);

                // Update the state with the new set of points forming the spiral trajectory
                setState(() {
                  _resetMarkers();
                  points.addAll(spiralPoints); // Add spiral points to the list
                });
              }
            },
          ),
          SizedBox(height: 10, width: 10,),
          FloatingActionButton(
            child: Icon(Icons.square),
            onPressed: () {
              // Add logic to create spiral trajectory

                List<LatLng> spiralPoints = generateZigZagPath(points, 0.2);

                // Update the state with the new set of points forming the spiral trajectory
                setState(() {
                  _resetMarkers();
                  points.addAll(spiralPoints); // Add spiral points to the list
                });
              },
          )
        ],
      ),
    );
  }
}