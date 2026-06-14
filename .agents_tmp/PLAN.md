# 1. OBJECTIVE

Implement a complete, production-ready theme system for the Lichess Mobile app with:
- Centralized ThemeManager with all 60+ palettes
- Dynamic color generation engine
- Theme persistence and live switching
- Theme browser with search, categories, favorites, and recently used themes
- Instant theme application across all screens without restart
- Smooth animations and transitions
- Full accessibility compliance with contrast ratios

Additionally, remove Play Store deployment infrastructure while preserving APK/AAB builds and GitHub Releases.

# 2. CONTEXT SUMMARY

## Current State
- Basic theme system exists in `lib/src/theme.dart` with limited customization
- Background colors limited to 10 predefined options (`BackgroundColor` enum)
- Board themes from chessground package (22 themes)
- Theme settings screen in `lib/src/view/settings/theme_settings_screen.dart`
- Theme preferences stored in `lib/src/model/settings/general_preferences.dart`

## Play Store Infrastructure to Remove
- `.github/workflows/deploy_play_store.yml` - main Play Store deployment workflow
- `android/fastlane/Fastfile` - contains Play Store upload lanes (internal, alpha, production)
- `android/fastlane/Appfile` - package name configuration
- References to `PLAY_STORE_*` secrets in workflows

## Files to Create/Modify
### New Files (Theme System):
- `lib/src/model/settings/theme_preferences.dart` - Theme preferences provider
- `lib/src/model/theme/theme_palette.dart` - All 60+ theme palette definitions
- `lib/src/model/theme/theme_colors.dart` - Color generation and accessibility
- `lib/src/model/theme/theme_category.dart` - Theme categories enum
- `lib/src/model/theme/theme_manager.dart` - Centralized theme management
- `lib/src/view/settings/theme_browser_screen.dart` - Theme browser UI
- `lib/src/widgets/theme_preview_card.dart` - Theme preview widget

### Modified Files:
- `lib/src/theme.dart` - Extend for new theme system
- `lib/src/app.dart` - Integrate theme provider
- `lib/src/model/settings/general_preferences.dart` - Add theme selection
- `lib/src/view/settings/theme_settings_screen.dart` - Add theme browser access
- `lib/src/view/settings/settings_screen.dart` - Add theme browser link

# 3. APPROACH OVERVIEW

## Theme System Architecture

1. **ThemeModel Layer** - Immutable data classes for themes using Freezed
2. **ThemeManager Layer** - Riverpod provider managing state, persistence, and theme application
3. **ColorEngine Layer** - Dynamic color generation from seed colors with accessibility validation
4. **UI Layer** - Theme browser, preview cards, and theme selection screens

## Implementation Strategy

1. Define all 60+ palettes as structured data with primary colors and metadata
2. Implement color generation engine that creates full color scheme from seed
3. Build accessibility checker that ensures contrast ratios meet WCAG AA
4. Create theme manager with favorites, recent, and search functionality
5. Build theme browser UI with grid view, filters, and instant preview
6. Integrate with existing theme.dart for Material theme generation
7. Remove Play Store workflow and related Fastfile content

# 4. IMPLEMENTATION STEPS

## Phase 1: Theme Data Models and Color Engine

### Step 1.1: Create Theme Palette Definitions
**Goal**: Define all 60+ theme palettes as structured data
**Method**: Create `lib/src/model/theme/theme_palette.dart` with:
- `ThemePalette` record with name, category, colors array
- All palette definitions with hex colors from requirements
- Categories: Named, Gradient, Light, Dark, HighContrast, Gaming, Premium

**Reference**: New file

### Step 1.2: Create Color Generation Engine
**Goal**: Generate full color scheme from seed colors
**Method**: Create `lib/src/model/theme/theme_colors.dart` with:
- `AppColorScheme` record with all 15+ color roles
- `ColorGenerator.generateFromSeed()` method
- Contrast ratio calculator for accessibility
- Light/dark variant generator

**Reference**: New file

### Step 1.3: Create Theme Categories
**Goal**: Define theme categories for filtering
**Method**: Create `lib/src/model/theme/theme_category.dart` with:
- `ThemeCategory` enum with all categories
- Category metadata (name, icon, description)

**Reference**: New file

## Phase 2: Theme Manager and Persistence

### Step 2.1: Create Theme Preferences Provider
**Goal**: Manage theme selection state with persistence
**Method**: Create `lib/src/model/settings/theme_preferences.dart`:
- `ThemePrefs` Freezed class with current theme ID, favorites, recent list
- `ThemePreferencesNotifier` extending Notifier with persistence
- Methods: selectTheme, toggleFavorite, addToRecent, resetToDefault

**Reference**: New file

### Step 2.2: Create Theme Manager
**Goal**: Centralized theme management service
**Method**: Create `lib/src/model/theme/theme_manager.dart`:
- `ThemeManager` provider combining preferences with palette data
- Methods: getThemeById, searchThemes, getByCategory, getFavorites, getRecent
- Caching layer for generated color schemes

