import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../models/display_models.dart';
import '../imagehandler.dart';
import './text_screen.dart';

import '../widgets/display_preview/adjustment_panel.dart';
import '../widgets/display_preview/filter_option_card.dart';
import '../widgets/display_preview/image_manipulation_panel.dart';
import '../widgets/display_preview/preview_status.dart';
import '../widgets/display_preview/bottom_nav_button.dart';
import '../components/info_row.dart';
import '../utils/preview_utils.dart';
import '../utils/transfer_utils.dart';
import '../components/loading_overlay.dart';
import '../models/filter_type.dart';
import '../utils/image_utils.dart';

class DisplayPreviewScreen extends StatefulWidget {
  final EpaperDisplay display;

  const DisplayPreviewScreen({super.key, required this.display});

  @override
  State<DisplayPreviewScreen> createState() => _DisplayPreviewScreenState();
}

class _DisplayPreviewScreenState extends State<DisplayPreviewScreen> {
  dynamic selectedImagePath;
  File? imageFile;
  bool isLoading = false;
  bool isGeneratingPreviews = false;
  String statusMessage = '';
  FilterType selectedFilter = FilterType.none;
  final ImagePicker _picker = ImagePicker();
  final Map<FilterType, Uint8List?> previewCache = {};
  ImageHandler imageHandler = ImageHandler();
  bool isDefaultImage = true;
  double contrastValue = 1.0;
  double saturationValue = 1.0;
  double brightnessValue = 1.0;
  int currentBottomTab = 0;
  bool isAdjustmentsVisible = false;
  int displayWidth = 0;
  int displayHeight = 0;
  bool isImageMenuVisible = false;
  bool isTextImage = false;

  @override
  void initState() {
    super.initState();
    _calculateDisplayDimensions();
    _loadDefaultImage();
  }

  void _calculateDisplayDimensions() {
    double widthInch = widget.display.widthMm / 25.4;
    double heightInch = widget.display.heightMm / 25.4;
    displayWidth = (widthInch * widget.display.resolution).round();
    displayHeight = (heightInch * widget.display.resolution).round();
  }

  Future<void> _loadDefaultImage() async {
    setState(() {
      isLoading = true;
      isGeneratingPreviews = true;
      statusMessage = 'Loading default image...';
    });

    try {
      selectedImagePath = 'assets/images/black-red.png';
      isDefaultImage = true;
      await imageHandler.loadRaster(selectedImagePath!);
      imageHandler.setDisplayDimensions(displayWidth, displayHeight);
      await _generateAllPreviews();

      setState(() {
        isLoading = false;
        isGeneratingPreviews = false;
        statusMessage = 'Default image loaded';
      });
    } catch (e) {
      setState(() {
        statusMessage = 'Error loading default image: $e';
        isLoading = false;
        isGeneratingPreviews = false;
      });
    }
  }

  Future<void> _applyAdjustments() async {
    setState(() {
      isGeneratingPreviews = true;
      statusMessage = 'Applying adjustments...';
    });

    try {
      previewCache.clear();
      if (selectedImagePath != null || isTextImage) {
        await imageHandler.loadRaster(selectedImagePath!);
      }

      imageHandler.applyAdjustments(
          contrast: contrastValue,
          brightness: brightnessValue,
          saturation: saturationValue);

      await _generateAllPreviews(skipReload: true);

      setState(() {
        isGeneratingPreviews = false;
        statusMessage = 'Adjustments applied';
        isAdjustmentsVisible = false;
      });
    } catch (e) {
      setState(() {
        statusMessage = 'Error applying adjustments: $e';
        isGeneratingPreviews = false;
      });
    }
  }

