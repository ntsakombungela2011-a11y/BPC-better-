import 'package:flutter_test/flutter_test.dart';
import 'package:lichess_mobile/src/model/settings/theme_preferences.dart';

void main() {
  group('ThemePrefs', () {
    test('toJson and fromJson', () {
      const prefs = ThemePrefs(
        selectedThemeId: 'electric',
        favoriteThemeIds: ['wabi_sabi'],
        recentThemeIds: ['electric', 'coastal_edit'],
      );
      final json = prefs.toJson();
      final fromJson = ThemePrefs.fromJson(json);
      expect(fromJson.selectedThemeId, prefs.selectedThemeId);
      expect(fromJson.favoriteThemeIds, prefs.favoriteThemeIds);
      expect(fromJson.recentThemeIds, prefs.recentThemeIds);
    });

    test('copyWith', () {
      const prefs = ThemePrefs(selectedThemeId: 'electric');
      final updated = prefs.copyWith(selectedThemeId: 'wabi_sabi');
      expect(updated.selectedThemeId, 'wabi_sabi');
      expect(updated.favoriteThemeIds, prefs.favoriteThemeIds);
    });
  });
}
