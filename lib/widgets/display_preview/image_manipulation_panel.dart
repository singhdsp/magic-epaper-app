import 'dart:math' as math;

import 'package:flutter/material.dart';

class ImageManipulationPanel extends StatelessWidget {
  final VoidCallback onRotateLeft;
  final VoidCallback onRotateRight;
  final VoidCallback onFlipHorizontal;
  final VoidCallback onFlipVertical;
  final VoidCallback onClose;

  const ImageManipulationPanel({
    super.key,
    required this.onRotateLeft,
    required this.onRotateRight,
    required this.onFlipHorizontal,
    required this.onFlipVertical,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 180,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Image Operations',
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildImageOperationButton(
                icon: Icons.rotate_left,
                label: 'Rotate Left',
                onTap: onRotateLeft,
              ),
              _buildImageOperationButton(
                icon: Icons.rotate_right,
                label: 'Rotate Right',
                onTap: onRotateRight,
              ),
              _buildImageOperationButton(
                icon: Icons.flip,
                label: 'Flip Horizontal',
                onTap: onFlipHorizontal,
              ),
              _buildImageOperationButton(
                icon: Icons.flip,
                label: 'Flip Vertical',
                rotation: 90,
                onTap: onFlipVertical,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageOperationButton({
    required IconData icon,
    required String label,
    double? rotation,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.deepOrange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.deepOrange.shade300),
            ),
            child: Transform.rotate(
              angle: (rotation ?? 0) * math.pi / 180,
              child: Icon(
                icon,
                color: Colors.deepOrange,
                size: 24,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}