  Future<void> _resetAdjustments() async {
    setState(() {
      contrastValue = 1;
      brightnessValue = 1;
      saturationValue = 1;
      isGeneratingPreviews = true;
      statusMessage = 'Resetting adjustments...';
    });

    try {
      previewCache.clear();
      if (selectedImagePath != null || isTextImage) {
        await imageHandler.loadRaster(selectedImagePath!);
      }
      await _generateAllPreviews();

      setState(() {
        isGeneratingPreviews = false;
        statusMessage = 'Adjustments reset';
      });
    } catch (e) {
      setState(() {
        statusMessage = 'Error resetting adjustments: $e';
        isGeneratingPreviews = false;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        setState(() {
          imageFile = File(pickedFile.path);
          selectedImagePath = pickedFile.path;
          isDefaultImage = false;
          previewCache.clear();
          statusMessage = 'Image selected, processing...';
          isLoading = true;
          isGeneratingPreviews = true;
        });

        await imageHandler.loadRaster(pickedFile.path);
        imageHandler.setDisplayDimensions(displayWidth, displayHeight);
        await _generateAllPreviews();

        setState(() {
          isLoading = false;
          isGeneratingPreviews = false;
          statusMessage = 'Image processed and ready';
        });
      }
    } catch (e) {
      setState(() {
        statusMessage = 'Error picking image: $e';
        isLoading = false;
        isGeneratingPreviews = false;
      });
    }
  }

  Future<void> _generateAllPreviews({bool skipReload = false}) async {
    if (selectedImagePath == null) return;

    try {
      if (!skipReload) {
        if (imageHandler.image == null) {
          await imageHandler.loadRaster(selectedImagePath!);
          imageHandler.setDisplayDimensions(displayWidth, displayHeight);
        }

        imageHandler.applyAdjustments(
            contrast: contrastValue,
            brightness: brightnessValue,
            saturation: saturationValue);
      }

      imageHandler.setDisplayColorMode(widget.display.supportedColors);

      for (var filter in FilterType.values) {
        final processedImage = await PreviewUtils.generatePreview(
          imageHandler: imageHandler,
          filter: filter,
          supportedColors: widget.display.supportedColors,
          contrast: contrastValue,
          brightness: brightnessValue,
          saturation: saturationValue,
        );

        setState(() {
          previewCache[filter] = processedImage;
        });
      }
    } catch (e) {
      setState(() {
        statusMessage = 'Error generating previews: $e';
      });
    }
  }

  Future<void> _applyImageOperation(String operation) async {
    setState(() {
      isGeneratingPreviews = true;
      statusMessage = 'Applying $operation...';
    });

    try {
      await ImageUtils.applyImageOperation(
        imageHandler: imageHandler,
        operation: operation,
        updateStatus: (msg) => setState(() => statusMessage = msg),
      );

      imageHandler.applyAdjustments(
        contrast: contrastValue,
        brightness: brightnessValue,
        saturation: saturationValue,
      );

      previewCache.clear();
      await _generateAllPreviews(skipReload: true);

      setState(() {
        isGeneratingPreviews = false;
        statusMessage = '$operation applied';
      });
    } catch (e) {
      setState(() {
        statusMessage = 'Error applying $operation: $e';
        isGeneratingPreviews = false;
      });
    }
  }

  Future<void> _applyFilter(FilterType filter) async {
    setState(() {
      selectedFilter = filter;
      statusMessage = '${filter.name} filter selected';
      isGeneratingPreviews = true;
    });

    try {
      imageHandler.applyAdjustments(
          contrast: contrastValue,
          brightness: brightnessValue,
          saturation: saturationValue);

      final processedImage = await PreviewUtils.generatePreview(
        imageHandler: imageHandler,
        filter: filter,
        supportedColors: widget.display.supportedColors,
        contrast: contrastValue,
        brightness: brightnessValue,
        saturation: saturationValue,
      );

      setState(() {
        previewCache[filter] = processedImage;
        isGeneratingPreviews = false;
      });
    } catch (e) {
      setState(() {
        statusMessage = 'Error generating preview: $e';
        isGeneratingPreviews = false;
      });
    }
  }

  Future<void> _transferToDisplay() async {
    if (selectedImagePath == null) {
      setState(() {
        statusMessage = 'Please select an image first';
      });
      return;
    }

    setState(() {
      isLoading = true;
      statusMessage = 'Preparing image...';
    });

    try {
      await TransferUtils.transferToDisplay(
        imageHandler: imageHandler,
        display: widget.display,
        selectedFilter: selectedFilter,
        updateStatus: (msg) => setState(() => statusMessage = msg),
      );

      setState(() {
        statusMessage = 'Transfer complete!';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        statusMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  void _handleBottomTabTap(int index) {
    setState(() {
      if (index == 1) {
        isAdjustmentsVisible = !isAdjustmentsVisible;
        isImageMenuVisible = false;
        currentBottomTab = isAdjustmentsVisible ? 1 : 0;
      } else if (index == 2) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TextScreen(
              displayWidth: displayWidth,
              displayHeight: displayHeight,
              supportedColors: [
                ...widget.display.supportedColors,
              ],
            ),
          ),
        ).then((imageBytes) async {
          if (imageBytes is Uint8List) {
            try {
              setState(() {
                isLoading = true;
                statusMessage = 'Loading text image...';
              });

              await imageHandler.loadFromBytes(imageBytes);
              isTextImage = true;
              selectedImagePath = imageBytes;
              imageHandler.setDisplayDimensions(displayWidth, displayHeight);

              await _generateAllPreviews();

              setState(() {
                isLoading = false;
                statusMessage = 'Text image loaded';
                isDefaultImage = false;
              });
            } catch (e) {
              setState(() {
                isLoading = false;
                statusMessage = 'Error loading text image: $e';
              });
            }
          }
        });
      } else if (index == 3) {
        isImageMenuVisible = !isImageMenuVisible;
        isAdjustmentsVisible = false;
        currentBottomTab = isImageMenuVisible ? 3 : 0;
      } else {
        isAdjustmentsVisible = false;
        isImageMenuVisible = false;
        currentBottomTab = index;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text(widget.display.name),
            backgroundColor: Colors.deepOrange,
            foregroundColor: Colors.white,
          ),
          body: Stack(
            children: [
              Positioned.fill(
                bottom: (isAdjustmentsVisible || isImageMenuVisible)
                    ? (isAdjustmentsVisible ? 240 : 180)
                    : 0,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InfoRow(
                                label: 'Size',
                                value:
                                    '${widget.display.widthMm.toStringAsFixed(1)} x ${widget.display.heightMm.toStringAsFixed(1)} mm',
                              ),
                              InfoRow(
                                label: 'Resolution',
                                value: '${widget.display.resolution} dpi',
                              ),
                              InfoRow(
                                label: 'Colors',
                                value: widget.display.supportedColors.join(', '),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 8, bottom: 8),
                        child: Text(
                          'Filter Options',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ...FilterType.values.map((filter) => FilterOptionCard(
                            filter: filter,
                            isSelected: selectedFilter == filter,
                            previewImage: previewCache[filter],
                            isLoading: isGeneratingPreviews,
                            onTap: () => _applyFilter(filter),
                          )),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: isLoading ? null : _pickImage,
                                icon: const Icon(Icons.image),
                                label: const Text('Select Image'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: isLoading ? null : _transferToDisplay,
                                icon: const Icon(Icons.send),
                                label: const Text('Transfer to Display'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      PreviewStatus(
                        statusMessage: statusMessage,
                        isLoading: isLoading && !isGeneratingPreviews,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isAdjustmentsVisible)
                      AdjustmentsPanel(
                        contrastValue: contrastValue,
                        brightnessValue: brightnessValue,
                        saturationValue: saturationValue,
                        onContrastChanged: (value) =>
                            setState(() => contrastValue = value),
                        onBrightnessChanged: (value) =>
                            setState(() => brightnessValue = value),
                        onSaturationChanged: (value) =>
                            setState(() => saturationValue = value),
                        onReset: _resetAdjustments,
                        onApply: _applyAdjustments,
                        isGeneratingPreviews: isGeneratingPreviews,
                        onClose: () => setState(() {
                          isAdjustmentsVisible = false;
                          currentBottomTab = 0;
                        }),
                      ),
                    if (isImageMenuVisible)
                      ImageManipulationPanel(
                        onRotateLeft: () => _applyImageOperation('rotateLeft'),
                        onRotateRight: () => _applyImageOperation('rotateRight'),
                        onFlipHorizontal: () =>
                            _applyImageOperation('flipHorizontal'),
                        onFlipVertical: () =>
                            _applyImageOperation('flipVertical'),
                        onClose: () => setState(() {
                          isImageMenuVisible = false;
                          currentBottomTab = 0;
                        }),
                      ),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: BottomAppBar(
            height: 80,
            padding: EdgeInsets.zero,
            elevation: 8,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  BottomNavButton(
                    icon: Icons.tune,
                    label: 'Adjust',
                    isSelected: currentBottomTab == 1,
                    onTap: () => _handleBottomTabTap(1),
                  ),
                  BottomNavButton(
                    icon: Icons.text_fields,
                    label: 'Text',
                    isSelected: currentBottomTab == 2,
                    onTap: () => _handleBottomTabTap(2),
                  ),
                  BottomNavButton(
                    icon: Icons.image,
                    label: 'Image',
                    isSelected: currentBottomTab == 3,
                    onTap: () => _handleBottomTabTap(3),
                  ),
                ],
              ),
            ),
          ),
        ),
        LoadingOverlay(isLoading: isLoading && !isGeneratingPreviews),
      ],
    );
  }
}