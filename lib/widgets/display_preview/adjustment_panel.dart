import 'package:flutter/material.dart';

class AdjustmentsPanel extends StatelessWidget {
  final double contrastValue;
  final double brightnessValue;
  final double saturationValue;
  final Function(double) onContrastChanged;
  final Function(double) onBrightnessChanged;
  final Function(double) onSaturationChanged;
  final VoidCallback onReset;
  final VoidCallback onApply;
  final bool isGeneratingPreviews;
  final VoidCallback onClose;

  const AdjustmentsPanel({
    super.key,
    required this.contrastValue,
    required this.brightnessValue,
    required this.saturationValue,
    required this.onContrastChanged,
    required this.onBrightnessChanged,
    required this.onSaturationChanged,
    required this.onReset,
    required this.onApply,
    required this.isGeneratingPreviews,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 240,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Image Adjustments',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onClose,
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildSlider(
              'Contrast',
              contrastValue,
              0,
              2.0,
              onContrastChanged,
            ),
            _buildSlider(
              'Brightness',
              brightnessValue,
              0,
              2.0,
              onBrightnessChanged,
            ),
            _buildSlider(
              'Saturation',
              saturationValue,
              0,
              2.0,
              onSaturationChanged,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: onReset,
                  child: const Text('Reset'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: isGeneratingPreviews ? null : onApply,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Apply'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(String label, double value, double min, double max,
      Function(double) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text(value.toStringAsFixed(2)),
            ],
          ),
          SizedBox(
            height: 40,
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: 20,
              onChanged: onChanged,
              activeColor: Colors.deepOrange,
            ),
          ),
        ],
      ),
    );
  }
}