**Reference**: New file

## Phase 3: Theme UI Components

### Step 3.1: Create Theme Preview Card
**Goal**: Visual preview widget for theme selection
**Method**: Create `lib/src/widgets/theme_preview_card.dart`:
- Mini chessboard preview with theme colors
- Theme name and category badge
- Favorite toggle button
- Selected state indicator

**Reference**: New file

### Step 3.2: Create Theme Browser Screen
**Goal**: Full theme selection interface
**Method**: Create `lib/src/view/settings/theme_browser_screen.dart`:
- Search bar with live filtering
- Category filter chips (horizontal scroll)
- Grid of theme preview cards
- Favorites section (collapsible)
- Recently used section (collapsible)
- Theme details bottom sheet

**Reference**: New file

### Step 3.3: Integrate Theme Browser in Settings
**Goal**: Make theme browser accessible from settings
**Method**: Modify `lib/src/view/settings/theme_settings_screen.dart`:
- Add "Browse All Themes" button linking to browser
- Show current theme preview

**Reference**: `lib/src/view/settings/theme_settings_screen.dart`

## Phase 4: Integration with Existing Theme System

### Step 4.1: Extend Theme Generation
**Goal**: Apply selected theme to Material theme
**Method**: Modify `lib/src/theme.dart`:
- Add `makeAppThemeFromPalette()` method
- Integrate theme palette colors into ColorScheme
- Add smooth transition support

**Reference**: `lib/src/theme.dart`

### Step 4.2: Connect to App
**Goal**: Wire theme system into app initialization
**Method**: Modify `lib/src/app.dart`:
- Add theme preferences provider to providers list
- Pass selected theme to makeAppTheme()

**Reference**: `lib/src/app.dart`

## Phase 5: Play Store Deployment Removal

### Step 5.1: Remove Play Store Workflow
**Goal**: Delete Play Store deployment workflow
**Method**: Delete `.github/workflows/deploy_play_store.yml`

**Reference**: `.github/workflows/deploy_play_store.yml`

### Step 5.2: Update Fastfile
**Goal**: Remove Play Store deployment lanes
**Method**: Replace `android/fastlane/Fastfile` content to only contain:
- Comment header
- Basic appbundle build lane (without upload)

**Reference**: `android/fastlane/Fastfile`

### Step 5.3: Remove Play Store Appfile
**Goal**: Delete Play Store specific configuration
**Method**: Delete `android/fastlane/Appfile`

**Reference**: `android/fastlane/Appfile`

### Step 5.4: Verify Build Workflow
**Goal**: Ensure build workflow still functions
**Method**: Review `.github/workflows/build.yml` - no changes needed

**Reference**: `.github/workflows/build.yml`

# 5. TESTING AND VALIDATION

## Theme System Tests
1. Verify all 60+ palettes render correctly in theme browser
2. Verify theme selection persists after app restart
3. Verify favorites can be added/removed and persist
4. Verify recent themes list updates correctly
5. Verify search filters themes by name
6. Verify category filters work correctly
7. Verify theme preview updates in real-time
8. Verify theme applies instantly without restart
9. Verify smooth crossfade transitions between themes
10. Verify contrast ratios meet accessibility standards

## Play Store Removal Tests
1. Verify APK build succeeds: `flutter build apk --debug`
2. Verify AAB build succeeds: `flutter build appbundle --debug`
3. Verify deploy_play_store.yml is deleted
4. Verify Fastfile no longer contains upload_to_play_store
5. Verify GitHub Release workflow still works

## Integration Tests
1. Verify theme changes apply to home screen
2. Verify theme changes apply to game board
3. Verify theme changes apply to analysis board
4. Verify theme changes apply to puzzle screens
5. Verify theme changes apply to settings screens
6. Verify theme changes apply to navigation bars
7. Verify theme changes apply to dialogs and bottom sheets
8. Verify no regressions in existing functionality

## Validation Commands
```bash
# Build verification
flutter analyze
flutter build apk --debug
flutter build appbundle --debug

# Code generation
dart run build_runner build
```

# 6. THEME PALETTES (60+ PALETTES)

## Electric Palettes
- Electric: Cobalt #1B4FE4, Coral #FF4757, Lemon #FFE100, Mint #00E59B, Void #0D0D0D

## Japanese/Wabi-Sabi
- Wabi-Sabi: Washi #F4EEE0, Umber #9E7B5A, Moss #6B7C49, Sumi #2F2B24, Linen #EAE0D5
- Japanese Carmine/Dark Slate Gray: Japanese Carmine #982930, Dark Slate Gray #39544B
- Matcha Cream/Milky Honey: Matcha Cream #9CA763, Milky Honey #F1E8C7

