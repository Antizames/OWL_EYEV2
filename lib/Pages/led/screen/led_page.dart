import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:owl/pages/appBar/widgets/customAppBar.dart';
import 'package:owl/pages/sideBarMenu/sidebar_menu.dart';
import 'package:owl/pages/led/widgets/led_cell.dart';
import 'package:owl/pages/led/widgets/led_settings.dart';
import 'package:owl/pages/configuration/widgets/myCustomSlider.dart';
class LedPage extends StatefulWidget {
  const LedPage({super.key});

  @override
  State<LedPage> createState() => _LedPageState();
}

class _LedPageState extends State<LedPage> {
  final int rows = 10;
  final int columns = 16;

  final Set<int> selected = {};
  final Set<String> activeDirections = {};
  final Map<int, Set<String>> orientations = {};
  final Map<int, int> colors = {};

  double brightness = 53;

  Rect? selectionRect;
  Offset? dragStart;
  GlobalKey gridKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(child: CustomScrollView(
        slivers: [
          CustomAppBar(
            title: 'LED-лента',
            leadingIcon: IconButton(
              icon: const Icon(Icons.menu, color: Colors.grey),
              onPressed: () => _openSidebarMenu(context),
            ),
            trailingIcon: IconButton(
              icon: const Icon(Icons.delete_sweep, color: Colors.grey),
              onPressed: () => setState(() => selected.clear()),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFE9EDF5), Color(0xFF95989E)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildSectionTitle('LED Матрица'),
                  _buildStyledContainer(child: _buildLedMatrixWithSelection()),

                  const SizedBox(height: 20),
                  _buildSectionTitle('Настройки LED'),
                  _buildStyledContainer(
                    child: LedSettingsPanel(
                      brightness: brightness,
                      onBrightnessChanged: (val) =>
                          setState(() => brightness = val),
                      activeDirections: activeDirections,
                      onToggleDirection: _toggleDirection,
                      onSetColor: _setColorForSelected,
                      onClearSelected: _clearSelected,
                      onClearAll: _clearAll,
                    ),
                  ),

                ],
              ),
            ),
          ),
        ],
      ),)
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: Text(title, style: const TextStyle(fontSize: 24, color: Colors.black)),
    );
  }

  Widget _buildStyledContainer({required Widget child}) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: const BorderRadius.all(Radius.circular(7)),
        border: Border.all(color: const Color.fromARGB(255, 109, 113, 120), width: 1),
      ),
      child: child,
    );
  }

  Widget _buildLedMatrixWithSelection() {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Stack(
        children: [
          _buildLedMatrix(),
          if (selectionRect != null)
            Positioned.fromRect(
              rect: selectionRect!,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.2),
                  border: Border.all(color: Colors.deepPurpleAccent, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLedMatrix() {
    return AspectRatio(
      aspectRatio: columns / rows,
      child: GridView.builder(
        key: gridKey,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: rows * columns,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                selected..clear()..add(index);
                activeDirections..clear()..addAll(_getDirections(index));
              });
            },
            onLongPress: () {
              setState(() {
                if (selected.contains(index)) {
                  selected.remove(index);
                } else {
                  selected.add(index);
                  activeDirections.clear();
                  activeDirections.addAll(_getDirections(index));
                }
              });
            },
            child: LedCell(
              index: index,
              isSelected: selected.contains(index),
              directions: _getDirections(index),
              colorIndex: colors[index],
            ),
          );
        },
      ),
    );
  }

  Set<String> _getDirections(int index) {
    return orientations[index] ?? {};
  }

  void _toggleDirection(String dir) {
    setState(() {
      if (activeDirections.contains(dir)) {
        activeDirections.remove(dir);
      } else {
        activeDirections.add(dir);
      }
      for (final i in selected) {
        final current = orientations[i] ?? <String>{};
        if (current.contains(dir)) {
          current.remove(dir);
        } else {
          current.add(dir);
        }
        orientations[i] = current;
      }
    });
  }

  void _setColorForSelected(int color) {
    setState(() {
      for (final i in selected) {
        colors[i] = color;
      }
    });
  }

  void _clearSelected() {
    setState(() {
      for (final i in selected) {
        orientations.remove(i);
        colors.remove(i);
      }
      selected.clear();
    });
  }

  void _clearAll() {
    setState(() {
      selected.clear();
      orientations.clear();
      colors.clear();
    });
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      dragStart = details.localPosition;
      selectionRect = null;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final current = details.localPosition;
    setState(() {
      selectionRect = Rect.fromPoints(dragStart!, current);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    _selectCellsInRect();
    setState(() {
      dragStart = null;
      selectionRect = null;
    });
  }

  void _selectCellsInRect() {
    if (selectionRect == null) return;

    final RenderBox? box = gridKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    final Offset gridOffset = box.localToGlobal(Offset.zero);
    final double cellWidth = (box.size.width - (columns - 1) * 4) / columns;
    final double cellHeight = (box.size.height - (rows - 1) * 4) / rows;

    final Rect globalSelectionRect = selectionRect!.shift(gridOffset);
    final newSelected = <int>{};

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < columns; col++) {
        final index = row * columns + col;
        final cellRect = Rect.fromLTWH(
          gridOffset.dx + col * (cellWidth + 4),
          gridOffset.dy + row * (cellHeight + 4),
          cellWidth,
          cellHeight,
        );
        if (globalSelectionRect.overlaps(cellRect)) {
          newSelected.add(index);
        }
      }
    }

    setState(() {
      selected..clear()..addAll(newSelected);
      activeDirections
        ..clear()
        ..addAll(selected.isNotEmpty ? _getDirections(selected.first) : {});
    });
  }

  void _openSidebarMenu(BuildContext context) {
    showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) =>
      throw UnimplementedError(),
      barrierDismissible: false,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero);
        final offsetAnimation = animation.drive(tween);

        return Stack(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: FadeTransition(
                opacity: animation,
                child: Container(color: Colors.black.withOpacity(0.5)),
              ),
            ),
            SlideTransition(
              position: offsetAnimation,
              child: const SidebarMenu(),
            ),
          ],
        );
      },
    );
  }
}
