import 'package:flutter/material.dart';

enum ThemeCategory {
  named,
  gradient,
  light,
  dark,
  highContrast,
  premium,
  gaming,
  favorites,
  recent,
}

class ThemePalette {
  final String id;
  final String name;
  final List<Color> colors;
  final List<ThemeCategory> categories;

  const ThemePalette({
    required this.id,
    required this.name,
    required this.colors,
    required this.categories,
  });

  Color get primary => colors.first;
  Color get secondary => colors.length > 1 ? colors[1] : colors.first;
  Color? get tertiary => colors.length > 2 ? colors[2] : null;
  Color? get accent => colors.length > 3 ? colors[3] : null;
  Color? get background => colors.length > 4 ? colors[4] : null;

  static const List<ThemePalette> allPalettes = [
    ThemePalette(
      id: 'electric',
      name: 'Electric',
      colors: [
        Color(0xFF1B4FE4), // Cobalt
        Color(0xFFFF4757), // Coral
        Color(0xFFFFE100), // Lemon
        Color(0xFF00E59B), // Mint
        Color(0xFF0D0D0D), // Void
      ],
      categories: [
        ThemeCategory.named,
        ThemeCategory.gaming,
        ThemeCategory.premium,
      ],
    ),
    ThemePalette(
      id: 'wabi_sabi',
      name: 'Wabi-Sabi',
      colors: [
        Color(0xFFF4EEE0), // Washi
        Color(0xFF9E7B5A), // Umber
        Color(0xFF6B7C49), // Moss
        Color(0xFF2F2B24), // Sumi
        Color(0xFFEAE0D5), // Linen
      ],
      categories: [ThemeCategory.named, ThemeCategory.light],
    ),
    ThemePalette(
      id: 'coastal_edit',
      name: 'Coastal Edit',
      colors: [
        Color(0xFFE8D5B7), // Sand
        Color(0xFF2A7B9B), // Ocean
        Color(0xFFA8D8CF), // Sea Foam
        Color(0xFF8B6F47), // Driftwood
        Color(0xFFF2F7F5), // Mist
      ],
      categories: [ThemeCategory.named, ThemeCategory.light],
    ),
    ThemePalette(
      id: 'luxury_noir',
      name: 'Luxury Noir',
      colors: [
        Color(0xFF1A1A1A), // Jet
        Color(0xFFD4AF37), // Gold
        Color(0xFFF8F4E3), // Ivory
        Color(0xFF9C4B1B), // Cognac
        Color(0xFFE5E5E5), // Platinum
      ],
      categories: [
        ThemeCategory.named,
        ThemeCategory.dark,
        ThemeCategory.premium,
      ],
    ),
    ThemePalette(
      id: 'sage_clay',
      name: 'Sage & Clay',
      colors: [
        Color(0xFFB2C5A8), // Sage
        Color(0xFFC4785A), // Clay
        Color(0xFFF5F0E8), // Cream
        Color(0xFF7A8B8B), // Slate
        Color(0xFF5C4A3A), // Bark
      ],
      categories: [ThemeCategory.named, ThemeCategory.light],
    ),
    ThemePalette(
      id: 'solar_flare',
      name: 'Solar Flare',
      colors: [
        Color(0xFFFFAA00), // Solar Gold
        Color(0xFFE8003A), // Flare Crimson
      ],
      categories: [ThemeCategory.gradient, ThemeCategory.gaming],
    ),
    ThemePalette(
      id: 'neon_tide',
      name: 'Neon Tide',
      colors: [
        Color(0xFF00F5AA), // Neon Mint
        Color(0xFF3B00FF), // Electric Violet
      ],
      categories: [ThemeCategory.gradient, ThemeCategory.gaming],
    ),
    ThemePalette(
      id: 'arctic',
      name: 'Arctic',
      colors: [
        Color(0xFFE8F5FF), // Ice White
        Color(0xFF0050D8), // Polar Blue
      ],
      categories: [ThemeCategory.gradient, ThemeCategory.light],
    ),
    ThemePalette(
      id: 'dusk',
      name: 'Dusk',
      colors: [
        Color(0xFFFF5CBA), // Sunset Pink
        Color(0xFF2B00FF), // Deep Indigo
      ],
      categories: [ThemeCategory.gradient, ThemeCategory.dark],
    ),
    ThemePalette(
      id: 'berry_glow',
      name: 'Berry Glow',
      colors: [
        Color(0xFF9333EA), // Royal Berry
        Color(0xFFFB7185), // Glow Rose
      ],
      categories: [ThemeCategory.gradient, ThemeCategory.premium],
    ),
    ThemePalette(
      id: 'cotton_candy',
      name: 'Cotton Candy',
      colors: [
        Color(0xFF7AA8FF), // Sky Candy
        Color(0xFFFF9AEF), // Candy Pink
      ],
      categories: [ThemeCategory.gradient, ThemeCategory.light],
    ),
    ThemePalette(
      id: 'golden_ember',
      name: 'Golden Ember',
      colors: [
        Color(0xFFFACC15), // Golden Sun
        Color(0xFFF97316), // Ember Orange
      ],
      categories: [ThemeCategory.gradient, ThemeCategory.premium],
    ),
    ThemePalette(
      id: 'aqua_depth',
      name: 'Aqua Depth',
      colors: [
        Color(0xFF0F766E), // Deep Teal
        Color(0xFF22D3EE), // Aqua Cyan
      ],
      categories: [ThemeCategory.gradient, ThemeCategory.dark],
    ),
    ThemePalette(
      id: 'royal_flame',
      name: 'Royal Flame',
      colors: [
        Color(0xFFDB2777), // Royal Magenta
        Color(0xFFDC2626), // Flame Red
      ],
      categories: [ThemeCategory.gradient, ThemeCategory.premium],
    ),
    ThemePalette(
      id: 'dark_scarlet_antique_ruby',
      name: 'Dark Scarlet / Antique Ruby',
      colors: [
        Color(0xFF4F0715), // Dark Scarlet
        Color(0xFF781728), // Antique Ruby
      ],
      categories: [ThemeCategory.named, ThemeCategory.dark],
    ),
    ThemePalette(
      id: 'japanese_carmine_dark_slate_gray',
      name: 'Japanese Carmine / Dark Slate Gray',
      colors: [
        Color(0xFF982930), // Japanese Carmine
        Color(0xFF39544B), // Dark Slate Gray
      ],
      categories: [ThemeCategory.named, ThemeCategory.dark],
    ),
    ThemePalette(
      id: 'slate_blue_glacier',
      name: 'Slate Blue / Glacier',
      colors: [
        Color(0xFF619BB6), // Slate Blue
        Color(0xFFBAD7E1), // Glacier
      ],
      categories: [ThemeCategory.named, ThemeCategory.light],
    ),
    ThemePalette(
      id: 'thistle_liberty',
      name: 'Thistle / Liberty',
      colors: [
        Color(0xFFDEC2DB), // Thistle
        Color(0xFF5B62B3), // Liberty
      ],
      categories: [ThemeCategory.named, ThemeCategory.light],
    ),
    ThemePalette(
      id: 'stormy_teal_oxidized_iron_pale_oak',
      name: 'Stormy Teal / Oxidized Iron / Pale Oak',
      colors: [
        Color(0xFF32707C), // Stormy Teal
        Color(0xFFA8371C), // Oxidized Iron
        Color(0xFFD4C4B7), // Pale Oak
      ],
      categories: [ThemeCategory.named, ThemeCategory.light],
    ),
    ThemePalette(
      id: 'luxury_noir_soft_oat',
      name: 'Luxury Noir / Soft Oat',
      colors: [
        Color(0xFF060D0C), // Luxury Noir (Darker)
        Color(0xFFF0EDE5), // Soft Oat
      ],
      categories: [ThemeCategory.named, ThemeCategory.dark],
    ),
    ThemePalette(
      id: 'liver_tan',
      name: 'Liver / Tan',
      colors: [
        Color(0xFF6A3428), // Liver
        Color(0xFFCFB882), // Tan
      ],
      categories: [ThemeCategory.named, ThemeCategory.dark],
    ),
    ThemePalette(
      id: 'bistre_brown_sugar',
      name: 'Bistre / Brown Sugar',
      colors: [
        Color(0xFF3D2C22), // Bistre
        Color(0xFFBB734B), // Brown Sugar
      ],
      categories: [ThemeCategory.named, ThemeCategory.dark],
    ),
    ThemePalette(
      id: 'dark_gray_vivid_yellow',
      name: 'Dark Gray / Vivid Yellow',
      colors: [
        Color(0xFF323232), // Dark Gray
        Color(0xFFFFDB00), // Vivid Yellow
      ],
      categories: [
        ThemeCategory.named,
        ThemeCategory.dark,
        ThemeCategory.gaming,
      ],
    ),
    ThemePalette(
      id: 'jasmine_dark_graphite',
      name: 'Jasmine / Dark Graphite',
      colors: [
        Color(0xFFF8DE7F), // Jasmine
        Color(0xFF3A393F), // Dark Graphite
      ],
      categories: [ThemeCategory.named, ThemeCategory.dark],
    ),
    ThemePalette(
      id: 'deep_dark_blue_warm_yellow_orange',
      name: 'Deep Dark Blue / Warm Yellow Orange',
      colors: [
        Color(0xFF001F7B), // Deep Dark Blue
        Color(0xFFFFBA09), // Warm Yellow Orange
      ],
      categories: [
        ThemeCategory.named,
        ThemeCategory.dark,
        ThemeCategory.premium,
      ],
    ),
    ThemePalette(
      id: 'dark_green_neon_green',
      name: 'Dark Green / Neon Green',
      colors: [
        Color(0xFF01210A), // Dark Green
        Color(0xFFA8FF00), // Neon Green
      ],
      categories: [
        ThemeCategory.named,
        ThemeCategory.dark,
        ThemeCategory.gaming,
      ],
    ),
    ThemePalette(
      id: 'dark_rich_green_golden_yellow',
      name: 'Dark Rich Green / Golden Yellow',
      colors: [
        Color(0xFF014726), // Dark Rich Green
        Color(0xFFFFCF00), // Golden Yellow
      ],
      categories: [ThemeCategory.named, ThemeCategory.dark],
    ),
    ThemePalette(
      id: 'deep_rich_red_soft_yellow',
      name: 'Deep Rich Red / Soft Yellow',
      colors: [
        Color(0xFFAB1509), // Deep Rich Red
        Color(0xFFFFF8D2), // Soft Yellow
      ],
      categories: [ThemeCategory.named, ThemeCategory.dark],
    ),
    ThemePalette(
      id: 'dark_red_bright_warm_yellow',
      name: 'Dark Red / Bright Warm Yellow',
      colors: [
        Color(0xFFA01717), // Dark Red
        Color(0xFFFFE162), // Bright Warm Yellow
      ],
      categories: [ThemeCategory.named, ThemeCategory.dark],
    ),
    ThemePalette(
      id: 'matcha_cream_milky_honey',
      name: 'Matcha Cream / Milky Honey',
      colors: [
        Color(0xFF9CA763), // Matcha Cream
        Color(0xFFF1E8C7), // Milky Honey
      ],
      categories: [ThemeCategory.named, ThemeCategory.light],
    ),
    ThemePalette(
      id: 'coffee_bean_almond',
      name: 'Coffee Bean / Almond',
      colors: [
        Color(0xFF2E0D14), // Coffee Bean
        Color(0xFFEFE1D5), // Almond
      ],
      categories: [ThemeCategory.named, ThemeCategory.dark],
    ),
    ThemePalette(
      id: 'mocha_berry_soft_vanilla',
      name: 'Mocha Berry / Soft Vanilla',
      colors: [
        Color(0xFF784955), // Mocha Berry
        Color(0xFFFAEDDB), // Soft Vanilla
      ],
      categories: [ThemeCategory.named, ThemeCategory.dark],
    ),
    ThemePalette(
      id: 'twilight',
      name: 'Twilight',
      colors: [
        Color(0xFF564A96), // Twilight Purple
        Color(0xFFB75F67), // Twilight Rose
      ],
      categories: [ThemeCategory.named, ThemeCategory.dark],
    ),
    ThemePalette(
      id: 'blacklist_purple_transparent_pink',
      name: 'Blacklist Purple / Transparent Pink',
      colors: [
        Color(0xFF240A30), // Blacklist Purple
        Color(0xFFFFDCF0), // Transparent Pink
      ],
      categories: [ThemeCategory.named, ThemeCategory.dark],
    ),
    ThemePalette(
      id: 'magenta',
      name: 'Magenta',
      colors: [
        Color(0xFF4B0C37), // Deep Magenta
        Color(0xFFC8005A), // Bright Magenta
      ],
      categories: [
        ThemeCategory.named,
        ThemeCategory.dark,
        ThemeCategory.premium,
      ],
    ),
    ThemePalette(
      id: 'muted_blue_green_fresh_green',
      name: 'Muted Blue Green / Fresh Green',
      colors: [
        Color(0xFF162531), // Muted Blue Green
        Color(0xFF9AF376), // Fresh Green
      ],
      categories: [
        ThemeCategory.named,
        ThemeCategory.dark,
        ThemeCategory.gaming,
      ],
    ),
    ThemePalette(
      id: 'deep_rich_purple_light_cream',
      name: 'Deep Rich Purple / Light Cream',
      colors: [
        Color(0xFF720065), // Deep Rich Purple
        Color(0xFFFDF9B6), // Light Cream
      ],
      categories: [ThemeCategory.named, ThemeCategory.dark],
    ),
    ThemePalette(
      id: 'deep_royal_purple_soft_snow_white',
      name: 'Deep Royal Purple / Soft Snow White',
      colors: [
        Color(0xFF460B6A), // Deep Royal Purple
        Color(0xFFFFFBFF), // Soft Snow White
      ],
      categories: [ThemeCategory.named, ThemeCategory.dark],
    ),
    ThemePalette(
      id: 'deep_navy_vibrant_cyan',
      name: 'Deep Navy / Vibrant Cyan',
      colors: [
        Color(0xFF001935), // Deep Navy
        Color(0xFF2FE8FF), // Vibrant Cyan
      ],
      categories: [
        ThemeCategory.named,
        ThemeCategory.dark,
        ThemeCategory.gaming,
      ],
    ),
    ThemePalette(
      id: 'vanilla_latte_teal_forest',
      name: 'Vanilla Latte / Teal Forest',
      colors: [
        Color(0xFFEFE1D5), // Vanilla Latte
        Color(0xFF184E50), // Teal Forest
      ],
      categories: [ThemeCategory.named, ThemeCategory.light],
    ),
    ThemePalette(
      id: 'sage_black_olive',
      name: 'Sage / Black Olive',
      colors: [
        Color(0xFFB2B49C), // Sage
        Color(0xFF3B3B2A), // Black Olive
      ],
      categories: [ThemeCategory.named, ThemeCategory.dark],
    ),
    ThemePalette(
      id: 'old_rose_seashell_sky_reflection',
      name: 'Old Rose / Seashell / Sky Reflection',
      colors: [
        Color(0xFFE19AA6), // Old Rose
        Color(0xFFFAF0EA), // Seashell
        Color(0xFF82B0CE), // Sky Reflection
      ],
      categories: [ThemeCategory.named, ThemeCategory.light],
    ),
    ThemePalette(
      id: 'soft_fawn_carbon_black_ivory_mist',
      name: 'Soft Fawn / Carbon Black / Ivory Mist',
      colors: [
        Color(0xFFD5B572), // Soft Fawn
        Color(0xFF201F14), // Carbon Black
        Color(0xFFF8F2E1), // Ivory Mist
      ],
      categories: [ThemeCategory.named, ThemeCategory.dark],
    ),
    ThemePalette(
      id: 'onyx_olive_desert',
      name: 'Onyx / Olive / Desert',
      colors: [
        Color(0xFF13140E), // Onyx
        Color(0xFF838236), // Olive
        Color(0xFFDEDACF), // Desert
      ],
      categories: [ThemeCategory.named, ThemeCategory.dark],
    ),
    ThemePalette(
      id: 'fiery_rose_black_pearl',
      name: 'Fiery Rose / Black Pearl',
      colors: [
        Color(0xFFFF4D73), // Fiery Rose
        Color(0xFF00181B), // Black Pearl
      ],
      categories: [
        ThemeCategory.named,
        ThemeCategory.dark,
        ThemeCategory.gaming,
      ],
    ),
    ThemePalette(
      id: 'tranquil_orange_maastricht_blue',
      name: 'Tranquil Orange / Maastricht Blue',
      colors: [
        Color(0xFFFFB268), // Tranquil Orange
        Color(0xFF001E37), // Maastricht Blue
      ],
      categories: [ThemeCategory.named, ThemeCategory.dark],
    ),
    ThemePalette(
      id: 'sangria',
      name: 'Sangria',
      colors: [
        Color(0xFFC0392B), // Sangria Red
        Color(0xFF080205), // Midnight Black
      ],
      categories: [
        ThemeCategory.named,
        ThemeCategory.dark,
        ThemeCategory.premium,
      ],
    ),
    ThemePalette(
      id: 'forest_night',
      name: 'Forest Night',
      colors: [
        Color(0xFF0A1200), // Forest Night
        Color(0xFFBD5E85), // Orchid Rose
      ],
      categories: [ThemeCategory.named, ThemeCategory.dark],
    ),
    ThemePalette(
      id: 'burgundy',
      name: 'Burgundy',
      colors: [
        Color(0xFF4A1528), // Burgundy
      ],
      categories: [ThemeCategory.named, ThemeCategory.dark],
    ),
    ThemePalette(
      id: 'navy',
      name: 'Navy',
      colors: [
        Color(0xFF292F91), // Navy
      ],
      categories: [ThemeCategory.named, ThemeCategory.dark],
    ),
    ThemePalette(
      id: 'cyan_spark',
      name: 'Cyan Spark',
      colors: [
        Color(0xFF00D4FF), // Cyan Spark
      ],
      categories: [
        ThemeCategory.named,
        ThemeCategory.dark,
        ThemeCategory.gaming,
      ],
    ),
    ThemePalette(
      id: 'near_black',
      name: 'Near Black',
      colors: [
        Color(0xFF1A0508), // Near Black
      ],
      categories: [
        ThemeCategory.named,
        ThemeCategory.dark,
        ThemeCategory.highContrast,
      ],
    ),
  ];
}