## Nature/Coastal
- Coastal Edit: Sand #E8D5B7, Ocean #2A7B9B, Sea Foam #A8D8CF, Driftwood #8B6F47, Mist #F2F7F5
- Sage & Clay: Sage #B2C5A8, Clay #C4785A, Cream #F5F0E8, Slate #7A8B8B, Bark #5C4A3A
- Sage/Black Olive: Sage #B2B49C, Black Olive #3B3B2A

## Luxury/Elegant
- Luxury Noir: Jet #1A1A1A, Gold #D4AF37, Ivory #F8F4E3, Cognac #9C4B1B, Platinum #E5E5E5
- Luxury Noir/Soft Oat: Luxury Noir #060D0C, Soft Oat #F0EDE5
- Vanilla Latte/Teal Forest: Vanilla Latte #EFE1D5, Teal Forest #184E50

## Vibrant/Gaming
- Solar Flare: Solar Gold #FFAA00, Flare Crimson #E8003A
- Neon Tide: Neon Mint #00F5AA, Electric Violet #3B00FF
- Fiery Rose/Black Pearl: Fiery Rose #FF4D73, Black Pearl #00181B

## Cool Tones
- Arctic: Ice White #E8F5FF, Polar Blue #0050D8
- Cyan Spark: Cyan Spark #00D4FF
- Deep Navy/Vibrant Cyan: Deep Navy #001935, Vibrant Cyan #2FE8FF
- Tranquil Orange/Maastricht Blue: Tranquil Orange #FFB268, Maastricht Blue #001E37

## Warm Tones
- Berry Glow: Royal Berry #9333EA, Glow Rose #FB7185
- Cotton Candy: Sky Candy #7AA8FF, Candy Pink #FF9AEF
- Golden Ember: Golden Sun #FACC15, Ember Orange #F97316
- Dark Scarlet/Antique Ruby: Dark Scarlet #4F0715, Antique Ruby #781728

## Purple/Magenta
- Dusk: Sunset Pink #FF5CBA, Deep Indigo #2B00FF
- Magenta: Deep Magenta #4B0C37, Bright Magenta #C8005A
- Deep Royal Purple/Soft Snow White: Deep Royal Purple #460B6A, Soft Snow White #FFFBFF
- Deep Rich Purple/Light Cream: Deep Rich Purple #720065, Light Cream #FDF9B6
- Blacklist Purple/Transparent Pink: Blacklist Purple #240A30, Transparent Pink #FFDCF0
- Thistle/Liberty: Thistle #DEC2DB, Liberty #5B62B3

## Green Tones
- Dark Green/Neon Green: Dark Green #01210A, Neon Green #A8FF00
- Dark Rich Green/Golden Yellow: Dark Rich Green #014726, Golden Yellow #FFCF00
- Muted Blue Green/Fresh Green: Muted Blue Green #162531, Fresh Green #9AF376

## Earth Tones
- Liver/Tan: Liver #6A3428, Tan #CFB882
- Bistre/Brown Sugar: Bistre #3D2C22, Brown Sugar #BB734B
- Coffee Bean/Almond: Coffee Bean #2E0D14, Almond #EFE1D5
- Mocha Berry/Soft Vanilla: Mocha Berry #784955, Soft Vanilla #FAEDDB

## Dark Tones
- Near Black: Near Black #1A0508
- Dark Gray/Vivid Yellow: Dark Gray #323232, Vivid Yellow #FFDB00
- Dark Red/Bright Warm Yellow: Dark Red #A01717, Bright Warm Yellow #FFE162
- Deep Rich Red/Soft Yellow: Deep Rich Red #AB1509, Soft Yellow #FFF8D2
- Forest Night: Forest Night #0A1200, Orchid Rose #BD5E85

## Blue Tones
- Slate Blue/Glacier: Slate Blue #619BB6, Glacier #BAD7E1
- Navy: Navy #292F91
- Deep Dark Blue/Warm Yellow Orange: Deep Dark Blue #001F7B, Warm Yellow Orange #FFBA09

## Classic/Royal
- Royal Flame: Royal Magenta #DB2777, Flame Red #DC2626
- Aqua Depth: Deep Teal #0F766E, Aqua Cyan #22D3EE
- Burgundy: Burgundy #4A1528
- Sangria: Sangria Red #C0392B, Midnight Black #080205
- Twilight: Twilight Purple #564A96, Twilight Rose #B75F67
- Jasmine/Dark Graphite: Jasmine #F8DE7F, Dark Graphite #3A393F

## Neutral/Warm
- Old Rose/Seashell/Sky Reflection: Old Rose #E19AA6, Seashell #FAF0EA, Sky Reflection #82B0CE
- Soft Fawn/Carbon Black/Ivory Mist: Soft Fawn #D5B572, Carbon Black #201F14, Ivory Mist #F8F2E1
- Onyx/Olive/Desert: Onyx #13140E, Olive #838236, Desert #DEDACF
- Stormy Teal/Oxidized Iron/Pale Oak: Stormy Teal #32707C, Oxidized Iron #A8371C, Pale Oak #D4C4B7
