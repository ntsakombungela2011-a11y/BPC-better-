import 'package:flutter/material.dart';
import 'package:lichess_mobile/src/model/theme/theme_category.dart';

/// Represents a color in a theme palette.
class PaletteColor {
  final String name;
  final Color color;

  const PaletteColor(this.name, this.color);
}

/// A theme palette containing a collection of colors.
class ThemePalette {
  final String id;
  final String name;
  final ThemeCategory category;
  final List<PaletteColor> colors;
  final String? description;

  const ThemePalette({
    required this.id,
    required this.name,
    required this.category,
    required this.colors,
    this.description,
  });

  /// Returns the primary color (first color in the list).
  Color get primaryColor => colors.isNotEmpty ? colors.first.color : Colors.blue;

  /// Returns the secondary color (second in the list, or primary if only one).
  Color get secondaryColor => colors.length > 1 ? colors[1].color : primaryColor;

  /// Returns the tertiary color (third in the list, or secondary if only two, or primary if only one).
  Color get tertiaryColor {
    if (colors.length > 2) return colors[2].color;
    return secondaryColor;
  }

  /// Returns the surface color (last color in the list if at least 4 colors, else uses primary/black logic).
  Color get surfaceColor {
    if (colors.length >= 4) return colors.last.color;
    return primaryColor.computeLuminance() > 0.5 ? Colors.white : const Color(0xFF0D0D0D);
  }

  /// Returns a display name combining palette name with color names.
  String get displayName => name;

  /// Returns whether this palette is a gradient palette (2 colors).
  bool get isGradient => colors.length >= 2;
}

/// All available theme palettes.
class ThemePalettes {
  ThemePalettes._();

