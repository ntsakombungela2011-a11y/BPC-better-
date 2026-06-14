import 'package:flutter/material.dart';

/// Categories for organizing theme palettes.
enum ThemeCategory {
  named('Named', Icons.palette, 'Classic named themes'),
  gradient('Gradient', Icons.gradient, 'Gradient color combinations'),
  light('Light', Icons.wb_sunny, 'Light and airy themes'),
  dark('Dark', Icons.dark_mode, 'Dark and moody themes'),
  highContrast('High Contrast', Icons.contrast, 'Accessibility-focused themes'),
  gaming('Gaming', Icons.sports_esports, 'Vibrant gaming-inspired themes'),
  premium('Premium', Icons.star, 'Luxury and elegant themes'),
  japanese('Japanese', Icons.temple_buddhist, 'Traditional Japanese aesthetics'),
  nature('Nature', Icons.park, 'Natural and organic colors'),
  cool('Cool', Icons.ac_unit, 'Cool-toned color schemes'),
  warm('Warm', Icons.local_fire_department, 'Warm-toned color schemes'),
  purple('Purple', Icons.auto_awesome, 'Purple and magenta themes'),
  green('Green', Icons.eco, 'Green color themes'),
  earth('Earth', Icons.landscape, 'Earthy and natural tones'),
  blue('Blue', Icons.water, 'Blue color themes'),
  classic('Classic', Icons.diamond, 'Classic and royal themes'),
  neutral('Neutral', Icons.grain, 'Neutral and balanced themes');

  final String label;
  final IconData icon;
  final String description;

  const ThemeCategory(this.label, this.icon, this.description);
}