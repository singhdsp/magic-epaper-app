import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

class ImageHandler {
  img.Image? originalImage;
  img.Image? image;
  img.Image? displayImage;
  List<String> displayColorMode = ['Black', 'White'];
  int displayWidth = 0;
  int displayHeight = 0;

  double currentContrast = 0.0;
  double currentBrightness = 0.0;
  double currentSaturation = 0.0;

  void setDisplayColorMode(List<String> supportedColors) {
    displayColorMode = supportedColors;
  }

  Future<void> loadFromBytes(Uint8List bytes) async {
    try {
      originalImage = img.decodeImage(bytes);

      image = originalImage!.clone();
      displayImage = null;

      currentContrast = 0.0;
      currentBrightness = 0.0;
      currentSaturation = 0.0;
    } catch (e) {
      throw Exception('Failed to load image from bytes: $e');
    }
  }

  Future<void> loadRaster(dynamic source) async {
    try {
      if (source is String) {
        if (source.startsWith('assets/')) {
          final imgBin = await rootBundle.load(source);
          final Uint8List byteArray = imgBin.buffer.asUint8List();
          originalImage = img.decodeImage(byteArray);
        } else {
          final File file = File(source);
          final bytes = await file.readAsBytes();
          originalImage = img.decodeImage(bytes);
        }
      } else if (source is Uint8List) {
        originalImage = img.decodeImage(source);
      } else {
        throw ArgumentError(
            'Source must be either a String path or Uint8List data');
      }

      image = originalImage!.clone();
      displayImage = null;

      currentContrast = 0.0;
      currentBrightness = 0.0;
      currentSaturation = 0.0;
    } catch (e) {
      throw Exception('Failed to load image: $e');
    }
  }

  Future<void> setDisplayDimensions(int width, int height) async {
    displayWidth = width;
    displayHeight = height;

    displayImage = null;
  }

  void applyDitheringFilter() {
    displayImage ??= _createDisplayImage();

    if (displayColorMode.contains('Red')) {
      displayImage = _applyBiColorDitheringToImage(displayImage!);
    } else {
      displayImage = img.grayscale(displayImage!);
      displayImage = img.ditherImage(displayImage!);
    }
  }

  void applyAdjustments({
    double contrast = 0.0,
    double brightness = 0.0,
    double saturation = 0.0,
  }) {
    currentContrast = contrast;
    currentBrightness = brightness;
    currentSaturation = saturation;

    displayImage = null;
  }

  void rotateRight() {
    if (originalImage == null) return;
    image = img.copyRotate(image!, angle: 90);
    displayImage = null;
  }

  void rotateLeft() {
    if (originalImage == null) return;
    image = img.copyRotate(image!, angle: -90);
    displayImage = null;
  }

  void flipHorizontal() {
    if (originalImage == null) return;
    image = img.flipHorizontal(image!);
    displayImage = null;
  }

  void flipVertical() {
    if (originalImage == null) return;
    image = img.flipVertical(image!);
    displayImage = null;
  }

  img.Image _createDisplayImage() {
    if (displayWidth <= 0 || displayHeight <= 0) {
      throw Exception('Display dimensions not set');
    }

    if (image == null) {
      throw Exception('No image available');
    }

    var display = img.Image(width: displayWidth, height: displayHeight);

    img.fill(display, color: img.ColorRgba8(255, 255, 255, 255));

    double scale = math.min(displayWidth / image!.width.toDouble(),
        displayHeight / image!.height.toDouble());

    int newWidth = (image!.width * scale).round();
    int newHeight = (image!.height * scale).round();

    int offsetX = (displayWidth - newWidth) ~/ 2;
    int offsetY = (displayHeight - newHeight) ~/ 2;

    var workingImage = image!.clone();

    if (currentBrightness != 1) {
      workingImage =
          img.adjustColor(workingImage, brightness: currentBrightness);
    }

    if (currentContrast != 1) {
      workingImage = img.adjustColor(workingImage, contrast: currentContrast);
    }

    if (currentSaturation != 1) {
      workingImage =
          img.adjustColor(workingImage, saturation: currentSaturation);
    }

    var scaledImage =
        img.copyResize(workingImage, width: newWidth, height: newHeight);

    img.compositeImage(display, scaledImage, dstX: offsetX, dstY: offsetY);

    return display;
  }

