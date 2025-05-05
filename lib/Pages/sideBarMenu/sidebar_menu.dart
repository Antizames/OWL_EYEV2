import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'widgets/rpg_dialog.dart';
import 'widgets/rpg_character_dialog.dart';
import 'package:owl/main.dart'; // путь до файла с navigatorKey

class SidebarMenu extends StatefulWidget {
  const SidebarMenu({super.key});

  @override
  State<SidebarMenu> createState() => _SidebarMenuState();
}

class _SidebarMenuState extends State<SidebarMenu> {
  final Map<String, int> tapCounters = {};
  OverlayEntry? _overlayEntry;

  void _showDevMessage(String key) {
    tapCounters[key] = (tapCounters[key] ?? 0) + 1;
    int count = tapCounters[key]!;

    // Отдельная пасхалка на 50-е нажатие
    if (count == 50) {
      _overlayEntry?.remove();
      _overlayEntry = OverlayEntry(
        builder: (context) => CharacterDialogBox(
          lines: [
            DialogLine(text: 'Ты совсем идиот?', imagePath: 'Assets/Images/kor.png'),
            DialogLine(text: 'Тебе русским языком сказали: эти страницы ещё в разработке.', imagePath: 'Assets/Images/kor.png'),
            DialogLine(text: 'А ты всё тыкаешь в них, надеясь, что они чудом откроются?', imagePath: 'Assets/Images/kor.png'),
            DialogLine(text: 'Секретный уровень захотел, да?', imagePath: 'Assets/Images/review.png'),
            DialogLine(text: 'Ладно, так уж и быть — извинишься по-хорошему, и я тебя отпускаю. Договорились?', imagePath: 'Assets/Images/review.png'),
          ],
          onFinish: () {
            _overlayEntry?.remove();
            _overlayEntry = null;
            Future.delayed(const Duration(milliseconds: 300), () {
              navigatorKey.currentState?.pushReplacementNamed('/boss');

            });
          },

        ),
      );
      Overlay.of(context).insert(_overlayEntry!);
      return;
    }

    // Сообщения на 5 / 15 / 30
    String? message;
    bool shake = false;

    if (count == 5) {
      message = 'Страница всё ещё в разработке...';
    } else if (count == 15) {
      message = 'Страница ВСЁ ЕЩЁ в разработке!';
    } else if (count == 30) {
      message = 'Вы чувствуете чей-то злобный взгляд...';
      shake = true;
    }

    if (message != null) {
      _overlayEntry?.remove();
      _overlayEntry = OverlayEntry(
        builder: (context) => RpgDialogBox(
          message: message!,
          onClose: () {
            _overlayEntry?.remove();
            _overlayEntry = null;
          },
          shake: shake,
        ),
      );
      Overlay.of(context).insert(_overlayEntry!);
    }
  }

  Widget _buildDisabledTile(IconData icon, String title, String key) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey),
      title: Text(title, style: const TextStyle(color: Colors.grey)),
      onTap: () => _showDevMessage(key),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(13),
        bottomRight: Radius.circular(13),
      ),
      child: Material(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height,
          color: Colors.white,
          child: Column(
            children: [
              const Padding(padding: EdgeInsets.all(10)),
              _buildTile(context, Icons.navigation, 'Навигация', '/'),
              _buildTile(context, FontAwesomeIcons.microchip, 'Конфигурация', '/conf'),
              _buildTile(context, FontAwesomeIcons.phoenixSquadron, 'Дрон', '/mod'),
              _buildTile(context, Icons.battery_charging_full, 'Питание и Батарея', '/bat'),
              _buildTile(context, Icons.cable, 'Порты', '/port'),
              _buildTile(context, FontAwesomeIcons.gears, 'Сервоприводы', '/ser'),
              _buildTile(context, FontAwesomeIcons.fan, 'Моторы', '/mot'),
              _buildTile(context, Icons.lightbulb_outline, 'LED-лента (тестовый)', '/led'),
              _buildTile(context, Icons.shield, 'Отказобезопасность (тестовый)', '/fail'),
              _buildTile(context, Icons.tune, 'PID настройки (тестовый)', '/pid'),
              _buildTile(context, Icons.satellite_alt, 'GPS (тестовый)', '/gps'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTile(BuildContext context, IconData icon, String title, String route) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        Navigator.pushReplacementNamed(context, route);
      },
    );
  }
}
