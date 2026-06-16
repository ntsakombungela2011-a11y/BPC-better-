import 'package:chessground/chessground.dart';
import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lichess_mobile/src/constants.dart';
import 'package:lichess_mobile/src/model/common/chess.dart';
import 'package:lichess_mobile/src/model/settings/board_preferences.dart';
import 'package:lichess_mobile/src/model/settings/general_preferences.dart';
import 'package:lichess_mobile/src/styles/lichess_icons.dart';
import 'package:lichess_mobile/src/styles/styles.dart';
import 'package:lichess_mobile/src/theme_system.dart';
import 'package:lichess_mobile/src/utils/color_palette.dart';
import 'package:lichess_mobile/src/utils/l10n_context.dart';
import 'package:lichess_mobile/src/utils/navigation.dart';
import 'package:lichess_mobile/src/utils/screen.dart';
import 'package:lichess_mobile/src/view/settings/background_theme_choice_screen.dart';
import 'package:lichess_mobile/src/view/settings/board_choice_screen.dart';
import 'package:lichess_mobile/src/view/settings/piece_set_screen.dart';
import 'package:lichess_mobile/src/widgets/adaptive_choice_picker.dart';
import 'package:lichess_mobile/src/widgets/list.dart';
import 'package:lichess_mobile/src/widgets/settings.dart';

class ThemeSettingsScreen extends ConsumerWidget {
  const ThemeSettingsScreen({super.key});

  static Route<dynamic> buildRoute() {
    return buildScreenRoute(screen: const ThemeSettingsScreen());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.mobileTheme), animateColor: true),
      body: const _Body(),
    );
  }
}

String shapeColorL10n(ShapeColor shapeColor) => switch (shapeColor) {
  ShapeColor.green => 'Green',
  ShapeColor.red => 'Red',
  ShapeColor.blue => 'Blue',
  ShapeColor.yellow => 'Yellow',
};

class _Body extends ConsumerStatefulWidget {
  const _Body();

  @override
  ConsumerState<_Body> createState() => _BodyState();
}

class _BodyState extends ConsumerState<_Body> {
  late double brightness;
  late double hue;

  bool openAdjustColorSection = false;

  @override
  void initState() {
    super.initState();
    final boardPrefs = ref.read(boardPreferencesProvider);
    brightness = boardPrefs.brightness;
    hue = boardPrefs.hue;
  }

