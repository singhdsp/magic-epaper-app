import 'package:flutter/material.dart';
import '../models/display_models.dart';
import '../widgets/display_screen/display_card.dart';

class DisplaySelectionScreen extends StatelessWidget {
  const DisplaySelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select E-Paper Display'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: availableDisplays.length,
        itemBuilder: (context, index) {
          final display = availableDisplays[index];
          return DisplayCard(display: display);
        },
      ),
    );
  }
}