import 'dart:typed_data';
import '../../models/display_models.dart';
import '../../epdutils.dart';
import '../../imagehandler.dart';
import '../../models/filter_type.dart';

class TransferUtils {
  static Future<void> transferToDisplay({
    required ImageHandler imageHandler,
    required EpaperDisplay display,
    required FilterType selectedFilter,
    required void Function(String) updateStatus,
  }) async {
    updateStatus('Preparing image...');

    try {
      imageHandler.setDisplayColorMode(display.supportedColors);

      switch (selectedFilter) {
        case FilterType.dithering:
          imageHandler.applyDitheringFilter();
          break;
        case FilterType.none:
          break;
      }

      updateStatus('Processing image for ${display.name}...');

      late Uint8List red;
      late Uint8List black;

      if (display.supportedColors.contains('Red')) {
        var (redData, blackData) = imageHandler.toEpdBiColor();
        red = redData;
        black = blackData;
      } else {
        black = imageHandler.toEpdBitmap();
        red = Uint8List(0);
      }

      updateStatus('Transferring to display...');

      int chunkSize = 220;
      List<Uint8List> redChunks = MagicEpd.divideUint8List(red, chunkSize);
      List<Uint8List> blackChunks = MagicEpd.divideUint8List(black, chunkSize);

      updateStatus('Please place your phone near the NFC tag...');

      await MagicEpd.writeChunk(blackChunks, redChunks);

      updateStatus('Transfer complete!');
    } catch (e) {
      updateStatus('Error: $e');
      rethrow;
    }
  }
}