  @override
  Widget build(BuildContext context) {
    final generalPrefs = ref.watch(generalPreferencesProvider);
    final boardPrefs = ref.watch(boardPreferencesProvider);

    final bool hasAjustedColors =
        brightness != kBoardDefaultBrightnessFilter || hue != kBoardDefaultHueFilter;

    final boardSize = isTabletOrLarger(context) ? 350.0 : 200.0;

    return SafeArea(
      top: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: _BoardPreview(
              size: boardSize,
              boardPrefs: boardPrefs,
              brightness: brightness,
              hue: hue,
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                ListSection(
                  hasLeading: true,
                  children: [
                    if (getCorePalette() != null)
                      SwitchSettingTile(
                        leading: const Icon(Icons.colorize_outlined),
                        title: Text(context.l10n.mobileSystemColors),
                        value: generalPrefs.systemColors,
                        onChanged: (value) {
                          ref.read(generalPreferencesProvider.notifier).toggleSystemColors();
                        },
                      ),
                    SettingsListTile(
                      icon: const Icon(Icons.wallpaper),
                      settingsLabel: Text(context.l10n.background),
                      settingsValue: generalPrefs.backgroundColor != null
                          ? generalPrefs.backgroundColor!.$1.label
                          : (generalPrefs.backgroundImage != null ? 'Image' : 'Default'),
                      onTap: () {
                        Navigator.of(context).push(BackgroundChoiceScreen.buildRoute());
                      },
                    ),
                    if (generalPrefs.backgroundColor != null ||
                        generalPrefs.backgroundImage != null)
                      ListTile(
                        leading: const Icon(Icons.cancel),
                        title: const Text('Reset background'),
                        onTap: () {
                          ref
                              .read(generalPreferencesProvider.notifier)
                              .setBackground(backgroundColor: null, backgroundImage: null);
                        },
                      ),
                    SettingsListTile(
                      icon: const Icon(LichessIcons.chess_board),
                      settingsLabel: Text(context.l10n.board),
                      settingsValue: boardPrefs.boardTheme.label,
                      onTap: () {
                        Navigator.of(context).push(BoardChoiceScreen.buildRoute());
                      },
                    ),
                    SettingsListTile(
                      icon: const Icon(LichessIcons.chess_pawn),
                      settingsLabel: Text(context.l10n.pieceSet),
                      settingsValue: boardPrefs.pieceSet.label,
                      onTap: () {
                        Navigator.of(context).push(PieceSetScreen.buildRoute());
                      },
                    ),
                    SettingsListTile(
                      icon: const Icon(LichessIcons.arrow_full_upperright),
                      settingsLabel: const Text('Drawn shape color'),
                      explanation:
                          'This color is only used for shapes drawn by hand using two fingers.',
                      settingsValue: shapeColorL10n(boardPrefs.shapeColor),
                      onTap: () {
                        showChoicePicker(
                          context,
                          choices: ShapeColor.values,
                          selectedItem: boardPrefs.shapeColor,
                          labelBuilder: (t) => Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(text: shapeColorL10n(t)),
                                const TextSpan(text: '   '),
                                WidgetSpan(child: Container(width: 15, height: 15, color: t.color)),
                              ],
                            ),
                          ),
                          onSelectedItemChanged: (ShapeColor? value) {
                            ref
                                .read(boardPreferencesProvider.notifier)
                                .setShapeColor(value ?? ShapeColor.green);
                          },
                        );
                      },
                    ),
                    SwitchSettingTile(
                      leading: const Icon(Icons.location_on),
                      title: Text(context.l10n.preferencesBoardCoordinates),
                      value: boardPrefs.coordinates,
                      onChanged: (value) {
                        ref.read(boardPreferencesProvider.notifier).toggleCoordinates();
                      },
                    ),
                    SwitchSettingTile(
                      // TODO translate
                      leading: const Icon(Icons.border_outer),
                      title: const Text('Show border'),
                      value: boardPrefs.showBorder,
                      onChanged: (value) {
                        ref.read(boardPreferencesProvider.notifier).toggleBorder();
                      },
                    ),
                  ],
                ),

                const _ThemePickerSection(),
                ListSection(
                  header: SettingsSectionTitle(context.l10n.advancedSettings),
                  hasLeading: true,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.brightness_6),
                      title: Slider.adaptive(
                        min: 0.2,
                        max: 1.4,
                        value: brightness,
                        onChanged: (value) {
                          setState(() {
                            brightness = value;
                          });
                        },
                        onChangeEnd: (value) {
                          ref
                              .read(boardPreferencesProvider.notifier)
                              .adjustColors(brightness: brightness);
                        },
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.invert_colors),
                      title: Slider.adaptive(
                        min: 0.0,
                        max: 360.0,
                        value: hue,
                        onChanged: (value) {
                          setState(() {
                            hue = value;
                          });
                        },
                        onChangeEnd: (value) {
                          ref.read(boardPreferencesProvider.notifier).adjustColors(hue: hue);
                        },
                      ),
                    ),
                    ListTile(
                      enabled: hasAjustedColors,
                      leading: const Icon(Icons.cancel),
                      title: Text(context.l10n.boardReset),
                      onTap: hasAjustedColors
                          ? () {
                              setState(() {
                                brightness = kBoardDefaultBrightnessFilter;
                                hue = kBoardDefaultHueFilter;
                              });
                              ref
                                  .read(boardPreferencesProvider.notifier)
                                  .adjustColors(brightness: brightness, hue: hue);
                            }
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BoardPreview extends StatelessWidget {
  const _BoardPreview({
    required this.size,
    required this.boardPrefs,
    required this.brightness,
    required this.hue,
  });

  final BoardPrefs boardPrefs;
  final double brightness;
  final double hue;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: StaticChessboard(
        size: size,
        orientation: Side.white,
        lastMove: const NormalMove(from: Square.e2, to: Square.e4),
        fen: 'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
        shapes: {
          Circle(color: boardPrefs.shapeColor.color, orig: Square.fromName('b8')),
          Arrow(
            color: boardPrefs.shapeColor.color,
            orig: Square.fromName('b8'),
            dest: Square.fromName('c6'),
          ),
        },
        settings: StaticChessboardSettings.fromBoardSettings(
          boardPrefs
              .toBoardSettings(Variant.standard)
              .copyWith(
                brightness: brightness,
                hue: hue,
                borderRadius: Styles.boardBorderRadius,
                boxShadow: boardShadows,
              ),
        ),
      ),
    );
  }
}