  img.Image _applyBiColorDitheringToImage(img.Image sourceImage) {
    final width = sourceImage.width;
    final height = sourceImage.height;

    final result = img.Image(width: width, height: height);

    var grayscale = img.grayscale(sourceImage);

    var dithered = img.ditherImage(grayscale);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final origPixel = sourceImage.getPixel(x, y);
        final ditherPixel = dithered.getPixel(x, y);

        final r = origPixel.getChannel(img.Channel.red);
        final g = origPixel.getChannel(img.Channel.green);
        final b = origPixel.getChannel(img.Channel.blue);

        int excessRed = ((r * 1.5) - g - b).round();

        final isDark = img.getLuminance(ditherPixel) < 128;

        if (excessRed > 100 && r > 150) {
          result.setPixel(x, y, img.ColorRgba8(255, 0, 0, 255));
        } else if (isDark) {
          result.setPixel(x, y, img.ColorRgba8(0, 0, 0, 255));
        } else {
          result.setPixel(x, y, img.ColorRgba8(255, 255, 255, 255));
        }
      }
    }

    return result;
  }

  img.Image _applyDisplayColorLimitationsToImage(img.Image sourceImage) {
    final width = sourceImage.width;
    final height = sourceImage.height;

    final result = img.Image(width: width, height: height);

    final hasRed = displayColorMode.contains('Red');

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final pixel = sourceImage.getPixel(x, y);
        final r = pixel.getChannel(img.Channel.red);
        final g = pixel.getChannel(img.Channel.green);
        final b = pixel.getChannel(img.Channel.blue);

        final gray = (0.299 * r + 0.587 * g + 0.114 * b).round();

        if (hasRed) {
          int excessRed = ((r * 2) - g - b).round();

          if (excessRed > 128) {
            result.setPixel(x, y, img.ColorRgba8(255, 0, 0, 255));
          } else if (gray < 128) {
            result.setPixel(x, y, img.ColorRgba8(0, 0, 0, 255));
          } else {
            result.setPixel(x, y, img.ColorRgba8(255, 255, 255, 255));
          }
        } else {
          if (gray < 128) {
            result.setPixel(x, y, img.ColorRgba8(0, 0, 0, 255));
          } else {
            result.setPixel(x, y, img.ColorRgba8(255, 255, 255, 255));
          }
        }
      }
    }
    return result;
  }

  Future<Uint8List> toPreviewImage({
    String? filterType,
    required List<String> displayColors,
  }) async {
    if (originalImage == null) {
      throw Exception('No image loaded');
    }

    setDisplayColorMode(displayColors);

    displayImage ??= _createDisplayImage();

    var workingImage = displayImage!.clone();

    if (filterType == 'dithering') {
      if (displayColorMode.contains('Red')) {
        workingImage = _applyBiColorDitheringToImage(workingImage);
      } else {
        workingImage = img.grayscale(workingImage);
        workingImage = img.ditherImage(workingImage);
      }
    } else {
      workingImage = _applyDisplayColorLimitationsToImage(workingImage);
    }

    return Uint8List.fromList(img.encodePng(workingImage));
  }

  Uint8List toEpdBitmap() {
    displayImage ??= _createDisplayImage();

    final width = displayImage!.width;
    final height = displayImage!.height;

    final widthBytes = (width + 7) ~/ 8;
    final bufferSize = widthBytes * height;
    final buffer = Uint8List(bufferSize);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final pixel = displayImage!.getPixel(x, y);
        final luminance = img.getLuminance(pixel);

        if (luminance < 128) {
          final byteIndex = y * widthBytes + (x ~/ 8);
          final bitIndex = 7 - (x % 8);
          buffer[byteIndex] |= (1 << bitIndex);
        }
      }
    }

    return buffer;
  }

  (Uint8List, Uint8List) toEpdBiColor() {
    displayImage ??= _createDisplayImage();

    final width = displayImage!.width;
    final height = displayImage!.height;

    final widthBytes = (width + 7) ~/ 8;
    final bufferSize = widthBytes * height;

    final blackBuffer = Uint8List(bufferSize);
    final redBuffer = Uint8List(bufferSize);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final pixel = displayImage!.getPixel(x, y);
        final r = pixel.getChannel(img.Channel.red);
        final g = pixel.getChannel(img.Channel.green);
        final b = pixel.getChannel(img.Channel.blue);

        final byteIndex = y * widthBytes + (x ~/ 8);
        final bitIndex = 7 - (x % 8);

        if (r > 200 && g < 100 && b < 100) {
          redBuffer[byteIndex] |= (1 << bitIndex);
        } else if (r < 128 && g < 128 && b < 128) {
          blackBuffer[byteIndex] |= (1 << bitIndex);
        }
      }
    }

    return (redBuffer, blackBuffer);
  }
}
