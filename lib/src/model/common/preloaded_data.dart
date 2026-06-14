import 'dart:io' show Directory;
import 'dart:async';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lichess_mobile/src/constants.dart';
import 'package:lichess_mobile/src/db/secure_storage.dart';
import 'package:lichess_mobile/src/model/auth/auth_controller.dart';
import 'package:lichess_mobile/src/model/auth/auth_storage.dart';
import 'package:lichess_mobile/src/network/http.dart';
import 'package:lichess_mobile/src/utils/string.dart';
import 'package:lichess_mobile/src/utils/system.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory, getApplicationSupportDirectory;

typedef PreloadedData = ({
  PackageInfo packageInfo,
  BaseDeviceInfo deviceInfo,
  AuthUser? authUser,
  String sri,
  int engineMaxMemoryInMb,
  Directory? appDocumentsDirectory,
  Directory? appSupportDirectory,
});

/// A provider that preloads various data needed throughout the app.
final preloadedDataProvider = FutureProvider<PreloadedData>((Ref ref) async {
  final authStorage = ref.read(authStorageProvider);

  // Run independent tasks in parallel
  final pInfoFuture = PackageInfo.fromPlatform();
  final deviceInfoFuture = DeviceInfoPlugin().deviceInfo;
  final sriFuture = _getSri();
  final authUserFuture = authStorage.read();
  final physicalMemoryFuture = System.instance.getTotalRam();
  final appDocsDirFuture = getApplicationDocumentsDirectory().catchError((_) => Directory(''));
  final appSupportDirFuture = getApplicationSupportDirectory().catchError((_) => Directory(''));

  final results = await Future.wait([
    pInfoFuture,
    deviceInfoFuture,
    sriFuture,
    authUserFuture,
    physicalMemoryFuture,
    appDocsDirFuture,
    appSupportDirFuture,
  ]);

  final pInfo = results[0] as PackageInfo;
  final deviceInfo = results[1] as BaseDeviceInfo;
  final sri = results[2] as String;
  var authUser = results[3] as AuthUser?;
  final physicalMemory = (results[4] as double?) ?? 256.0;
  final appDocumentsDirectory = results[5] as Directory?;
  final appSupportDirectory = results[6] as Directory?;

  final token = authUser?.token;
  if (token != null) {
    // Non-blocking token validation
    final userAgent = makeUserAgent(pInfo, deviceInfo, sri, null);
    final client = DefaultClient(ref.read(httpClientFactoryProvider)(), userAgent: userAgent);
    unawaited(client
        .postReadJson(lichessUri('/api/token/test'), mapper: (json) => json, body: token)
        .timeout(const Duration(seconds: 5))
        .then((data) {
          final isValid = data[token] != null;
          if (!isValid) {
            authStorage.delete();
            // Note: can't easily update local variable for the return record here if it's already returned,
            // but the side effect (storage delete) is what matters for next start.
          }
        })
        .catchError((_) {})
        .whenComplete(() {
          client.close();
        }));
  }

  final engineMaxMemory = (physicalMemory / 10).ceil();

  return (
    packageInfo: pInfo,
    deviceInfo: deviceInfo,
    authUser: authUser,
    sri: sri,
    engineMaxMemoryInMb: engineMaxMemory,
    appDocumentsDirectory: appDocumentsDirectory,
    appSupportDirectory: appSupportDirectory,
  );
}, name: 'PreloadedDataProvider');

Future<String> _getSri() async {
  try {
    final storedSri = await SecureStorage.instance.read(key: kSRIStorageKey);
    if (storedSri != null) return storedSri;

    final sri = genRandomString(12);
    await SecureStorage.instance.write(key: kSRIStorageKey, value: sri);
    return sri;
  } on PlatformException catch (_) {
    await SecureStorage.instance.deleteAll();
    return genRandomString(12);
  } catch (_) {
    return genRandomString(12);
  }
}