class _ThemePickerSection extends StatefulWidget {
  const _ThemePickerSection();

  @override
  State<_ThemePickerSection> createState() => _ThemePickerSectionState();
}

class _ThemePickerSectionState extends State<_ThemePickerSection> {
  String _query = '';
  ThemeCategory? _category;

  @override
  Widget build(BuildContext context) {
    final filteredThemes = ThemeRegistry.search(_query, category: _category);
    final categories = ThemeCategory.values;

    return ListSection(
      header: const SettingsSectionTitle('App palette'),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              labelText: 'Search themes',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => setState(() => _query = value),
          ),
        ),
        SizedBox(
          height: 48,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final category = index == 0 ? null : categories[index - 1];
              final selected = _category == category;
              return ChoiceChip(
                label: Text(category?.name ?? 'All'),
                selected: selected,
                onSelected: (_) => setState(() => _category = category),
              );
            },
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemCount: categories.length + 1,
          ),
        ),
        if (ThemeManager.instance.recentThemes.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Recent themes', style: Theme.of(context).textTheme.titleSmall),
            ),
          ),
        if (ThemeManager.instance.recentThemes.isNotEmpty)
          SizedBox(
            height: 44,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final theme = ThemeManager.instance.recentThemes[index];
                return ActionChip(
                  avatar: CircleAvatar(backgroundColor: theme.palette.primary),
                  label: Text(theme.name),
                  onPressed: () => ThemeManager.instance.applyTheme(theme),
                );
              },
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemCount: ThemeManager.instance.recentThemes.length,
            ),
          ),
        ValueListenableBuilder<ThemeModel>(
          valueListenable: ThemeManager.instance.currentTheme,
          builder: (context, selectedTheme, _) {
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                mainAxisExtent: 132,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemCount: filteredThemes.length,
              itemBuilder: (context, index) {
                final theme = filteredThemes[index];
                return _ThemePreviewCard(
                  theme: theme,
                  selected: selectedTheme.id == theme.id,
                  favorite: ThemeManager.instance.favoriteThemeIds.contains(theme.id),
                  onFavoriteChanged: () => setState(() {}),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _ThemePreviewCard extends StatelessWidget {
  const _ThemePreviewCard({required this.theme, required this.selected, required this.favorite, required this.onFavoriteChanged});

  final ThemeModel theme;
  final bool selected;
  final bool favorite;
  final VoidCallback onFavoriteChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = theme.colorScheme(Theme.of(context).brightness);
    return Card(
      clipBehavior: Clip.antiAlias,
      color: scheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: selected ? scheme.primary : scheme.outlineVariant, width: selected ? 3 : 1),
      ),
      child: InkWell(
        onTap: () => ThemeManager.instance.applyTheme(theme),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(theme.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: scheme.onSurface, fontWeight: FontWeight.w700)),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: Icon(favorite ? Icons.star : Icons.star_border, color: scheme.secondary),
                    onPressed: () async {
                      await ThemeManager.instance.toggleFavorite(theme);
                      onFavoriteChanged();
                    },
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  for (final color in [theme.palette.primary, theme.palette.secondary, theme.palette.tertiary, theme.palette.background])
                    Expanded(child: Container(height: 28, color: color)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: Container(height: 10, decoration: BoxDecoration(color: scheme.primaryContainer, borderRadius: BorderRadius.circular(999)))),
                  const SizedBox(width: 8),
                  Icon(selected ? Icons.check_circle : Icons.radio_button_unchecked, color: scheme.primary, size: 18),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
