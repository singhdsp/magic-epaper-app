import 'package:flutter/material.dart';
import '../../../../models/display_models.dart';
import '../../screens/display_preview_screen.dart';
import 'color_dot.dart';

class DisplayCard extends StatelessWidget {
  final EpaperDisplay display;

  const DisplayCard({super.key, required this.display});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DisplayPreviewScreen(display: display),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPreviewImage(),
            _buildDisplayDetails(),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewImage() {
    return Expanded(
      child: Container(
        color: Colors.grey[200],
        width: double.infinity,
        child: display.imagePath != null
        ? Image.asset(
            display.imagePath!,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Icon(
              Icons.image_not_supported,
              size: 50,
              color: Colors.grey[400],
            ),
          );
            },
          )
        : Center(
            child: Icon(
          Icons.image_not_supported,
          size: 50,
          color: Colors.grey[400],
            ),
          ),
      ),
    );
  }

  Widget _buildDisplayDetails() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            display.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '${display.widthMm.toStringAsFixed(1)} × ${display.heightMm.toStringAsFixed(1)} mm',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: display.supportedColors
                .map((color) => ColorDot(color: color))
                .toList(),
          ),
        ],
      ),
    );
  }
}