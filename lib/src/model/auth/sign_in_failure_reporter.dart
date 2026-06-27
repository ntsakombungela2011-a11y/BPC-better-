import 'package:flutter/foundation.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> reportSignInFailure(
  Ref ref,
  Object error,
  StackTrace stack, {
  required bool cancelled,
}) async {
  if (!cancelled) {
    debugPrint('Sign-in failed: $error');
  }
}
