import 'package:flutter/material.dart';
import 'package:owl/pages/configuration/widgets/myCustomSlider.dart';
import 'package:owl/pages/led/widgets/styled_button.dart';

class LedSettingsPanel extends StatelessWidget {
  final double brightness;
  final Function(double) onBrightnessChanged;

  final Set<String> activeDirections;
  final void Function(String) onToggleDirection;
  final void Function(int) onSetColor;
  final void Function() onClearSelected;
  final void Function() onClearAll;

  const LedSettingsPanel({
    super.key,
    required this.brightness,
    required this.onBrightnessChanged,
    required this.activeDirections,
    required this.onToggleDirection,
    required this.onSetColor,
    required this.onClearSelected,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Яркость", style: TextStyle(color: Colors.white)),
          Row(
            children: [
              Expanded(
                child: MyCustomSlider(
                  sliderValue: brightness,
                  onValueChanged: onBrightnessChanged,
                ),
              ),
              const SizedBox(width: 10),
              Text('${brightness.toInt()}%', style: const TextStyle(color: Colors.white)),
            ],
          ),
          const SizedBox(height: 12),
          const Text("Ориентация", style: TextStyle(color: Colors.white)),
          Wrap(
            spacing: 8,
            children: ['С', 'В', 'Ю', 'З', 'U', 'D'].map((d) {
              final isSelected = activeDirections.contains(d);

              return OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: isSelected ? Colors.orange : Colors.transparent,
                  side: const BorderSide(color: Colors.orange),
                ),
                onPressed: () => onToggleDirection(d),
                child: Text(
                  d,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          const Text("Цвет", style: TextStyle(color: Colors.white)),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: List.generate(
              16,
                  (i) => OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.orange),
                ),
                onPressed: () => onSetColor(i),
                child: Text(
                  '$i',
                  style: const TextStyle(color: Colors.orange),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          StyledButton(
            text: "Режим назначения цепи",
            onPressed: () {},
          ),


          const SizedBox(height: 10),
          Column(
            children: [
              StyledButton(
                text: "Очистить выбранное",
                onPressed: onClearSelected,
              ),
              const SizedBox(height: 10),
              StyledButton(
                text: "Очистить ВСЕ",
                onPressed: onClearAll,
              ),
            ],
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
