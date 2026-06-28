import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lichess_mobile/src/model/engine/evaluation_preferences.dart';
import 'package:lichess_mobile/src/model/engine/evaluation_service.dart';

// This file was missing and is a dependency for several screens.
// Re-exporting providers from evaluation_service.dart and evaluation_preferences.dart
// to satisfy legacy imports if any, or providing common types.

export 'package:lichess_mobile/src/model/engine/evaluation_service.dart';
export 'package:lichess_mobile/src/model/engine/evaluation_preferences.dart';
