enum FilterType { none, dithering }

extension FilterTypeExtension on FilterType {
  String get name {
    switch (this) {
      case FilterType.none:
        return 'None';
      case FilterType.dithering:
        return 'Dithering';
    }
  }

  String get description {
    switch (this) {
      case FilterType.none:
        return 'Original image without processing';
      case FilterType.dithering:
        return 'Floyd-Steinberg dithering';
    }
  }
}