  static const List<ThemePalette> all = [
    ThemePalette(
      id: 'electric',
      name: 'Electric',
      category: ThemeCategory.gaming,
      colors: [
        PaletteColor('Cobalt', Color(0xFF1B4FE4)), PaletteColor('Coral', Color(0xFFFF4757)), PaletteColor('Lemon', Color(0xFFFFE100)), PaletteColor('Mint', Color(0xFF00E59B)), PaletteColor('Void', Color(0xFF0D0D0D))
      ],
    ),
    ThemePalette(
      id: 'wabi_sabi',
      name: 'Wabi-Sabi',
      category: ThemeCategory.nature,
      colors: [
        PaletteColor('Washi', Color(0xFFF4EEE0)), PaletteColor('Umber', Color(0xFF9E7B5A)), PaletteColor('Moss', Color(0xFF6B7C49)), PaletteColor('Sumi', Color(0xFF2F2B24)), PaletteColor('Linen', Color(0xFFEAE0D5))
      ],
    ),
    ThemePalette(
      id: 'coastal_edit',
      name: 'Coastal Edit',
      category: ThemeCategory.nature,
      colors: [
        PaletteColor('Sand', Color(0xFFE8D5B7)), PaletteColor('Ocean', Color(0xFF2A7B9B)), PaletteColor('Sea Foam', Color(0xFFA8D8CF)), PaletteColor('Driftwood', Color(0xFF8B6F47)), PaletteColor('Mist', Color(0xFFF2F7F5))
      ],
    ),
    ThemePalette(
      id: 'luxury_noir',
      name: 'Luxury Noir',
      category: ThemeCategory.premium,
      colors: [
        PaletteColor('Jet', Color(0xFF1A1A1A)), PaletteColor('Gold', Color(0xFFD4AF37)), PaletteColor('Ivory', Color(0xFFF8F4E3)), PaletteColor('Cognac', Color(0xFF9C4B1B)), PaletteColor('Platinum', Color(0xFFE5E5E5))
      ],
    ),
    ThemePalette(
      id: 'sage_and_clay',
      name: 'Sage & Clay',
      category: ThemeCategory.nature,
      colors: [
        PaletteColor('Sage', Color(0xFFB2C5A8)), PaletteColor('Clay', Color(0xFFC4785A)), PaletteColor('Cream', Color(0xFFF5F0E8)), PaletteColor('Slate', Color(0xFF7A8B8B)), PaletteColor('Bark', Color(0xFF5C4A3A))
      ],
    ),
    ThemePalette(
      id: 'solar_flare',
      name: 'Solar Flare',
      category: ThemeCategory.warm,
      colors: [
        PaletteColor('Solar Gold', Color(0xFFFFAA00)), PaletteColor('Flare Crimson', Color(0xFFE8003A))
      ],
    ),
    ThemePalette(
      id: 'neon_tide',
      name: 'Neon Tide',
      category: ThemeCategory.gradient,
      colors: [
        PaletteColor('Neon Mint', Color(0xFF00F5AA)), PaletteColor('Electric Violet', Color(0xFF3B00FF))
      ],
    ),
    ThemePalette(
      id: 'arctic',
      name: 'Arctic',
      category: ThemeCategory.cool,
      colors: [
        PaletteColor('Ice White', Color(0xFFE8F5FF)), PaletteColor('Polar Blue', Color(0xFF0050D8))
      ],
    ),
    ThemePalette(
      id: 'dusk',
      name: 'Dusk',
      category: ThemeCategory.purple,
      colors: [
        PaletteColor('Sunset Pink', Color(0xFFFF5CBA)), PaletteColor('Deep Indigo', Color(0xFF2B00FF))
      ],
    ),
    ThemePalette(
      id: 'berry_glow',
      name: 'Berry Glow',
      category: ThemeCategory.warm,
      colors: [
        PaletteColor('Royal Berry', Color(0xFF9333EA)), PaletteColor('Glow Rose', Color(0xFFFB7185))
      ],
    ),
    ThemePalette(
      id: 'cotton_candy',
      name: 'Cotton Candy',
      category: ThemeCategory.warm,
      colors: [
        PaletteColor('Sky Candy', Color(0xFF7AA8FF)), PaletteColor('Candy Pink', Color(0xFFFF9AEF))
      ],
    ),
    ThemePalette(
      id: 'golden_ember',
      name: 'Golden Ember',
      category: ThemeCategory.warm,
      colors: [
        PaletteColor('Golden Sun', Color(0xFFFACC15)), PaletteColor('Ember Orange', Color(0xFFF97316))
      ],
    ),
    ThemePalette(
      id: 'aqua_depth',
      name: 'Aqua Depth',
      category: ThemeCategory.blue,
      colors: [
        PaletteColor('Deep Teal', Color(0xFF0F766E)), PaletteColor('Aqua Cyan', Color(0xFF22D3EE))
      ],
    ),
    ThemePalette(
      id: 'royal_flame',
      name: 'Royal Flame',
      category: ThemeCategory.classic,
      colors: [
        PaletteColor('Royal Magenta', Color(0xFFDB2777)), PaletteColor('Flame Red', Color(0xFFDC2626))
      ],
    ),
    ThemePalette(
      id: 'dark_scarlet_antique_ruby',
      name: 'Dark Scarlet / Antique Ruby',
      category: ThemeCategory.dark,
      colors: [
        PaletteColor('Dark Scarlet', Color(0xFF4F0715)), PaletteColor('Antique Ruby', Color(0xFF781728))
      ],
    ),
    ThemePalette(
      id: 'japanese_carmine_dark_slate_gray',
      name: 'Japanese Carmine / Dark Slate Gray',
      category: ThemeCategory.japanese,
      colors: [
        PaletteColor('Japanese Carmine', Color(0xFF982930)), PaletteColor('Dark Slate Gray', Color(0xFF39544B))
      ],
    ),
    ThemePalette(
      id: 'slate_blue_glacier',
      name: 'Slate Blue / Glacier',
      category: ThemeCategory.blue,
      colors: [
        PaletteColor('Slate Blue', Color(0xFF619BB6)), PaletteColor('Glacier', Color(0xFFBAD7E1))
      ],
    ),
    ThemePalette(
      id: 'thistle_liberty',
      name: 'Thistle / Liberty',
      category: ThemeCategory.purple,
      colors: [
        PaletteColor('Thistle', Color(0xFFDEC2DB)), PaletteColor('Liberty', Color(0xFF5B62B3))
      ],
    ),
    ThemePalette(
      id: 'stormy_teal_oxidized_iron_pale_oak',
      name: 'Stormy Teal / Oxidized Iron / Pale Oak',
      category: ThemeCategory.neutral,
      colors: [
        PaletteColor('Stormy Teal', Color(0xFF32707C)), PaletteColor('Oxidized Iron', Color(0xFFA8371C)), PaletteColor('Pale Oak', Color(0xFFD4C4B7))
      ],
    ),
    ThemePalette(
      id: 'luxury_noir_soft_oat',
      name: 'Luxury Noir / Soft Oat',
      category: ThemeCategory.premium,
      colors: [
        PaletteColor('Luxury Noir', Color(0xFF060D0C)), PaletteColor('Soft Oat', Color(0xFFF0EDE5))
      ],
    ),
    ThemePalette(
      id: 'liver_tan',
      name: 'Liver / Tan',
      category: ThemeCategory.earth,
      colors: [
        PaletteColor('Liver', Color(0xFF6A3428)), PaletteColor('Tan', Color(0xFFCFB882))
      ],
    ),
    ThemePalette(
      id: 'bistre_brown_sugar',
      name: 'Bistre / Brown Sugar',
      category: ThemeCategory.earth,
      colors: [
        PaletteColor('Bistre', Color(0xFF3D2C22)), PaletteColor('Brown Sugar', Color(0xFFBB734B))
      ],
    ),
    ThemePalette(
      id: 'dark_gray_vivid_yellow',
      name: 'Dark Gray / Vivid Yellow',
      category: ThemeCategory.dark,
      colors: [
        PaletteColor('Dark Gray', Color(0xFF323232)), PaletteColor('Vivid Yellow', Color(0xFFFFDB00))
      ],
    ),
    ThemePalette(
      id: 'jasmine_dark_graphite',
      name: 'Jasmine / Dark Graphite',
      category: ThemeCategory.classic,
      colors: [
        PaletteColor('Jasmine', Color(0xFFF8DE7F)), PaletteColor('Dark Graphite', Color(0xFF3A393F))
      ],
    ),
    ThemePalette(
      id: 'deep_dark_blue_warm_yellow_orange',
      name: 'Deep Dark Blue / Warm Yellow Orange',
      category: ThemeCategory.blue,
      colors: [
        PaletteColor('Deep Dark Blue', Color(0xFF001F7B)), PaletteColor('Warm Yellow Orange', Color(0xFFFFBA09))
      ],
    ),
    ThemePalette(
      id: 'dark_green_neon_green',
      name: 'Dark Green / Neon Green',
      category: ThemeCategory.green,
      colors: [
        PaletteColor('Dark Green', Color(0xFF01210A)), PaletteColor('Neon Green', Color(0xFFA8FF00))
      ],
    ),
    ThemePalette(
      id: 'dark_rich_green_golden_yellow',
      name: 'Dark Rich Green / Golden Yellow',
      category: ThemeCategory.green,
      colors: [
        PaletteColor('Dark Rich Green', Color(0xFF014726)), PaletteColor('Golden Yellow', Color(0xFFFFCF00))
      ],
    ),
    ThemePalette(
      id: 'deep_rich_red_soft_yellow',
      name: 'Deep Rich Red / Soft Yellow',
      category: ThemeCategory.dark,
      colors: [
        PaletteColor('Deep Rich Red', Color(0xFFAB1509)), PaletteColor('Soft Yellow', Color(0xFFFFF8D2))
      ],
    ),
    ThemePalette(
      id: 'dark_red_bright_warm_yellow',
      name: 'Dark Red / Bright Warm Yellow',
      category: ThemeCategory.dark,
      colors: [
        PaletteColor('Dark Red', Color(0xFFA01717)), PaletteColor('Bright Warm Yellow', Color(0xFFFFE162))
      ],
    ),
    ThemePalette(
      id: 'matcha_cream_milky_honey',
      name: 'Matcha Cream / Milky Honey',
      category: ThemeCategory.neutral,
      colors: [
        PaletteColor('Matcha Cream', Color(0xFF9CA763)), PaletteColor('Milky Honey', Color(0xFFF1E8C7))
      ],
    ),
    ThemePalette(
      id: 'coffee_bean_almond',
      name: 'Coffee Bean / Almond',
      category: ThemeCategory.earth,
      colors: [
        PaletteColor('Coffee Bean', Color(0xFF2E0D14)), PaletteColor('Almond', Color(0xFFEFE1D5))
      ],
    ),
    ThemePalette(
      id: 'mocha_berry_soft_vanilla',
      name: 'Mocha Berry / Soft Vanilla',
      category: ThemeCategory.earth,
      colors: [
        PaletteColor('Mocha Berry', Color(0xFF784955)), PaletteColor('Soft Vanilla', Color(0xFFFAEDDB))
      ],
    ),
    ThemePalette(
      id: 'twilight',
      name: 'Twilight',
      category: ThemeCategory.classic,
      colors: [
        PaletteColor('Twilight Purple', Color(0xFF564A96)), PaletteColor('Twilight Rose', Color(0xFFB75F67))
      ],
    ),
    ThemePalette(
      id: 'blacklist_purple_transparent_pink',
      name: 'Blacklist Purple / Transparent Pink',
      category: ThemeCategory.purple,
      colors: [
        PaletteColor('Blacklist Purple', Color(0xFF240A30)), PaletteColor('Transparent Pink', Color(0xFFFFDCF0))
      ],
    ),
    ThemePalette(
      id: 'magenta',
      name: 'Magenta',
      category: ThemeCategory.purple,
      colors: [
        PaletteColor('Deep Magenta', Color(0xFF4B0C37)), PaletteColor('Bright Magenta', Color(0xFFC8005A))
      ],
    ),
    ThemePalette(
      id: 'muted_blue_green_fresh_green',
      name: 'Muted Blue Green / Fresh Green',
      category: ThemeCategory.green,
      colors: [
        PaletteColor('Muted Blue Green', Color(0xFF162531)), PaletteColor('Fresh Green', Color(0xFF9AF376))
      ],
    ),
    ThemePalette(
      id: 'deep_rich_purple_light_cream',
      name: 'Deep Rich Purple / Light Cream',
      category: ThemeCategory.purple,
      colors: [
        PaletteColor('Deep Rich Purple', Color(0xFF720065)), PaletteColor('Light Cream', Color(0xFFFDF9B6))
      ],
    ),
    ThemePalette(
      id: 'deep_royal_purple_soft_snow_white',
      name: 'Deep Royal Purple / Soft Snow White',
      category: ThemeCategory.purple,
      colors: [
        PaletteColor('Deep Royal Purple', Color(0xFF460B6A)), PaletteColor('Soft Snow White', Color(0xFFFFFBFF))
      ],
    ),
    ThemePalette(
      id: 'deep_navy_vibrant_cyan',
      name: 'Deep Navy / Vibrant Cyan',
      category: ThemeCategory.blue,
      colors: [
        PaletteColor('Deep Navy', Color(0xFF001935)), PaletteColor('Vibrant Cyan', Color(0xFF2FE8FF))
      ],
    ),
    ThemePalette(
      id: 'vanilla_latte_teal_forest',
      name: 'Vanilla Latte / Teal Forest',
      category: ThemeCategory.earth,
      colors: [
        PaletteColor('Vanilla Latte', Color(0xFFEFE1D5)), PaletteColor('Teal Forest', Color(0xFF184E50))
      ],
    ),
    ThemePalette(
      id: 'sage_black_olive',
      name: 'Sage / Black Olive',
      category: ThemeCategory.nature,
      colors: [
        PaletteColor('Sage', Color(0xFFB2B49C)), PaletteColor('Black Olive', Color(0xFF3B3B2A))
      ],
    ),
    ThemePalette(
      id: 'old_rose_seashell_sky_reflection',
      name: 'Old Rose / Seashell / Sky Reflection',
      category: ThemeCategory.neutral,
      colors: [
        PaletteColor('Old Rose', Color(0xFFE19AA6)), PaletteColor('Seashell', Color(0xFFFAF0EA)), PaletteColor('Sky Reflection', Color(0xFF82B0CE))
      ],
    ),
    ThemePalette(
      id: 'soft_fawn_carbon_black_ivory_mist',
      name: 'Soft Fawn / Carbon Black / Ivory Mist',
      category: ThemeCategory.neutral,
      colors: [
        PaletteColor('Soft Fawn', Color(0xFFD5B572)), PaletteColor('Carbon Black', Color(0xFF201F14)), PaletteColor('Ivory Mist', Color(0xFFF8F2E1))
      ],
    ),
    ThemePalette(
      id: 'onyx_olive_desert',
      name: 'Onyx / Olive / Desert',
      category: ThemeCategory.neutral,
      colors: [
        PaletteColor('Onyx', Color(0xFF13140E)), PaletteColor('Olive', Color(0xFF838236)), PaletteColor('Desert', Color(0xFFDEDACF))
      ],
    ),
    ThemePalette(
      id: 'fiery_rose_black_pearl',
      name: 'Fiery Rose / Black Pearl',
      category: ThemeCategory.classic,
      colors: [
        PaletteColor('Fiery Rose', Color(0xFFFF4D73)), PaletteColor('Black Pearl', Color(0xFF00181B))
      ],
    ),
    ThemePalette(
      id: 'tranquil_orange_maastricht_blue',
      name: 'Tranquil Orange / Maastricht Blue',
      category: ThemeCategory.classic,
      colors: [
        PaletteColor('Tranquil Orange', Color(0xFFFFB268)), PaletteColor('Maastricht Blue', Color(0xFF001E37))
      ],
    ),
    ThemePalette(
      id: 'sangria',
      name: 'Sangria',
      category: ThemeCategory.classic,
      colors: [
        PaletteColor('Sangria Red', Color(0xFFC0392B)), PaletteColor('Midnight Black', Color(0xFF080205))
      ],
    ),
    ThemePalette(
      id: 'forest_night',
      name: 'Forest Night',
      category: ThemeCategory.dark,
      colors: [
        PaletteColor('Forest Night', Color(0xFF0A1200)), PaletteColor('Orchid Rose', Color(0xFFBD5E85))
      ],
    ),
    ThemePalette(
      id: 'burgundy',
      name: 'Burgundy',
      category: ThemeCategory.classic,
      colors: [
        PaletteColor('Burgundy', Color(0xFF4A1528))
      ],
    ),
    ThemePalette(
      id: 'navy',
      name: 'Navy',
      category: ThemeCategory.blue,
      colors: [
        PaletteColor('Navy', Color(0xFF292F91))
      ],
    ),
    ThemePalette(
      id: 'cyan_spark',
      name: 'Cyan Spark',
      category: ThemeCategory.blue,
      colors: [
        PaletteColor('Cyan Spark', Color(0xFF00D4FF))
      ],
    ),
    ThemePalette(
      id: 'near_black',
      name: 'Near Black',
      category: ThemeCategory.dark,
      colors: [
        PaletteColor('Near Black', Color(0xFF1A0508))
      ],
    ),
  ];

  /// Get a palette by its ID.
  static ThemePalette? getById(String id) {
    try {
      return all.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get all palettes in a specific category.
  static List<ThemePalette> getByCategory(ThemeCategory category) {
    return all.where((p) => p.category == category).toList();
  }

  /// Search palettes by name.
  static List<ThemePalette> search(String query) {
    final lowerQuery = query.toLowerCase();
    return all.where((p) {
      return p.name.toLowerCase().contains(lowerQuery) ||
          p.colors.any((c) => c.name.toLowerCase().contains(lowerQuery));
    }).toList();
  }
}
