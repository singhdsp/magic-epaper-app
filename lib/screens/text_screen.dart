import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class TextScreen extends StatefulWidget {
  final int displayWidth;
  final int displayHeight;
  final List<String> supportedColors;

  const TextScreen({
    super.key,
    required this.displayWidth,
    required this.displayHeight,
    required this.supportedColors,
  });

  @override
  State<TextScreen> createState() => _TextScreenState();
}

class _TextScreenState extends State<TextScreen> {
  final TextEditingController _textController = TextEditingController();
  final GlobalKey _canvasKey = GlobalKey();
  String _enteredText = '';
  double _textSize = 24.0;
  Color _textColor = Colors.black;
  Color _backgroundColor = Colors.white;
  FontWeight _fontWeight = FontWeight.normal;
  String _fontFamily = 'Roboto';

  final List<String> _availableFonts = [
    'Roboto',
    'Montserrat',
    'PlayfairDisplay',
    'Poppins',
  ];

  final Map<String, FontWeight> _fontWeights = {
    'Light': FontWeight.w300,
    'Regular': FontWeight.normal,
    'Medium': FontWeight.w500,
    'Bold': FontWeight.bold,
    'Extra Bold': FontWeight.w800,
  };

  String _selectedFontWeight = 'Regular';
  String? _errorMessage;

  late final Map<String, Color> _supportedColorMap = {
    'Red': Colors.red,
    'Black': Colors.black,
    'White': Colors.white,
  };

  @override
  void initState() {
    super.initState();
    _validateAndSetColors();
    _loadFonts();
  }

  void _validateAndSetColors() {
    if (!_supportedColorMap.values.contains(_textColor)) {
      _textColor = Colors.black;
    }

    if (!_supportedColorMap.values.contains(_backgroundColor)) {
      _backgroundColor = Colors.white;
    }
  }

