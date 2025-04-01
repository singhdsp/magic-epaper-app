import 'dart:typed_data';
import '../../models/filter_type.dart';
import '../../imagehandler.dart';

class PreviewUtils {
  static Future<Uint8List?> generatePreview({
    required ImageHandler imageHandler,
    required FilterType filter,
    required List<String> supportedColors,
    double contrast = 1.0,
    double brightness = 1.0,
    double saturation = 1.0,
  }) async {
    try {
      imageHandler.applyAdjustments(
        contrast: contrast,
        brightness: brightness,
        saturation: saturation,
      );

      imageHandler.setDisplayColorMode(supportedColors);

      String? filterType;
      switch (filter) {
        case FilterType.none:
          filterType = null;
          break;
        case FilterType.dithering:
          filterType = 'dithering';
          break;
      }

      return await imageHandler.toPreviewImage(
        filterType: filterType,
        displayColors: supportedColors,
      );
    } catch (e) {
      return null;
    }
  }
}