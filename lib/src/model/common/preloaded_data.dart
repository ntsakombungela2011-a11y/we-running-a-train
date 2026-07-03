import 'dart:io' show Directory;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lichess_mobile/src/constants.dart';
import 'package:lichess_mobile/src/db/secure_storage.dart';
import 'package:lichess_mobile/src/model/auth/auth_controller.dart';
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

final preloadedDataProvider = FutureProvider<PreloadedData>((Ref ref) async {
  final pInfo = await PackageInfo.fromPlatform();
  final deviceInfo = await DeviceInfoPlugin().deviceInfo;

  String? storedSri;
  try {
    storedSri = await SecureStorage.instance.read(key: kSRIStorageKey);
  } on PlatformException catch (_) {
    await SecureStorage.instance.deleteAll();
  }
  final sri = storedSri ?? genRandomString(12);

  // Return a static offline user immediately
  const authUser = AuthUser(
    user: LightUser(id: UserId('offline_user'), name: 'Offline User'),
    token: 'offline_token',
  );

  final physicalMemory = await System.instance.getTotalRam() ?? 256.0;
  final engineMaxMemory = (physicalMemory / 10).ceil();

  Directory? appDocumentsDirectory;
  try {
    appDocumentsDirectory = await getApplicationDocumentsDirectory();
  } catch (_) {}

  Directory? appSupportDirectory;
  try {
    appSupportDirectory = await getApplicationSupportDirectory();
  } catch (_) {}

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