  Future<void> _loadFonts() async {
    await Future.wait([
      FontLoader('Roboto').load(),
      FontLoader('Montserrat').load(),
      FontLoader('PlayfairDisplay').load(),
      FontLoader('Poppins').load(),
    ]);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<Uint8List?> _saveCanvasAsImage() async {
    try {
      final boundary = _canvasKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: 1.0);
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error capturing image: $e');
      setState(() => _errorMessage = 'Error capturing image');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Create Text Image'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.done),
            onPressed: () async {
              final imageBytes = await _saveCanvasAsImage();
              if (imageBytes != null) {
                Navigator.pop(context, imageBytes);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_errorMessage != null)
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              color: Colors.red[100],
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Material(
                  elevation: 8.0,
                  borderRadius: BorderRadius.circular(12.0),
                  shadowColor: Colors.black26,
                  child: Container(
                    width: widget.displayWidth.toDouble(),
                    height: widget.displayHeight.toDouble(),
                    decoration: BoxDecoration(
                      color: _backgroundColor,
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: RepaintBoundary(
                      key: _canvasKey,
                      child: CustomPaint(
                        painter: TextCanvasPainter(
                          text: _enteredText,
                          textSize: _textSize,
                          textColor: _textColor,
                          backgroundColor: _backgroundColor,
                          fontFamily: _fontFamily,
                          fontWeight: _fontWeight,
                        ),
                        size: Size(
                          widget.displayWidth.toDouble(),
                          widget.displayHeight.toDouble(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24.0),
                topRight: Radius.circular(24.0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  offset: const Offset(0, -3),
                  blurRadius: 6.0,
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: const BoxDecoration(
                    color: Colors.deepOrange,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24.0),
                      topRight: Radius.circular(24.0),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.tune, color: Colors.white),
                      SizedBox(width: 8.0),
                      Text(
                        'Text Settings',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.4,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Your Text',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14.0,
                                  color: Colors.deepOrange,
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              TextField(
                                controller: _textController,
                                decoration: InputDecoration(
                                  hintText: 'Type your text here',
                                  fillColor: Colors.grey[50],
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                    borderSide:
                                        BorderSide(color: Colors.grey[300]!),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                    borderSide:
                                        BorderSide(color: Colors.grey[300]!),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                    borderSide: const BorderSide(
                                        color: Colors.deepOrange),
                                  ),
                                  contentPadding: const EdgeInsets.all(16.0),
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.clear,
                                        color: Colors.grey),
                                    onPressed: () {
                                      _textController.clear();
                                      setState(() => _enteredText = '');
                                    },
                                  ),
                                ),
                                onChanged: (value) =>
                                    setState(() => _enteredText = value),
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontFamily: _fontFamily,
                                  fontWeight: FontWeight.normal,
                                ),
                                maxLines: 3,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.font_download,
                                      color: Colors.deepOrange, size: 20),
                                  SizedBox(width: 8.0),
                                  Text(
                                    'Font Family',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14.0,
                                      color: Colors.deepOrange,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8.0),
                              Container(
                                height: 56.0,
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(12.0),
                                  border: Border.all(color: Colors.grey[200]!),
                                ),
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 8.0),
                                  itemCount: _availableFonts.length,
                                  itemBuilder: (context, index) {
                                    final font = _availableFonts[index];
                                    final isSelected = _fontFamily == font;

                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _fontFamily = font;
                                        });
                                        HapticFeedback.selectionClick();
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 6.0),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0, vertical: 8.0),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? Colors.deepOrange
                                              : Colors.grey[100],
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                          boxShadow: isSelected
                                              ? [
                                                  BoxShadow(
                                                    color: Colors.deepOrange
                                                        .withOpacity(0.3),
                                                    blurRadius: 4.0,
                                                    offset: const Offset(0, 2),
                                                  )
                                                ]
                                              : null,
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          font,
                                          style: TextStyle(
                                            fontFamily: font,
                                            fontWeight: FontWeight.w500,
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.black87,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.text_fields,
                                      color: Colors.deepOrange, size: 20),
                                  SizedBox(width: 8.0),
                                  Text(
                                    'Font Size',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14.0,
                                      color: Colors.deepOrange,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8.0),
                              Row(
                                children: [
                                  Text(
                                    '${_textSize.round()}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Expanded(
                                    child: Slider(
                                      value: _textSize,
                                      min: 12.0,
                                      max: 72.0,
                                      divisions: 30,
                                      activeColor: Colors.deepOrange,
                                      inactiveColor:
                                          Colors.deepOrange.withAlpha(51),
                                      thumbColor: Colors.white,
                                      label: _textSize.round().toString(),
                                      onChanged: (value) {
                                        setState(() {
                                          _textSize = value;
                                        });
                                      },
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.text_decrease,
                                        color: Colors.grey),
                                    onPressed: () {
                                      if (_textSize > 12) {
                                        setState(() {
                                          _textSize =
                                              (_textSize - 2).clamp(12.0, 72.0);
                                        });
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.text_increase,
                                        color: Colors.grey),
                                    onPressed: () {
                                      if (_textSize < 72) {
                                        setState(() {
                                          _textSize =
                                              (_textSize + 2).clamp(12.0, 72.0);
                                        });
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.format_bold,
                                      color: Colors.deepOrange, size: 20),
                                  SizedBox(width: 8.0),
                                  Text(
                                    'Font Weight',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14.0,
                                      color: Colors.deepOrange,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8.0),
                              SizedBox(
                                height: 48.0,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _fontWeights.length,
                                  itemBuilder: (context, index) {
                                    final weightName =
                                        _fontWeights.keys.elementAt(index);
                                    final isSelected =
                                        _selectedFontWeight == weightName;

                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedFontWeight = weightName;
                                          _fontWeight =
                                              _fontWeights[weightName]!;
                                        });
                                        HapticFeedback.selectionClick();
                                      },
                                      child: Container(
                                        margin:
                                            const EdgeInsets.only(right: 12.0),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0, vertical: 8.0),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? Colors.deepOrange
                                              : Colors.grey[100],
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                          boxShadow: isSelected
                                              ? [
                                                  BoxShadow(
                                                    color: Colors.deepOrange
                                                        .withOpacity(0.3),
                                                    blurRadius: 4.0,
                                                    offset: const Offset(0, 2),
                                                  )
                                                ]
                                              : null,
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          weightName,
                                          style: TextStyle(
                                            fontFamily: _fontFamily,
                                            fontWeight:
                                                _fontWeights[weightName],
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.black87,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 32.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildColorSelector(
                                  title: 'Text Color',
                                  icon: Icons.text_format,
                                  selectedColor: _textColor,
                                  onColorChanged: (color) {
                                    setState(() {
                                      _textColor = color;
                                    });
                                    HapticFeedback.selectionClick();
                                  },
                                ),
                              ),
                              const SizedBox(width: 16.0),
                              Expanded(
                                child: _buildColorSelector(
                                  title: 'Background',
                                  icon: Icons.format_color_fill,
                                  selectedColor: _backgroundColor,
                                  onColorChanged: (color) {
                                    setState(() {
                                      _backgroundColor = color;
                                    });
                                    HapticFeedback.selectionClick();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorSelector({
    required String title,
    required IconData icon,
    required Color selectedColor,
    required Function(Color) onColorChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.deepOrange, size: 16),
              const SizedBox(width: 6.0),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14.0,
                  color: Colors.deepOrange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _supportedColorMap.entries.map((entry) {
              final color = entry.value;
              final isSelected = selectedColor == color;

              return GestureDetector(
                onTap: () => onColorChanged(color),
                child: Container(
                  width: 36.0,
                  height: 36.0,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.deepOrange : Colors.grey[300]!,
                      width: isSelected ? 2.0 : 1.0,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.deepOrange.withOpacity(0.4),
                              blurRadius: 6.0,
                              spreadRadius: 1.0,
                            )
                          ]
                        : null,
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          size: 20.0,
                          color: color == Colors.white
                              ? Colors.black
                              : Colors.white,
                        )
                      : null,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class TextCanvasPainter extends CustomPainter {
  final String text;
  final double textSize;
  final Color textColor;
  final Color backgroundColor;
  final String fontFamily;
  final FontWeight fontWeight;

  TextCanvasPainter({
    required this.text,
    required this.textSize,
    required this.textColor,
    required this.backgroundColor,
    required this.fontFamily,
    required this.fontWeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = backgroundColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    if (text.isEmpty) return;
    final textStyle = TextStyle(
      fontSize: textSize,
      color: textColor,
      fontFamily: fontFamily,
      fontWeight: fontWeight,
      height: 1.2, 
    );

    final textSpan = TextSpan(text: text, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    final maxWidth = size.width - 20.0;
    textPainter.layout(maxWidth: maxWidth);

    final offset = Offset(
      (size.width - textPainter.width) / 2,
      (size.height - textPainter.height) / 2,
    );

    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is TextCanvasPainter) {
      return oldDelegate.text != text ||
          oldDelegate.textSize != textSize ||
          oldDelegate.textColor != textColor ||
          oldDelegate.backgroundColor != backgroundColor ||
          oldDelegate.fontFamily != fontFamily ||
          oldDelegate.fontWeight != fontWeight;
    }
    return true;
  }
}
