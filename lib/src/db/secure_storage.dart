import 'package:flutter_secure_storage/flutter_secure_storage.dart';

AndroidOptions _getAndroidOptions() =>
    const AndroidOptions(storageNamespace: 'com.boipelo.chess.secure');

class SecureStorage extends FlutterSecureStorage {
  const SecureStorage._({super.aOptions});

  static final instance = SecureStorage._(aOptions: _getAndroidOptions());
}
