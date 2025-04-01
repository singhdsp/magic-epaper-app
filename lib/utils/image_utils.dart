import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import '../imagehandler.dart';

class ImageUtils {
  static Future<Uint8List?> pickImage(ImagePicker picker) async {
    try {
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
      );
      return await pickedFile?.readAsBytes();
    } catch (e) {
      return null;
    }
  }

  static Future<void> applyImageOperation({
    required ImageHandler imageHandler,
    required String operation,
    required void Function(String) updateStatus,
  }) async {
    updateStatus('Applying $operation...');
    try {
      switch (operation) {
        case 'rotateRight':
          imageHandler.rotateRight();
          break;
        case 'rotateLeft':
          imageHandler.rotateLeft();
          break;
        case 'flipHorizontal':
          imageHandler.flipHorizontal();
          break;
        case 'flipVertical':
          imageHandler.flipVertical();
          break;
      }
      updateStatus('$operation applied');
    } catch (e) {
      updateStatus('Error applying $operation: $e');
      rethrow;
    }
  }
}