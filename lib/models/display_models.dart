class EpaperDisplay {
  final String id;
  final String name;
  final double widthMm;
  final double heightMm;
  final int resolution;
  final String? imagePath;
  final List<String> supportedColors;

  const EpaperDisplay({
    required this.id,
    required this.name,
    required this.widthMm,
    required this.heightMm,
    required this.resolution,
    required this.imagePath,
    required this.supportedColors,
  });
}

final List<EpaperDisplay> availableDisplays = [
  const EpaperDisplay(
    id: "2_13_bwr",
    name: "2.13\" BWR",
    widthMm: 48.0,
    heightMm: 24.0,
    resolution: 212,    
    imagePath: null,
    supportedColors: ["Black", "Red", "White"],
  ),
  const EpaperDisplay(
    id: "2_9_bw",
    name: "2.9\" BW",
    widthMm: 66.9,
    heightMm: 29.1,
    resolution: 296,    
    imagePath: null,
    supportedColors: ["Black", "White"],
  ),
  const EpaperDisplay(
    id: "4_2_bwr",
    name: "4.2\" BWR",
    widthMm: 84.8,
    heightMm: 63.6,
    resolution: 400,  
    imagePath: null, 
    supportedColors: ["Black", "Red", "White"],
  ),
  const EpaperDisplay(
    id: "7_5_bw",
    name: "7.5\" BW",
    widthMm: 163.2,
    heightMm: 97.9,
    resolution: 800,   
    imagePath: null, 
    supportedColors: ["Black", "White"],
  ),
];
