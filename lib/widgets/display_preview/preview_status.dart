import 'package:flutter/material.dart';

class PreviewStatus extends StatelessWidget {
  final String statusMessage;
  final bool isLoading;

  const PreviewStatus({
    super.key,
    required this.statusMessage,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (statusMessage.isEmpty) return const SizedBox.shrink();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Status: ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: Text(statusMessage),
                ),
                if (isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}